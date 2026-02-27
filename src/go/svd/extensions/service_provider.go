package extensions

import (
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	csvExporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/csv"
	jsonExporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/json"
	xmlExporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/xml"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

// ServiceProvider provides a simple service container for SVD components
type ServiceProvider struct {
	validator    validators.SVDValidator
	jsonExporter exporters.SVDJSONExporter
	csvExporter  exporters.SVDCSVExporter
	xmlExporter  exporters.SVDXMLExporter
}

// NewServiceProvider creates a new service provider with default implementations
func NewServiceProvider() *ServiceProvider {
	validator := validators.NewStandardisedVesselDatasetValidator()

	return &ServiceProvider{
		validator:    validator,
		jsonExporter: jsonExporter.NewJSONExporter(validator),
		csvExporter:  csvExporter.NewCSVExporter(validator),
		xmlExporter:  xmlExporter.NewXMLExporter(validator),
	}
}

// NewServiceProviderWithCustomValidator creates a new service provider with custom validator
func NewServiceProviderWithCustomValidator(validator validators.SVDValidator) *ServiceProvider {
	return &ServiceProvider{
		validator:    validator,
		jsonExporter: jsonExporter.NewJSONExporter(validator),
		csvExporter:  csvExporter.NewCSVExporter(validator),
		xmlExporter:  xmlExporter.NewXMLExporter(validator),
	}
}

// GetValidator returns the SVD validator
func (s *ServiceProvider) GetValidator() validators.SVDValidator {
	return s.validator
}

// GetJSONExporter returns the JSON exporter
func (s *ServiceProvider) GetJSONExporter() exporters.SVDJSONExporter {
	return s.jsonExporter
}

// GetCSVExporter returns the CSV exporter
func (s *ServiceProvider) GetCSVExporter() exporters.SVDCSVExporter {
	return s.csvExporter
}

// GetXMLExporter returns the XML exporter
func (s *ServiceProvider) GetXMLExporter() exporters.SVDXMLExporter {
	return s.xmlExporter
}

// SetValidator sets a custom validator
func (s *ServiceProvider) SetValidator(validator validators.SVDValidator) {
	s.validator = validator
	// Update exporters with new validator
	s.jsonExporter = jsonExporter.NewJSONExporter(validator)
	s.csvExporter = csvExporter.NewCSVExporter(validator)
	s.xmlExporter = xmlExporter.NewXMLExporter(validator)
}

// SetJSONExporter sets a custom JSON exporter
func (s *ServiceProvider) SetJSONExporter(exporter exporters.SVDJSONExporter) {
	s.jsonExporter = exporter
}

// SetCSVExporter sets a custom CSV exporter
func (s *ServiceProvider) SetCSVExporter(exporter exporters.SVDCSVExporter) {
	s.csvExporter = exporter
}

// SetXMLExporter sets a custom XML exporter
func (s *ServiceProvider) SetXMLExporter(exporter exporters.SVDXMLExporter) {
	s.xmlExporter = exporter
}
