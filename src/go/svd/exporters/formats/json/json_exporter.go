package json

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

var marshalIndentFunc = json.MarshalIndent

// Exporter implements the JSON exporter for SVD.
type Exporter struct {
	*exporters.BaseExporter
}

// NewJSONExporter creates a new JSON exporter with the given validator.
func NewJSONExporter(validator validators.SVDValidator) exporters.SVDJSONExporter {
	return &Exporter{BaseExporter: exporters.NewBaseExporter(validator)}
}

// ExportAsync exports the SVD to JSON format.
func (e *Exporter) ExportAsync(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	return e.ValidateAndExport(ctx, svd, e.internalExport)
}

func (e *Exporter) internalExport(ctx context.Context, svd *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	data, err := marshalIndentFunc(svd, "", "  ")
	if err != nil {
		return nil, fmt.Errorf("marshal svd json: %w", err)
	}

	return &exporters.StandardisedVesselDatasetContent{
		Data:        data,
		FileName:    generateFileName("json", svd),
		ContentType: "application/json",
	}, nil
}

func generateFileName(ext string, svd *models.StandardisedVesselDataset) string {
	if svd != nil && svd.General != nil {
		return fmt.Sprintf("SVD_%s_%s.%s", svd.General.Imo, svd.General.ShipReportingDate.UTC().Format("2006-01-02"), ext)
	}
	return fmt.Sprintf("SVD_%s.%s", time.Now().UTC().Format("2006-01-02"), ext)
}
