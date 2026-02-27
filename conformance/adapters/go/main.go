package main

import (
	"context"
	"encoding/json"
	"fmt"
	"os"
	"strings"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters"
	csvexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/csv"
	jsonexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/json"
	xmlexporter "github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/exporters/formats/xml"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/validators"
)

type benchmarkConfig struct {
	Iterations int `json:"iterations"`
}

type adapterRequest struct {
	Dataset    json.RawMessage `json:"dataset"`
	Operations []string        `json:"operations"`
	Benchmark  benchmarkConfig `json:"benchmark"`
}

type validationIssue struct {
	Field   string `json:"field"`
	Message string `json:"message"`
}

type validateResult struct {
	Ok     bool              `json:"ok"`
	Errors []validationIssue `json:"errors,omitempty"`
	Error  string            `json:"error,omitempty"`
}

type exportResult struct {
	Ok          bool   `json:"ok"`
	FileName    string `json:"file_name,omitempty"`
	ContentType string `json:"content_type,omitempty"`
	Data        string `json:"data,omitempty"`
	Error       string `json:"error,omitempty"`
}

type benchmarkMetric struct {
	TotalMS    float64 `json:"total_ms"`
	AvgMS      float64 `json:"avg_ms"`
	ErrorCount int     `json:"error_count"`
}

type benchmarkResult struct {
	Ok         bool                       `json:"ok"`
	Iterations int                        `json:"iterations,omitempty"`
	Metrics    map[string]benchmarkMetric `json:"metrics,omitempty"`
	Error      string                     `json:"error,omitempty"`
}

type adapterResponse struct {
	Implementation string         `json:"implementation"`
	Results        map[string]any `json:"results"`
	Error          string         `json:"error,omitempty"`
}

func shouldRun(ops []string, operation string) bool {
	if len(ops) == 0 {
		return true
	}
	for _, op := range ops {
		if strings.EqualFold(op, operation) {
			return true
		}
	}
	return false
}

func validateSVD(validator validators.SVDValidator, svd *models.StandardisedVesselDataset) validateResult {
	errs := validator.Validate(svd)
	issues := make([]validationIssue, 0, len(errs))
	for _, err := range errs {
		issues = append(issues, validationIssue{Field: err.Field, Message: err.Message})
	}
	return validateResult{Ok: true, Errors: issues}
}

func runExport(
	exporter exporters.SVDExporter,
	svd *models.StandardisedVesselDataset,
	fallbackContentType string,
) exportResult {
	result, err := exporter.ExportAsync(context.Background(), svd)
	if err != nil {
		return exportResult{Ok: false, Error: err.Error()}
	}

	contentType := result.ContentType
	if contentType == "" {
		contentType = fallbackContentType
	}

	return exportResult{
		Ok:          true,
		FileName:    result.FileName,
		ContentType: contentType,
		Data:        string(result.Data),
	}
}

func timeLoop(iterations int, fn func() error) benchmarkMetric {
	start := time.Now()
	errorCount := 0
	for i := 0; i < iterations; i++ {
		if err := fn(); err != nil {
			errorCount++
		}
	}
	total := time.Since(start)
	return benchmarkMetric{
		TotalMS:    float64(total.Microseconds()) / 1000.0,
		AvgMS:      (float64(total.Microseconds()) / 1000.0) / float64(iterations),
		ErrorCount: errorCount,
	}
}

func runBenchmark(
	iterations int,
	svd *models.StandardisedVesselDataset,
	validator validators.SVDValidator,
	jsonExp exporters.SVDJSONExporter,
	xmlExp exporters.SVDXMLExporter,
	csvExp exporters.SVDCSVExporter,
) benchmarkResult {
	if svd == nil {
		return benchmarkResult{Ok: false, Error: "svd cannot be nil"}
	}

	if iterations <= 0 {
		iterations = 100
	}

	metrics := map[string]benchmarkMetric{}

	metrics["validate"] = timeLoop(iterations, func() error {
		_ = validator.Validate(svd)
		return nil
	})

	metrics["export_json"] = timeLoop(iterations, func() error {
		_, err := jsonExp.ExportAsync(context.Background(), svd)
		return err
	})

	metrics["export_xml"] = timeLoop(iterations, func() error {
		_, err := xmlExp.ExportAsync(context.Background(), svd)
		return err
	})

	metrics["export_csv"] = timeLoop(iterations, func() error {
		_, err := csvExp.ExportAsync(context.Background(), svd)
		return err
	})

	return benchmarkResult{Ok: true, Iterations: iterations, Metrics: metrics}
}

func main() {
	decoder := json.NewDecoder(os.Stdin)
	var req adapterRequest
	if err := decoder.Decode(&req); err != nil {
		writeResponse(adapterResponse{Implementation: "go", Results: map[string]any{}, Error: fmt.Sprintf("invalid request: %v", err)})
		os.Exit(1)
	}

	var svd *models.StandardisedVesselDataset
	if len(req.Dataset) > 0 && strings.TrimSpace(string(req.Dataset)) != "null" {
		if err := json.Unmarshal(req.Dataset, &svd); err != nil {
			writeResponse(adapterResponse{Implementation: "go", Results: map[string]any{}, Error: fmt.Sprintf("invalid dataset: %v", err)})
			os.Exit(1)
		}
	}

	validator := validators.NewStandardisedVesselDatasetValidator()
	jsonExp := jsonexporter.NewJSONExporter(validator)
	xmlExp := xmlexporter.NewXMLExporter(validator)
	csvExp := csvexporter.NewCSVExporter(validator)

	resp := adapterResponse{Implementation: "go", Results: map[string]any{}}

	if shouldRun(req.Operations, "validate") {
		resp.Results["validate"] = validateSVD(validator, svd)
	}

	if shouldRun(req.Operations, "export_json") {
		resp.Results["export_json"] = runExport(jsonExp, svd, "application/json")
	}

	if shouldRun(req.Operations, "export_xml") {
		resp.Results["export_xml"] = runExport(xmlExp, svd, "application/xml")
	}

	if shouldRun(req.Operations, "export_csv") {
		resp.Results["export_csv"] = runExport(csvExp, svd, "text/csv")
	}

	if shouldRun(req.Operations, "benchmark") {
		resp.Results["benchmark"] = runBenchmark(req.Benchmark.Iterations, svd, validator, jsonExp, xmlExp, csvExp)
	}

	writeResponse(resp)
}

func writeResponse(resp adapterResponse) {
	encoder := json.NewEncoder(os.Stdout)
	encoder.SetEscapeHTML(false)
	if err := encoder.Encode(resp); err != nil {
		fmt.Fprintf(os.Stderr, "failed to write adapter response: %v\n", err)
		os.Exit(1)
	}
}
