package validators

import "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"

// StandardisedVesselDatasetValidator validates SVD models.
type StandardisedVesselDatasetValidator struct {
	generalValidator GeneralInformationValidator
}

// NewStandardisedVesselDatasetValidator creates a new SVD validator.
func NewStandardisedVesselDatasetValidator() SVDValidator {
	return &StandardisedVesselDatasetValidator{
		generalValidator: NewGeneralInformationValidator(),
	}
}

// Validate validates the StandardisedVesselDataset.
func (v *StandardisedVesselDatasetValidator) Validate(svd *models.StandardisedVesselDataset) []ValidationError {
	if svd == nil {
		return []ValidationError{{
			Field:   "SVD",
			Message: "SVD cannot be nil",
		}}
	}

	if svd.General == nil {
		return []ValidationError{{
			Field:   "General",
			Message: "General is required",
		}}
	}

	return v.generalValidator.Validate(svd.General)
}
