use crate::model::{GeneralInformation, StandardisedVesselDataset};
use crate::validator::{format_validation_failure, validate};
use chrono::{DateTime, FixedOffset, Utc};
use serde::Serialize;
use serde_json::{Map, Value};

#[derive(Debug, Clone, Serialize)]
pub struct ExportContent {
    pub file_name: String,
    pub content_type: String,
    pub data: String,
}

pub fn export_json(
    dataset: &StandardisedVesselDataset,
    raw_dataset: &Value,
) -> Result<ExportContent, String> {
    validate_for_export(dataset)?;

    let data = serde_json::to_string_pretty(raw_dataset)
        .map_err(|err| format!("marshal raw dataset json: {err}"))?;

    Ok(ExportContent {
        file_name: generate_file_name("json", dataset.general.as_ref()),
        content_type: "application/json".to_string(),
        data,
    })
}

pub fn export_xml(
    dataset: &StandardisedVesselDataset,
    raw_dataset: &Value,
) -> Result<ExportContent, String> {
    validate_for_export(dataset)?;

    let Value::Object(root) = raw_dataset else {
        return Err("dataset must be a JSON object".to_string());
    };

    let mut out = String::new();
    out.push_str("<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n");
    out.push_str("<StandardisedVesselDataset>\n");
    append_xml_object_fields(&mut out, root, 1);
    out.push_str("</StandardisedVesselDataset>");

    Ok(ExportContent {
        file_name: generate_file_name("xml", dataset.general.as_ref()),
        content_type: "application/xml".to_string(),
        data: out,
    })
}

pub fn export_csv(
    dataset: &StandardisedVesselDataset,
    raw_dataset: &Value,
) -> Result<ExportContent, String> {
    validate_for_export(dataset)?;

    let Value::Object(root) = raw_dataset else {
        return Err("dataset must be a JSON object".to_string());
    };

    let mut headers = Vec::new();
    let mut values = Vec::new();
    flatten_csv(root, "", &mut headers, &mut values);

    if headers.is_empty() {
        return Err("dataset must contain at least one CSV-exportable field".to_string());
    }

    let mut writer = csv::Writer::from_writer(vec![]);
    writer
        .write_record(headers)
        .map_err(|err| format!("write csv header: {err}"))?;
    writer
        .write_record(values)
        .map_err(|err| format!("write csv values: {err}"))?;
    writer.flush().map_err(|err| format!("flush csv: {err}"))?;

    let data = String::from_utf8(
        writer
            .into_inner()
            .map_err(|err| format!("finish csv writer: {err}"))?,
    )
    .map_err(|err| format!("decode csv bytes: {err}"))?;

    Ok(ExportContent {
        file_name: generate_file_name("csv", dataset.general.as_ref()),
        content_type: "text/csv".to_string(),
        data,
    })
}

fn append_xml_object_fields(out: &mut String, object: &Map<String, Value>, indent: usize) {
    for (key, value) in object {
        let tag = to_pascal_token(key);
        append_xml_value(out, &tag, value, indent);
    }
}

fn append_xml_value(out: &mut String, tag: &str, value: &Value, indent: usize) {
    match value {
        Value::Null => {}
        Value::Object(map) => {
            if map.is_empty() {
                return;
            }
            indent_line(out, indent);
            out.push('<');
            out.push_str(tag);
            out.push_str(">\n");
            append_xml_object_fields(out, map, indent + 1);
            indent_line(out, indent);
            out.push_str("</");
            out.push_str(tag);
            out.push_str(">\n");
        }
        _ => {
            indent_line(out, indent);
            out.push('<');
            out.push_str(tag);
            out.push('>');
            out.push_str(&xml_escape(&format_xml_primitive(value)));
            out.push_str("</");
            out.push_str(tag);
            out.push_str(">\n");
        }
    }
}

fn indent_line(out: &mut String, indent: usize) {
    for _ in 0..indent {
        out.push_str("  ");
    }
}

fn flatten_csv(
    object: &Map<String, Value>,
    prefix: &str,
    headers: &mut Vec<String>,
    values: &mut Vec<String>,
) {
    for (key, value) in object {
        let token = to_pascal_token(key);
        let path = if prefix.is_empty() {
            token
        } else {
            format!("{prefix}.{token}")
        };

        match value {
            Value::Null => {}
            Value::Object(map) => flatten_csv(map, &path, headers, values),
            _ => {
                headers.push(path.clone());
                values.push(format_csv_primitive(&path, value));
            }
        }
    }
}

