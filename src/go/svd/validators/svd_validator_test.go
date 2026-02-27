package validators_test

import (
	"testing"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestStandardisedVesselDatasetValidator(t *testing.T) {
	validator := validators.NewStandardisedVesselDatasetValidator()

	t.Run("nil_svd", func(t *testing.T) {
		errs := validator.Validate(nil)
		if len(errs) != 1 || errs[0].Message != "SVD cannot be nil" {
			t.Fatalf("unexpected errors: %+v", errs)
		}
	})

	t.Run("missing_general", func(t *testing.T) {
		errs := validator.Validate(&models.StandardisedVesselDataset{})
		if len(errs) != 1 || errs[0].Message != "General is required" {
			t.Fatalf("unexpected errors: %+v", errs)
		}
	})

	t.Run("valid", func(t *testing.T) {
		errs := validator.Validate(testdata.ValidSVD())
		if len(errs) != 0 {
			t.Fatalf("expected no errors, got %+v", errs)
		}
	})

	t.Run("invalid", func(t *testing.T) {
		errs := validator.Validate(testdata.InvalidSVD())
		if len(errs) == 0 {
			t.Fatal("expected validation errors")
		}
	})
}
