use serde_json::{json, Value};
use std::path::{Path, PathBuf};
use svd_rust::adapter::{run_request, AdapterRequest};

fn repo_root() -> PathBuf {
    Path::new(env!("CARGO_MANIFEST_DIR"))
        .join("../../..")
        .canonicalize()
        .expect("canonicalize repo root")
}

fn load_case(name: &str) -> Value {
    let path = repo_root().join("conformance").join("cases").join(name);
    let raw = std::fs::read_to_string(&path).unwrap_or_else(|err| panic!("read {path:?}: {err}"));
    serde_json::from_str(&raw).unwrap_or_else(|err| panic!("parse {path:?}: {err}"))
}

fn run_case(case: &Value, operations: &[&str]) -> Value {
    let request: AdapterRequest = serde_json::from_value(json!({
        "dataset": case["dataset"].clone(),
        "operations": operations,
    }))
    .expect("deserialize request");

    run_request(request).expect("adapter response")
}

#[test]
fn valid_core_case_matches_expected_assertions() {
    let case = load_case("valid_core.json");
    let response = run_case(
        &case,
        &["validate", "export_json", "export_xml", "export_csv"],
    );

    assert_eq!(response["results"]["validate"]["ok"], true);
    assert_eq!(response["results"]["validate"]["errors"], json!([]));
    assert_eq!(response["results"]["export_json"]["ok"], true);
    assert_eq!(response["results"]["export_xml"]["ok"], true);
    assert_eq!(response["results"]["export_csv"]["ok"], true);

    let json_export: Value = serde_json::from_str(
        response["results"]["export_json"]["data"]
            .as_str()
            .expect("json export payload"),
    )
    .expect("parse json export");

    assert_eq!(json_export["general"]["eventType"], "NOON");
    assert_eq!(json_export["general"]["operationType"], "SAILING");
    assert_eq!(json_export["general"]["shipName"], "MV Example");
    assert_eq!(json_export["general"]["imo"], "9876543");
    assert_eq!(
        json_export["general"]["shipReportingDate"],
        "2025-01-02T15:04:05Z"
    );
    assert_eq!(json_export["portAndRoute"]["departurePortCode"], "SGSIN");
    assert_eq!(json_export["portAndRoute"]["arrivalPortCode"], "NLRTM");
    assert_eq!(json_export["emissions"]["totalCo2"], 10.5);

    let xml_payload = response["results"]["export_xml"]["data"]
        .as_str()
        .expect("xml payload");
    assert!(xml_payload.contains("<EventType>NOON</EventType>"));
    assert!(xml_payload.contains("<OperationType>SAILING</OperationType>"));
    assert!(xml_payload.contains("<ShipName>MV Example</ShipName>"));
    assert!(xml_payload.contains("<Imo>9876543</Imo>"));
    assert!(xml_payload.contains("<ShipReportingDate>2025-01-02T15:04:05Z</ShipReportingDate>"));
    assert!(xml_payload.contains("<DeparturePortCode>SGSIN</DeparturePortCode>"));
    assert!(xml_payload.contains("<ArrivalPortCode>NLRTM</ArrivalPortCode>"));
    assert!(xml_payload.contains("<TotalCo2>10.5</TotalCo2>"));

    let csv_payload = response["results"]["export_csv"]["data"]
        .as_str()
        .expect("csv payload");
    let mut rows = csv::Reader::from_reader(csv_payload.as_bytes());
    let headers = rows
        .headers()
        .expect("csv headers")
        .iter()
        .map(ToOwned::to_owned)
        .collect::<Vec<_>>();
    let row = rows
        .records()
        .next()
        .expect("csv row")
        .expect("valid csv row")
        .iter()
        .map(ToOwned::to_owned)
        .collect::<Vec<_>>();

    let mut map = std::collections::HashMap::new();
    for (header, value) in headers.iter().zip(row.iter()) {
        let key = header.split('.').next_back().expect("short key");
        map.insert(key.to_string(), value.to_string());
    }

    assert_eq!(map.get("EventType"), Some(&"NOON".to_string()));
    assert_eq!(map.get("OperationType"), Some(&"SAILING".to_string()));
    assert_eq!(map.get("ShipName"), Some(&"MV Example".to_string()));
    assert_eq!(map.get("Imo"), Some(&"9876543".to_string()));
    assert_eq!(
        map.get("ShipReportingDate"),
        Some(&"2025-01-02T15:04:05.0000000Z".to_string())
    );
    assert_eq!(map.get("DeparturePortCode"), Some(&"SGSIN".to_string()));
    assert_eq!(map.get("ArrivalPortCode"), Some(&"NLRTM".to_string()));
    assert_eq!(map.get("TotalCo2"), Some(&"10.5".to_string()));
}

#[test]
fn invalid_general_case_fails_validation_and_exports() {
    let case = load_case("invalid_general.json");
    let response = run_case(
        &case,
        &["validate", "export_json", "export_xml", "export_csv"],
    );

    assert_eq!(response["results"]["validate"]["ok"], true);
    assert!(
        response["results"]["validate"]["errors"]
            .as_array()
            .expect("error array")
            .len()
            > 0
    );

    assert_eq!(response["results"]["export_json"]["ok"], false);
    assert_eq!(response["results"]["export_xml"]["ok"], false);
    assert_eq!(response["results"]["export_csv"]["ok"], false);
}

#[test]
fn benchmark_contract_is_complete() {
    let case = load_case("valid_core.json");
    let request: AdapterRequest = serde_json::from_value(json!({
        "dataset": case["dataset"].clone(),
        "operations": ["benchmark"],
        "benchmark": {
            "iterations": 5
        }
    }))
    .expect("benchmark request");

    let response = run_request(request).expect("benchmark response");
    assert_eq!(response["results"]["benchmark"]["ok"], true);
    assert_eq!(response["results"]["benchmark"]["iterations"], 5);

    let metrics = response["results"]["benchmark"]["metrics"]
        .as_object()
        .expect("metrics object");
    for op in ["validate", "export_json", "export_xml", "export_csv"] {
        assert!(metrics.contains_key(op));
    }
}