fn format_xml_primitive(value: &Value) -> String {
    match value {
        Value::Bool(v) => {
            if *v {
                "true".to_string()
            } else {
                "false".to_string()
            }
        }
        Value::Number(n) => n.to_string(),
        Value::String(s) => s.clone(),
        _ => value.to_string(),
    }
}

fn format_csv_primitive(path: &str, value: &Value) -> String {
    match value {
        Value::Bool(v) => {
            if *v {
                "True".to_string()
            } else {
                "False".to_string()
            }
        }
        Value::Number(n) => n.to_string(),
        Value::String(s) => {
            if path.ends_with("ShipReportingDate") {
                return format_dotnet_datetime(Some(s));
            }
            s.clone()
        }
        _ => value.to_string(),
    }
}

fn to_pascal_token(input: &str) -> String {
    let mut chars = input.chars();
    let Some(first) = chars.next() else {
        return String::new();
    };

    let mut out = String::new();
    out.extend(first.to_uppercase());
    out.extend(chars);
    out
}

fn validate_for_export(dataset: &StandardisedVesselDataset) -> Result<(), String> {
    let errors = validate(Some(dataset));
    if errors.is_empty() {
        Ok(())
    } else {
        Err(format_validation_failure(&errors))
    }
}

fn generate_file_name(ext: &str, general: Option<&GeneralInformation>) -> String {
    let date = general
        .and_then(|g| g.ship_reporting_date.as_deref())
        .and_then(filename_date)
        .unwrap_or_else(current_utc_date);

    if let Some(imo) = general.and_then(|g| g.imo.as_deref()).map(str::trim) {
        if !imo.is_empty() {
            return format!("SVD_{}_{}.{}", imo, date, ext);
        }
    }

    format!("SVD_{}.{}", date, ext)
}

fn filename_date(raw: &str) -> Option<String> {
    DateTime::<FixedOffset>::parse_from_rfc3339(raw)
        .ok()
        .map(|dt| dt.with_timezone(&Utc).format("%Y-%m-%d").to_string())
}

fn current_utc_date() -> String {
    Utc::now().format("%Y-%m-%d").to_string()
}

fn format_dotnet_datetime(raw: Option<&str>) -> String {
    let Some(raw) = raw else {
        return String::new();
    };

    let trimmed = raw.trim();
    if trimmed.is_empty() {
        return String::new();
    }

    match DateTime::<FixedOffset>::parse_from_rfc3339(trimmed) {
        Ok(parsed) => {
            let utc = parsed.with_timezone(&Utc);
            let ticks = utc.timestamp_subsec_nanos() / 100;
            format!("{}.{:07}Z", utc.format("%Y-%m-%dT%H:%M:%S"), ticks)
        }
        Err(_) => trimmed.to_string(),
    }
}

fn xml_escape(input: &str) -> String {
    input
        .replace('&', "&amp;")
        .replace('<', "&lt;")
        .replace('>', "&gt;")
        .replace('"', "&quot;")
        .replace('\'', "&apos;")
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::model::StandardisedVesselDataset;
    use serde_json::json;

    fn valid_fixture() -> (StandardisedVesselDataset, Value) {
        let raw = json!({
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
        });

        let model: StandardisedVesselDataset =
            serde_json::from_value(raw.clone()).expect("valid model");
        (model, raw)
    }

    #[test]
    fn exports_json_with_raw_dataset_content() {
        let (model, raw) = valid_fixture();
        let out = export_json(&model, &raw).expect("json export");
        let payload: Value = serde_json::from_str(&out.data).expect("json parse");
        assert_eq!(payload["general"]["eventType"], "NOON");
    }

    #[test]
    fn exports_xml_dynamic_paths() {
        let (model, raw) = valid_fixture();
        let out = export_xml(&model, &raw).expect("xml export");
        assert!(out.data.contains("<EventType>NOON</EventType>"));
        assert!(out
            .data
            .contains("<ArrivalPortCode>NLRTM</ArrivalPortCode>"));
    }

    #[test]
    fn exports_csv_dynamic_fields() {
        let (model, raw) = valid_fixture();
        let out = export_csv(&model, &raw).expect("csv export");
        assert!(out.data.contains("General.ShipReportingDate"));
        assert!(out.data.contains("2025-01-02T15:04:05.0000000Z"));
    }
}
