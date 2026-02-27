package exporters_test

import (
	"context"
	"errors"
	"testing"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

type fakeValidator struct {
	errs []validators.ValidationError
}

func (f *fakeValidator) Validate(*models.StandardisedVesselDataset) []validators.ValidationError {
	return f.errs
}

func TestBaseExporter(t *testing.T) {
	t.Run("nil_context", func(t *testing.T) {
		b := exporters.NewBaseExporter(nil)
		called := false
		_, err := b.ValidateAndExport(nil, testdata.ValidSVD(), func(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
			called = true
			return &exporters.StandardisedVesselDatasetContent{}, nil
		})
		if err != nil {
			t.Fatalf("unexpected error: %v", err)
		}
		if !called {
			t.Fatal("expected export to be called")
		}
	})

	t.Run("cancelled_context", func(t *testing.T) {
		ctx, cancel := context.WithCancel(context.Background())
		cancel()
		b := exporters.NewBaseExporter(nil)
		_, err := b.ValidateAndExport(ctx, testdata.ValidSVD(), func(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
			return nil, nil
		})
		if !errors.Is(err, context.Canceled) {
			t.Fatalf("expected canceled error, got %v", err)
		}
	})

	t.Run("nil_svd", func(t *testing.T) {
		b := exporters.NewBaseExporter(nil)
		_, err := b.ValidateAndExport(context.Background(), nil, func(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
			return nil, nil
		})
		if err == nil || err.Error() != "svd cannot be nil" {
			t.Fatalf("unexpected error: %v", err)
		}
	})

	t.Run("validation_error", func(t *testing.T) {
		b := exporters.NewBaseExporter(&fakeValidator{errs: []validators.ValidationError{{Field: "General.Imo", Message: "Imo is required"}}})
		_, err := b.ValidateAndExport(context.Background(), testdata.ValidSVD(), func(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
			return nil, nil
		})
		if _, ok := err.(*validators.ValidatorException); !ok {
			t.Fatalf("expected ValidatorException, got %T", err)
		}
	})

	t.Run("export_error", func(t *testing.T) {
		exportErr := errors.New("boom")
		b := exporters.NewBaseExporter(nil)
		_, err := b.ValidateAndExport(context.Background(), testdata.ValidSVD(), func(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
			return nil, exportErr
		})
		if !errors.Is(err, exportErr) {
			t.Fatalf("expected export error, got %v", err)
		}
	})
}
