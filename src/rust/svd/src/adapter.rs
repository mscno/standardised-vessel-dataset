use crate::exporters::{export_csv, export_json, export_xml};
use crate::model::StandardisedVesselDataset;
use crate::validator::{validate, ValidationIssue};
use serde::{Deserialize, Serialize};
use serde_json::{Map, Value};
use std::io::{self, Read};
use std::time::Instant;

#[derive(Debug, Deserialize)]
pub struct AdapterRequest {
    #[serde(default)]
    dataset: Option<Value>,
    #[serde(default)]
    operations: Vec<String>,
    #[serde(default)]
    benchmark: BenchmarkConfig,
}

#[derive(Debug, Default, Deserialize)]
struct BenchmarkConfig {
    #[serde(default)]
    iterations: Option<usize>,
}

#[derive(Debug, Clone)]
struct ParsedDataset {
    model: StandardisedVesselDataset,
    raw: Value,
}

#[derive(Debug, Serialize)]
struct AdapterResponse {
    implementation: &'static str,
    results: Map<String, Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

#[derive(Debug, Serialize)]
struct ValidateResult {
    ok: bool,
    errors: Vec<ValidationIssue>,
}

#[derive(Debug, Serialize)]
struct ExportResult {
    ok: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    file_name: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    content_type: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    data: Option<String>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

#[derive(Debug, Serialize)]
struct BenchmarkMetric {
    total_ms: f64,
    avg_ms: f64,
    error_count: usize,
}

#[derive(Debug, Serialize)]
struct BenchmarkResult {
    ok: bool,
    iterations: usize,
    metrics: Map<String, Value>,
    #[serde(skip_serializing_if = "Option::is_none")]
    error: Option<String>,
}

pub fn run_from_stdin() -> i32 {
    let mut raw = String::new();
    if io::stdin().read_to_string(&mut raw).is_err() {
        write_response(AdapterResponse {
            implementation: "rust",
            results: Map::new(),
            error: Some("failed to read stdin".to_string()),
        });
        return 1;
    }

    if raw.trim().is_empty() {
        write_response(AdapterResponse {
            implementation: "rust",
            results: Map::new(),
            error: Some("empty request".to_string()),
        });
        return 1;
    }

    let request: AdapterRequest = match serde_json::from_str(&raw) {
        Ok(request) => request,
        Err(err) => {
            write_response(AdapterResponse {
                implementation: "rust",
                results: Map::new(),
                error: Some(format!("invalid request: {err}")),
            });
            return 1;
        }
    };

    match run_request(request) {
        Ok(response) => {
            write_response(response);
            0
        }
        Err(message) => {
            write_response(AdapterResponse {
                implementation: "rust",
                results: Map::new(),
                error: Some(message),
            });
            1
        }
    }
}

pub fn run_request(request: AdapterRequest) -> Result<Value, String> {
    let dataset = parse_dataset(request.dataset)?;

    let mut results = Map::new();

    if should_run(&request.operations, "validate") {
        let errors = validate(dataset.as_ref().map(|d| &d.model));
        insert_json(
            &mut results,
            "validate",
            &ValidateResult { ok: true, errors },
        )?;
    }

    if should_run(&request.operations, "export_json") {
        let result = run_export(dataset.as_ref(), export_json);
        insert_json(&mut results, "export_json", &result)?;
    }

    if should_run(&request.operations, "export_xml") {
        let result = run_export(dataset.as_ref(), export_xml);
        insert_json(&mut results, "export_xml", &result)?;
    }

    if should_run(&request.operations, "export_csv") {
        let result = run_export(dataset.as_ref(), export_csv);
        insert_json(&mut results, "export_csv", &result)?;
    }

    if should_run(&request.operations, "benchmark") {
        let result = run_benchmark(
            dataset.as_ref(),
            request.benchmark.iterations.unwrap_or(100),
        );
        insert_json(&mut results, "benchmark", &result)?;
    }

    serde_json::to_value(AdapterResponse {
        implementation: "rust",
        results,
        error: None,
    })
    .map_err(|err| format!("serialize adapter response: {err}"))
}

fn parse_dataset(dataset: Option<Value>) -> Result<Option<ParsedDataset>, String> {
    let Some(raw) = dataset else {
        return Ok(None);
    };

    if raw.is_null() {
        return Ok(None);
    }

    let model: StandardisedVesselDataset =
        serde_json::from_value(raw.clone()).map_err(|err| format!("invalid dataset: {err}"))?;

    Ok(Some(ParsedDataset { model, raw }))
}

fn should_run(operations: &[String], operation: &str) -> bool {
    operations.is_empty()
        || operations
            .iter()
            .any(|candidate| candidate.eq_ignore_ascii_case(operation))
}

fn run_export<F>(dataset: Option<&ParsedDataset>, export_fn: F) -> ExportResult
where
    F: Fn(&StandardisedVesselDataset, &Value) -> Result<crate::exporters::ExportContent, String>,
{
    let Some(dataset) = dataset else {
        return ExportResult {
            ok: false,
            file_name: None,
            content_type: None,
            data: None,
            error: Some("svd cannot be nil".to_string()),
        };
    };

    match export_fn(&dataset.model, &dataset.raw) {
        Ok(content) => ExportResult {
            ok: true,
            file_name: Some(content.file_name),
            content_type: Some(content.content_type),
            data: Some(content.data),
            error: None,
        },
        Err(error) => ExportResult {
            ok: false,
            file_name: None,
            content_type: None,
            data: None,
            error: Some(error),
        },
    }
}

fn run_benchmark(dataset: Option<&ParsedDataset>, iterations: usize) -> BenchmarkResult {
    let Some(dataset) = dataset else {
        return BenchmarkResult {
            ok: false,
            iterations: 0,
            metrics: Map::new(),
            error: Some("svd cannot be nil".to_string()),
        };
    };

    let iterations = if iterations == 0 { 100 } else { iterations };

    let mut metrics = Map::new();

    let validate_metric = time_loop(iterations, || {
        let _ = validate(Some(&dataset.model));
        Ok(())
    });
    let json_metric = time_loop(iterations, || {
        export_json(&dataset.model, &dataset.raw).map(|_| ())
    });
    let xml_metric = time_loop(iterations, || {
        export_xml(&dataset.model, &dataset.raw).map(|_| ())
    });
    let csv_metric = time_loop(iterations, || {
        export_csv(&dataset.model, &dataset.raw).map(|_| ())
    });

    let _ = insert_json(&mut metrics, "validate", &validate_metric);
    let _ = insert_json(&mut metrics, "export_json", &json_metric);
    let _ = insert_json(&mut metrics, "export_xml", &xml_metric);
    let _ = insert_json(&mut metrics, "export_csv", &csv_metric);

    BenchmarkResult {
        ok: true,
        iterations,
        metrics,
        error: None,
    }
}

fn time_loop<F>(iterations: usize, mut op: F) -> BenchmarkMetric
where
    F: FnMut() -> Result<(), String>,
{
    let start = Instant::now();
    let mut error_count = 0;

    for _ in 0..iterations {
        if op().is_err() {
            error_count += 1;
        }
    }

    let total_ms = start.elapsed().as_secs_f64() * 1000.0;
    let avg_ms = total_ms / iterations as f64;

    BenchmarkMetric {
        total_ms,
        avg_ms,
        error_count,
    }
}

fn insert_json<T: Serialize>(
    map: &mut Map<String, Value>,
    key: &str,
    value: &T,
) -> Result<(), String> {
    let json = serde_json::to_value(value).map_err(|err| format!("serialize {key}: {err}"))?;
    map.insert(key.to_string(), json);
    Ok(())
}

fn write_response<T: Serialize>(response: T) {
    match serde_json::to_string(&response) {
        Ok(payload) => {
            println!("{payload}");
        }
        Err(err) => {
            println!(
                "{{\"implementation\":\"rust\",\"results\":{{}},\"error\":\"failed to serialize response: {}\"}}",
                err
            );
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::json;

    fn valid_request() -> AdapterRequest {
        serde_json::from_value(json!({
            "dataset": {
                "general": {
                    "eventType": "NOON",
                    "operationType": "SAILING",
                    "shipName": "MV Example",
                    "imo": "9876543",
                    "shipReportingDate": "2025-01-02T15:04:05Z"
                },
                "portAndRoute": {
                    "departurePortCode": "SGSIN",
                    "arrivalPortCode": "NLRTM"
                },
                "emissions": {
                    "totalCo2": 10.5
                }
            },
            "operations": ["validate", "export_json", "export_xml", "export_csv", "benchmark"],
            "benchmark": {
                "iterations": 3
            }
        }))
        .expect("valid adapter request")
    }

    #[test]
    fn runs_all_operations() {
        let response = run_request(valid_request()).expect("adapter response");
        let results = response["results"].as_object().expect("results object");

        assert!(results.contains_key("validate"));
        assert!(results.contains_key("export_json"));
        assert!(results.contains_key("export_xml"));
        assert!(results.contains_key("export_csv"));
        assert!(results.contains_key("benchmark"));
        assert_eq!(response["implementation"], "rust");
    }

    #[test]
    fn exports_fail_for_invalid_dataset() {
        let request: AdapterRequest = serde_json::from_value(json!({
            "dataset": {
                "general": {
                    "imo": "",
                    "shipName": "",
                    "shipReportingDate": "0001-01-01T00:00:00Z"
                }
            },
            "operations": ["export_json"]
        }))
        .expect("invalid dataset request");

        let response = run_request(request).expect("adapter response");
        assert_eq!(response["results"]["export_json"]["ok"], false);
    }
}
