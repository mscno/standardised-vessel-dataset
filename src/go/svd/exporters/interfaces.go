package exporters

import (
	"context"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

// SVDExporter represents a generic interface for exporting Standardised Vessel Datasets (SVD)
type SVDExporter interface {
	// ExportAsync exports SVD to output format (XML, JSON, CSV)
	// Returns StandardisedVesselDatasetContent or error if validation fails
	ExportAsync(ctx context.Context, svd *models.StandardisedVesselDataset) (*StandardisedVesselDatasetContent, error)
}

// SVDJSONExporter represents a JSON exporter for Standardised Vessel Datasets
type SVDJSONExporter interface {
	SVDExporter
}

// SVDCSVExporter represents a CSV exporter for Standardised Vessel Datasets
type SVDCSVExporter interface {
	SVDExporter
}

// SVDXMLExporter represents an XML exporter for Standardised Vessel Datasets
type SVDXMLExporter interface {
	SVDExporter
}
