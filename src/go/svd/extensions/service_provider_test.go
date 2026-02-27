package extensions_test

import (
	"context"
	"errors"
	"testing"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/extensions"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/internal/testdata"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

type alwaysInvalidValidator struct{}

func (alwaysInvalidValidator) Validate(*models.StandardisedVesselDataset) []validators.ValidationError {
	return []validators.ValidationError{{Field: "General.Imo", Message: "Imo is required"}}
}

type staticExporter struct {
	result *exporters.StandardisedVesselDatasetContent
	err    error
}

func (s staticExporter) ExportAsync(context.Context, *models.StandardisedVesselDataset) (*exporters.StandardisedVesselDatasetContent, error) {
	return s.result, s.err
}

func TestServiceProvider(t *testing.T) {
	t.Run("default_provider", func(t *testing.T) {
		p := extensions.NewServiceProvider()
		if p.GetValidator() == nil || p.GetJSONExporter() == nil || p.GetCSVExporter() == nil || p.GetXMLExporter() == nil {
			t.Fatal("provider returned nil services")
		}
	})

	t.Run("custom_validator", func(t *testing.T) {
		p := extensions.NewServiceProviderWithCustomValidator(alwaysInvalidValidator{})
		_, err := p.GetJSONExporter().ExportAsync(context.Background(), testdata.ValidSVD())
		if err == nil {
			t.Fatal("expected validation error")
		}
	})

	t.Run("set_validator_updates_exporters", func(t *testing.T) {
		p := extensions.NewServiceProvider()
		p.SetValidator(alwaysInvalidValidator{})
		_, err := p.GetCSVExporter().ExportAsync(context.Background(), testdata.ValidSVD())
		if err == nil {
			t.Fatal("expected validator error")
		}
	})

	t.Run("set_custom_exporters", func(t *testing.T) {
		p := extensions.NewServiceProvider()
		customResult := &exporters.StandardisedVesselDatasetContent{Data: []byte("x"), FileName: "x", ContentType: "text/plain"}
		customErr := errors.New("custom")

		p.SetJSONExporter(staticExporter{result: customResult})
		p.SetCSVExporter(staticExporter{err: customErr})
		p.SetXMLExporter(staticExporter{result: customResult})

		if got, err := p.GetJSONExporter().ExportAsync(context.Background(), nil); err != nil || got != customResult {
			t.Fatalf("unexpected json exporter result: %v %v", got, err)
		}
		if _, err := p.GetCSVExporter().ExportAsync(context.Background(), nil); !errors.Is(err, customErr) {
			t.Fatalf("unexpected csv exporter error: %v", err)
		}
		if got, err := p.GetXMLExporter().ExportAsync(context.Background(), nil); err != nil || got != customResult {
			t.Fatalf("unexpected xml exporter result: %v %v", got, err)
		}
	})
}
