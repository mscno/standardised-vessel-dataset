package xml_test

import (
	"context"
	"encoding/xml"
	"strings"
	"testing"

	xmlexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/xml"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestXMLExporter(t *testing.T) {
	exporter := xmlexporter.NewXMLExporter(validators.NewStandardisedVesselDatasetValidator())

	t.Run("valid_export", func(t *testing.T) {
		result, err := exporter.ExportAsync(context.Background(), testdata.ValidSVD())
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if result.ContentType != "application/xml" {
			t.Fatalf("unexpected content type: %s", result.ContentType)
		}
		if result.FileName != "SVD_9876543_2025-01-02.xml" {
			t.Fatalf("unexpected file name: %s", result.FileName)
		}

		xmlText := string(result.Data)
		if !strings.HasPrefix(xmlText, "<?xml version=\"1.0\" encoding=\"UTF-8\"?>") {
			t.Fatalf("missing xml declaration: %s", xmlText)
		}

		start := strings.Index(xmlText, "<StandardisedVesselDataset")
		if start == -1 {
			t.Fatal("missing root element")
		}

		var decoded models.StandardisedVesselDataset
		if err := xml.Unmarshal([]byte(xmlText[start:]), &decoded); err != nil {
			t.Fatalf("invalid xml output: %v", err)
		}
		if decoded.General == nil || decoded.General.Imo != "9876543" {
			t.Fatalf("missing general in xml output: %+v", decoded.General)
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
