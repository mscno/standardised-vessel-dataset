package csv

import (
	"context"
	"encoding/csv"
	"errors"
	"reflect"
	"strings"
	"testing"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

func TestCSVExporterInternalBranches(t *testing.T) {
	t.Run("write_error", func(t *testing.T) {
		orig := writeCSVRecords
		defer func() { writeCSVRecords = orig }()
		writeCSVRecords = func(_ *csv.Writer, _ []string, _ []string) error {
			return errors.New("write")
		}

		exporter := NewCSVExporter(nil)
		_, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{General: &models.GeneralInformation{Imo: "1234567", ShipReportingDate: time.Now().UTC()}})
		if err == nil || !strings.Contains(err.Error(), "write") {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("filename_without_general", func(t *testing.T) {
		exporter := NewCSVExporter(nil)
		result, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !strings.HasPrefix(result.FileName, "SVD_") || !strings.HasSuffix(result.FileName, ".csv") {
			t.Fatalf("unexpected filename: %s", result.FileName)
		}
	})
}

func TestFormatValue(t *testing.T) {
	t.Run("force_empty", func(t *testing.T) {
		if got := formatValue(reflect.TypeOf(""), reflect.ValueOf("x"), true); got != "" {
			t.Fatalf("expected empty, got %q", got)
		}
	})

	t.Run("invalid_value", func(t *testing.T) {
		if got := formatValue(reflect.TypeOf(""), reflect.Value{}, false); got != "" {
			t.Fatalf("expected empty, got %q", got)
		}
	})

	if got := formatValue(reflect.TypeOf(time.Time{}), reflect.ValueOf(time.Time{}), false); got != "" {
		t.Fatalf("expected empty time, got %q", got)
	}
	if got := formatValue(reflect.TypeOf(time.Time{}), reflect.ValueOf(time.Date(2025, 1, 1, 0, 0, 0, 0, time.UTC)), false); got == "" {
		t.Fatal("expected formatted time")
	}
	if got := formatValue(reflect.TypeOf(time.Duration(0)), reflect.ValueOf(2*time.Hour+3*time.Minute+4*time.Second), false); got != "02:03:04" {
		t.Fatalf("unexpected duration format: %q", got)
	}
	if got := formatValue(reflect.TypeOf(true), reflect.ValueOf(true), false); got != "True" {
		t.Fatalf("unexpected bool value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(false), reflect.ValueOf(false), false); got != "False" {
		t.Fatalf("unexpected bool value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(0.0), reflect.ValueOf(1.5), false); got != "1.5" {
		t.Fatalf("unexpected float value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(float32(0)), reflect.ValueOf(float32(1.5)), false); got != "1.5" {
		t.Fatalf("unexpected float32 value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(int64(0)), reflect.ValueOf(int64(7)), false); got != "7" {
		t.Fatalf("unexpected int value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(uint64(0)), reflect.ValueOf(uint64(9)), false); got != "9" {
		t.Fatalf("unexpected uint value: %q", got)
	}
	if got := formatValue(reflect.TypeOf(struct{ A int }{}), reflect.ValueOf(struct{ A int }{A: 1}), false); got != "{1}" {
		t.Fatalf("unexpected default format value: %q", got)
	}
}

func TestFormatDurationAsTimeSpan(t *testing.T) {
	if got := formatDurationAsTimeSpan(-time.Second); got != "-00:00:01" {
		t.Fatalf("unexpected negative duration format: %q", got)
	}
	if got := formatDurationAsTimeSpan(150 * time.Nanosecond); got != "00:00:00.0000001" {
		t.Fatalf("unexpected fractional duration format: %q", got)
	}
	if got := formatDurationAsTimeSpan(26 * time.Hour); got != "1.02:00:00" {
		t.Fatalf("unexpected day duration format: %q", got)
	}
	if got := formatDurationAsTimeSpan(25*time.Hour + 150*time.Nanosecond); got != "1.01:00:00.0000001" {
		t.Fatalf("unexpected fractional day duration format: %q", got)
	}
}

func TestFlattenValuePointerBranches(t *testing.T) {
	type sample struct {
		A string `csv:"A"`
	}
	type sampleWithIgnored struct {
		A string `csv:"A"`
		B string
		C string `csv:"-"`
	}

	var headers []string
	var values []string

	flattenValue("Sample", reflect.TypeOf(&sample{}), reflect.Value{}, false, &headers, &values)
	if len(headers) != 1 || headers[0] != "Sample.A" || values[0] != "" {
		t.Fatalf("unexpected flattened nil pointer values: headers=%v values=%v", headers, values)
	}

	headers = nil
	values = nil
	flattenValue("Sample", reflect.TypeOf(&sample{}), reflect.ValueOf(&sample{A: "x"}), true, &headers, &values)
	if len(headers) != 1 || headers[0] != "Sample.A" || values[0] != "" {
		t.Fatalf("unexpected flattened force-empty values: headers=%v values=%v", headers, values)
	}

	headers = nil
	values = nil
	flattenValue("Sample", reflect.TypeOf(sampleWithIgnored{}), reflect.ValueOf(sampleWithIgnored{A: "ok", B: "skip", C: "skip"}), false, &headers, &values)
	if len(headers) != 1 || headers[0] != "Sample.A" || values[0] != "ok" {
		t.Fatalf("unexpected flatten result with ignored fields: headers=%v values=%v", headers, values)
	}
}
