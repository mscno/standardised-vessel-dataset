package validators

import "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"

// GeneralInformationValidatorImpl validates GeneralInformation.
type GeneralInformationValidatorImpl struct{}

// NewGeneralInformationValidator creates a new GeneralInformation validator.
func NewGeneralInformationValidator() GeneralInformationValidator {
	return &GeneralInformationValidatorImpl{}
}

// Validate validates GeneralInformation using the same rules as the .NET implementation.
func (v *GeneralInformationValidatorImpl) Validate(general *models.GeneralInformation) []ValidationError {
	var errors []ValidationError
	if general == nil {
		return []ValidationError{{
			Field:   "General",
			Message: "General is required",
		}}
	}

	if general.Imo == "" {
		errors = append(errors, ValidationError{Field: "General.Imo", Message: "Imo is required", Value: general.Imo})
	}
	if !isSevenDigitImo(general.Imo) {
		errors = append(errors, ValidationError{Field: "General.Imo", Message: "Imo must be seven digits.", Value: general.Imo})
	}
	if general.ShipName == "" {
		errors = append(errors, ValidationError{Field: "General.ShipName", Message: "Ship Name is required", Value: general.ShipName})
	}
	if general.ShipReportingDate.IsZero() {
		errors = append(errors, ValidationError{Field: "General.ShipReportingDate", Message: "Ship Reporting Date (Datetime) must be greater than default.", Value: general.ShipReportingDate})
	}

	return errors
}

func isSevenDigitImo(value string) bool {
	if len(value) != 7 {
		return false
	}

	for i := 0; i < len(value); i++ {
		if value[i] < '0' || value[i] > '9' {
			return false
		}
	}

	return true
}
