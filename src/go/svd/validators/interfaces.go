package validators

import "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"

// ValidationError represents a validation error for a specific field
type ValidationError struct {
	Field   string
	Message string
	Value   interface{}
}

// SVDValidator interface for validating StandardisedVesselDataset
type SVDValidator interface {
	Validate(svd *models.StandardisedVesselDataset) []ValidationError
}

// GeneralInformationValidator interface for validating GeneralInformation
type GeneralInformationValidator interface {
	Validate(general *models.GeneralInformation) []ValidationError
}
