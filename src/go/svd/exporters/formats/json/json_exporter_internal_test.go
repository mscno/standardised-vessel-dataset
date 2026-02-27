package json

import (
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

func TestJSONExporterInternalBranches(t *testing.T) {
	t.Run("marshal_error", func(t *testing.T) {
		orig := marshalIndentFunc
		defer func() { marshalIndentFunc = orig }()
		marshalIndentFunc = func(v any, prefix, indent string) ([]byte, error) {
			return nil, errors.New("boom")
		}

		exporter := NewJSONExporter(nil)
		_, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{General: &models.GeneralInformation{Imo: "1234567", ShipReportingDate: time.Now().UTC()}})
		if err == nil || !strings.Contains(err.Error(), "marshal svd json") {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("filename_without_general", func(t *testing.T) {
		exporter := NewJSONExporter(nil)
		result, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !strings.HasPrefix(result.FileName, "SVD_") || !strings.HasSuffix(result.FileName, ".json") {
			t.Fatalf("unexpected filename: %s", result.FileName)
		}
	})
}
