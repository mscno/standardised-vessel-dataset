package xml

import (
	"bytes"
	"context"
	"errors"
	"strings"
	"testing"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

type fakeEncoder struct {
	encodeErr error
	flushErr  error
}

func (f fakeEncoder) Indent(prefix, indent string) {}
func (f fakeEncoder) Encode(v any) error           { return f.encodeErr }
func (f fakeEncoder) Flush() error                 { return f.flushErr }

func TestXMLExporterInternalBranches(t *testing.T) {
	t.Run("encode_error", func(t *testing.T) {
		orig := newXMLEncoder
		defer func() { newXMLEncoder = orig }()
		newXMLEncoder = func(*bytes.Buffer) xmlEncoder { return fakeEncoder{encodeErr: errors.New("encode")} }

		exporter := NewXMLExporter(nil)
		_, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{General: &models.GeneralInformation{Imo: "1234567", ShipReportingDate: time.Now().UTC()}})
		if err == nil || !strings.Contains(err.Error(), "marshal svd xml") {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("flush_error", func(t *testing.T) {
		orig := newXMLEncoder
		defer func() { newXMLEncoder = orig }()
		newXMLEncoder = func(*bytes.Buffer) xmlEncoder { return fakeEncoder{flushErr: errors.New("flush")} }

		exporter := NewXMLExporter(nil)
		_, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{General: &models.GeneralInformation{Imo: "1234567", ShipReportingDate: time.Now().UTC()}})
		if err == nil || !strings.Contains(err.Error(), "flush svd xml encoder") {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("filename_without_general", func(t *testing.T) {
		exporter := NewXMLExporter(nil)
		result, err := exporter.ExportAsync(context.Background(), &models.StandardisedVesselDataset{})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !strings.HasPrefix(result.FileName, "SVD_") || !strings.HasSuffix(result.FileName, ".xml") {
			t.Fatalf("unexpected filename: %s", result.FileName)
		}
	})
}
