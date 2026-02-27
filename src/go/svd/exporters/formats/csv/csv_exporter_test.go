package csv_test

import (
	"context"
	"encoding/csv"
	"strings"
	"testing"

	csvexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/csv"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestCSVExporter(t *testing.T) {
	exporter := csvexporter.NewCSVExporter(validators.NewStandardisedVesselDatasetValidator())

	t.Run("valid_export", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), testdata.ValidSVD())
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if result.ContentType != "text/csv" {
			t.Fatalf("unexpected content type: %s", result.ContentType)
		}
		if result.FileName != "SVD_9876543_2025-01-02.csv" {
			t.Fatalf("unexpected file name: %s", result.FileName)
		}

		records := readCSV(t, result.Data)
		if len(records) != 2 {
			t.Fatalf("expected 2 records, got %d", len(records))
		}

		headers := records[0]
		values := records[1]
		if headers[0] != "General.EventType" {
			t.Fatalf("unexpected first header: %s", headers[0])
		}

		m := mapFromRow(headers, values)
		if m["General.ShipReportingDate"] != "2025-01-02T15:04:05.0000000Z" {
			t.Fatalf("unexpected datetime format: %s", m["General.ShipReportingDate"])
		}
		if m["General.ElapsedTime"] != "1.00:00:00" {
			t.Fatalf("unexpected duration format: %s", m["General.ElapsedTime"])
		}
		if m["SpeedAndDistance.LadenIndicator"] != "True" {
			t.Fatalf("unexpected bool format: %s", m["SpeedAndDistance.LadenIndicator"])
		}
	})

	t.Run("nil_section_outputs_blanks", func(t *testing.T) {
		svd := &models.StandardisedVesselDataset{General: testdata.ValidSVD().General}
		result, err := exporter.ExportAsync(context.Background(), svd)
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		records := readCSV(t, result.Data)
		m := mapFromRow(records[0], records[1])
		if m["PortAndRoute.DeparturePortCode"] != "" {
			t.Fatalf("expected blank value for nil section, got %q", m["PortAndRoute.DeparturePortCode"])
		}
	})

	t.Run("invalid_svd", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), testdata.InvalidSVD())
		if err == nil || !strings.Contains(err.Error(), "Validation failed") {
			t.Fatalf("unexpected error: %v", err)
		}
		if result != nil {
			t.Fatal("expected nil result")
		}
	})
}

func readCSV(t *testing.T, data []byte) [][]string {
	t.Helper()
	r := csv.NewReader(strings.NewReader(string(data)))
	records, err := r.ReadAll()
	if err != nil {
		t.Fatalf("invalid csv output: %v", err)
	}
	return records
}

func mapFromRow(headers, values []string) map[string]string {
	m := make(map[string]string, len(headers))
	for i := range headers {
		m[headers[i]] = values[i]
	}
	return m
}
