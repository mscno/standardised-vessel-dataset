package json_test

import (
	"context"
	"encoding/json"
	"strings"
	"testing"

	jsonexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/json"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestJSONExporter(t *testing.T) {
	exporter := jsonexporter.NewJSONExporter(validators.NewStandardisedVesselDatasetValidator())

	t.Run("valid_export", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), testdata.ValidSVD())
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if result.ContentType != "application/json" {
			t.Fatalf("unexpected content type: %s", result.ContentType)
		}
		if result.FileName != "SVD_9876543_2025-01-02.json" {
			t.Fatalf("unexpected file name: %s", result.FileName)
		}

		var decoded models.StandardisedVesselDataset
		if err := json.Unmarshal(result.Data, &decoded); err != nil {
			t.Fatalf("invalid json output: %v", err)
		}
		if decoded.General == nil || decoded.General.Imo != "9876543" {
			t.Fatalf("missing general imo in output: %+v", decoded.General)
		}
	})

	t.Run("invalid_svd", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), testdata.InvalidSVD())
		if err == nil {
			t.Fatal("expected validation error")
		}
		if result != nil {
			t.Fatal("expected nil result")
		}
		if !strings.Contains(err.Error(), "Validation failed") {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("nil_svd", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), nil)
		if err == nil || err.Error() != "svd cannot be nil" {
			t.Fatalf("unexpected error: %v", err)
		}
		if result != nil {
			t.Fatal("expected nil result")
		}
	})
}
