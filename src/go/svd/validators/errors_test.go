package validators_test

import (
	"strings"
	"testing"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

func TestValidatorException(t *testing.T) {
	t.Run("empty", func(t *testing.T) {
		ex := validators.NewValidatorException(nil)
		if ex.Error() != "Validation failed" {
			t.Fatalf("unexpected message: %s", ex.Error())
		}
		if ex.HasErrors() {
			t.Fatal("expected no errors")
		}
	})

	t.Run("with_errors", func(t *testing.T) {
		ex := validators.NewValidatorException([]validators.ValidationError{{
			Field:   "General.Imo",
			Message: "Imo is required",
		}})
		if !ex.HasErrors() {
			t.Fatal("expected has errors")
		}
		msg := ex.Error()
		if !strings.Contains(msg, "Validation failed") || !strings.Contains(msg, "General.Imo: Imo is required") {
			t.Fatalf("unexpected message: %s", msg)
		}
	})
}
