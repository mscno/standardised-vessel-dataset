package exporters

import (
	"context"
	"errors"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

// BaseExporter provides common functionality for all exporters.
type BaseExporter struct {
	validator validators.SVDValidator
}

// NewBaseExporter creates a new base exporter with the given validator.
func NewBaseExporter(validator validators.SVDValidator) *BaseExporter {
	return &BaseExporter{validator: validator}
}

// ValidateAndExport validates the SVD and calls the internal export method.
func (b *BaseExporter) ValidateAndExport(
	ctx context.Context,
	svd *models.StandardisedVesselDataset,
	exportFunc func(ctx context.Context, svd *models.StandardisedVesselDataset) (*StandardisedVesselDatasetContent, error),
) (*StandardisedVesselDatasetContent, error) {
	if ctx == nil {
		ctx = context.Background()
	}
	if err := ctx.Err(); err != nil {
		return nil, err
	}
	if svd == nil {
		return nil, errors.New("svd cannot be nil")
	}

	if b.validator != nil {
		validationErrors := b.validator.Validate(svd)
		if len(validationErrors) > 0 {
			return nil, validators.NewValidatorException(validationErrors)
		}
	}

	return exportFunc(ctx, svd)
}
