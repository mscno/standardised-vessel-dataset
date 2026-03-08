package validators_test

import (
	"testing"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestGeneralInformationValidator(t *testing.T) {
	validator := validators.NewGeneralInformationValidator()

	t.Run("nil", func(t *testing.T) {
		errs := validator.Validate(nil)
		if len(errs) != 1 || errs[0].Message != "General is required" {
			t.Fatalf("unexpected errors: %+v", errs)
		}
	})

	t.Run("valid", func(t *testing.T) {
		errs := validator.Validate(&models.GeneralInformation{
			Imo:               "1234567",
			ShipName:          "MV Test",
			ShipReportingDate: time.Now().UTC(),
		})
		if len(errs) != 0 {
			t.Fatalf("expected no errors, got %+v", errs)
		}
	})

	t.Run("invalid", func(t *testing.T) {
		errs := validator.Validate(&models.GeneralInformation{})
		if len(errs) != 4 {
			t.Fatalf("expected 4 errors, got %d (%+v)", len(errs), errs)
		}
	})

	t.Run("invalid_non_numeric_imo", func(t *testing.T) {
		errs := validator.Validate(&models.GeneralInformation{
			Imo:               "12A4567",
			ShipName:          "MV Test",
			ShipReportingDate: time.Now().UTC(),
		})

		if len(errs) != 1 {
			t.Fatalf("expected 1 error, got %d (%+v)", len(errs), errs)
		}

		if errs[0].Field != "General.Imo" || errs[0].Message != "Imo must be seven digits." {
			t.Fatalf("unexpected error: %+v", errs[0])
		}
	})
}
