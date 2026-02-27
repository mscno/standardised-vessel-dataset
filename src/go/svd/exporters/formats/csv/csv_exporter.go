package csv

import (
	"bytes"
	"context"
	"encoding/csv"
	"fmt"
	"reflect"
	"strconv"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

const dotNetUTCFormat = "2006-01-02T15:04:05.0000000Z"

var writeCSVRecords = func(writer *csv.Writer, headers, values []string) error {
	if err := writer.Write(headers); err != nil {
		return fmt.Errorf("write csv header: %w", err)
	}
	if err := writer.Write(values); err != nil {
		return fmt.Errorf("write csv values: %w", err)
	}
	writer.Flush()
	if err := writer.Error(); err != nil {
		return fmt.Errorf("flush csv data: %w", err)
	}
	return nil
}

// Exporter implements the CSV exporter for SVD.
type Exporter struct {
	*exporters.BaseExporter
}

// NewCSVExporter creates a new CSV exporter with the given validator.
func NewCSVExporter(validator validators.SVDValidator) exporters.SVDCSVExporter {
	return &Exporter{BaseExporter: exporters.NewBaseExporter(validator)}
}

// ExportAsync exports the SVD to CSV format.
func (e *Exporter) ExportAsync(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	return e.ValidateAndExport(ctx, svd, e.internalExport)
}

func (e *Exporter) internalExport(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	headers, values := flattenDataset(svd)

	var buf bytes.Buffer
	writer := csv.NewWriter(&buf)
	if err := writeCSVRecords(writer, headers, values); err != nil {
		return nil, err
	}

	return &exporters.StandardisedVesselDatasetContent{
		Data:        buf.Bytes(),
		FileName:    generateFileName("csv", svd),
		ContentType: "text/csv",
	}, nil
}

func generateFileName(ext string, svd *models.StandardisedVesselDataset) string {
	if svd != nil && svd.General != nil {
		return fmt.Sprintf("SVD_%s_%s.%s", svd.General.Imo, svd.General.ShipReportingDate.UTC().Format("2006-01-02"), ext)
	}
	return fmt.Sprintf("SVD_%s.%s", time.Now().UTC().Format("2006-01-02"), ext)
}

func flattenDataset(svd *models.StandardisedVesselDataset) ([]string, []string) {
	var headers []string
	var values []string

	svdType := reflect.TypeOf(models.StandardisedVesselDataset{})
	var svdValue reflect.Value
	if svd != nil {
		svdValue = reflect.ValueOf(svd).Elem()
	}

	for i := 0; i < svdType.NumField(); i++ {
		fieldType := svdType.Field(i)
		csvTag := fieldType.Tag.Get("csv")
		if csvTag == "" || csvTag == "-" {
			continue
		}

		var fieldValue reflect.Value
		if svdValue.IsValid() {
			fieldValue = svdValue.Field(i)
		}

		flattenValue(csvTag, fieldType.Type, fieldValue, false, &headers, &values)
	}

	return headers, values
}

func flattenValue(prefix string, typ reflect.Type, value reflect.Value, forceEmpty bool, headers, values *[]string) {
	if typ.Kind() == reflect.Ptr {
		if forceEmpty || !value.IsValid() || value.IsNil() {
			flattenValue(prefix, typ.Elem(), reflect.Value{}, true, headers, values)
			return
		}
		flattenValue(prefix, typ.Elem(), value.Elem(), false, headers, values)
		return
	}

	if typ == reflect.TypeOf(time.Time{}) || typ == reflect.TypeOf(time.Duration(0)) || typ.Kind() != reflect.Struct {
		*headers = append(*headers, prefix)
		*values = append(*values, formatValue(typ, value, forceEmpty))
		return
	}

	for i := 0; i < typ.NumField(); i++ {
		childType := typ.Field(i)
		csvTag := childType.Tag.Get("csv")
		if csvTag == "" || csvTag == "-" {
			continue
		}

		var childValue reflect.Value
		if value.IsValid() {
			childValue = value.Field(i)
		}

		flattenValue(prefix+"."+csvTag, childType.Type, childValue, forceEmpty, headers, values)
	}
}

func formatValue(typ reflect.Type, value reflect.Value, forceEmpty bool) string {
	if forceEmpty {
		return ""
	}

	if !value.IsValid() {
		return ""
	}

	if typ == reflect.TypeOf(time.Time{}) {
		t := value.Interface().(time.Time)
		if t.IsZero() {
			return ""
		}
		return t.UTC().Format(dotNetUTCFormat)
	}

	if typ == reflect.TypeOf(time.Duration(0)) {
		return formatDurationAsTimeSpan(value.Interface().(time.Duration))
	}

	switch typ.Kind() {
	case reflect.String:
		return value.String()
	case reflect.Int, reflect.Int8, reflect.Int16, reflect.Int32, reflect.Int64:
		return strconv.FormatInt(value.Int(), 10)
	case reflect.Uint, reflect.Uint8, reflect.Uint16, reflect.Uint32, reflect.Uint64:
		return strconv.FormatUint(value.Uint(), 10)
	case reflect.Float32:
		return strconv.FormatFloat(value.Float(), 'f', -1, 32)
	case reflect.Float64:
		return strconv.FormatFloat(value.Float(), 'f', -1, 64)
	case reflect.Bool:
		if value.Bool() {
			return "True"
		}
		return "False"
	default:
		return fmt.Sprintf("%v", value.Interface())
	}
}

func formatDurationAsTimeSpan(d time.Duration) string {
	negative := d < 0
	if negative {
		d = -d
	}

	ticks := d.Nanoseconds() / 100
	const ticksPerSecond int64 = 10_000_000
	const ticksPerMinute = ticksPerSecond * 60
	const ticksPerHour = ticksPerMinute * 60
	const ticksPerDay = ticksPerHour * 24

	days := ticks / ticksPerDay
	ticks = ticks % ticksPerDay
	hours := ticks / ticksPerHour
	ticks = ticks % ticksPerHour
	minutes := ticks / ticksPerMinute
	ticks = ticks % ticksPerMinute
	seconds := ticks / ticksPerSecond
	fractions := ticks % ticksPerSecond

	var out string
	if fractions == 0 {
		if days > 0 {
			out = fmt.Sprintf("%d.%02d:%02d:%02d", days, hours, minutes, seconds)
		} else {
			out = fmt.Sprintf("%02d:%02d:%02d", hours, minutes, seconds)
		}
	} else {
		if days > 0 {
			out = fmt.Sprintf("%d.%02d:%02d:%02d.%07d", days, hours, minutes, seconds, fractions)
		} else {
			out = fmt.Sprintf("%02d:%02d:%02d.%07d", hours, minutes, seconds, fractions)
		}
	}

	if negative {
		return "-" + out
	}
	return out
}
