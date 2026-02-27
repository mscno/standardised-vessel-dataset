package xml

import (
	"bytes"
	"context"
	"encoding/xml"
	"fmt"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

type xmlEncoder interface {
	Indent(prefix, indent string)
	Encode(v any) error
	Flush() error
}

var newXMLEncoder = func(buf *bytes.Buffer) xmlEncoder {
	return xml.NewEncoder(buf)
}

// Exporter implements the XML exporter for SVD.
type Exporter struct {
	*exporters.BaseExporter
}

// NewXMLExporter creates a new XML exporter with the given validator.
func NewXMLExporter(validator validators.SVDValidator) exporters.SVDXMLExporter {
	return &Exporter{BaseExporter: exporters.NewBaseExporter(validator)}
}

// ExportAsync exports the SVD to XML format.
func (e *Exporter) ExportAsync(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	return e.ValidateAndExport(ctx, svd, e.internalExport)
}

func (e *Exporter) internalExport(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	var buf bytes.Buffer
	buf.WriteString("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n")

	encoder := newXMLEncoder(&buf)
	encoder.Indent("", "  ")
	if err := encoder.Encode(svd); err != nil {
		return nil, fmt.Errorf("marshal svd xml: %w", err)
	}
	if err := encoder.Flush(); err != nil {
		return nil, fmt.Errorf("flush svd xml encoder: %w", err)
	}

	return &exporters.StandardisedVesselDatasetContent{
		Data:        buf.Bytes(),
		FileName:    generateFileName("xml", svd),
		ContentType: "application/xml",
	}, nil
}

func generateFileName(ext string, svd *models.StandardisedVesselDataset) string {
	if svd != nil && svd.General != nil {
		return fmt.Sprintf("SVD_%s_%s.%s", svd.General.Imo, svd.General.ShipReportingDate.UTC().Format("2006-01-02"), ext)
	}
	return fmt.Sprintf("SVD_%s.%s", time.Now().UTC().Format("2006-01-02"), ext)
}
