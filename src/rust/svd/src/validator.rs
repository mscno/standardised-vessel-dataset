use crate::model::{GeneralInformation, StandardisedVesselDataset};
use chrono::{DateTime, Datelike, FixedOffset};
use serde::Serialize;

#[derive(Debug, Clone, PartialEq, Eq, Serialize)]
pub struct ValidationIssue {
    pub field: String,
    pub message: String,
}

pub fn validate(dataset: Option<&StandardisedVesselDataset>) -> Vec<ValidationIssue> {
    let Some(dataset) = dataset else {
        return vec![ValidationIssue {
            field: "SVD".to_string(),
            message: "SVD cannot be nil".to_string(),
        }];
    };

    let Some(general) = dataset.general.as_ref() else {
        return vec![ValidationIssue {
            field: "General".to_string(),
            message: "General is required".to_string(),
        }];
    };

    validate_general(general)
}

fn validate_general(general: &GeneralInformation) -> Vec<ValidationIssue> {
    let mut errors = Vec::new();

    let imo = general.imo.as_deref().unwrap_or("").trim();
    if imo.is_empty() {
        errors.push(ValidationIssue {
            field: "General.Imo".to_string(),
            message: "Imo is required".to_string(),
        });
    }

    if !is_seven_digit_imo(imo) {
        errors.push(ValidationIssue {
            field: "General.Imo".to_string(),
            message: "Imo must be seven digits.".to_string(),
        });
    }

    let ship_name = general.ship_name.as_deref().unwrap_or("").trim();
    if ship_name.is_empty() {
        errors.push(ValidationIssue {
            field: "General.ShipName".to_string(),
            message: "Ship Name is required".to_string(),
        });
    }

    let report_date_raw = general.ship_reporting_date.as_deref();
    if report_date_missing_or_default(report_date_raw) {
        errors.push(ValidationIssue {
            field: "General.ShipReportingDate".to_string(),
            message: "Ship Reporting Date (Datetime) must be greater than default.".to_string(),
        });
    }

    errors
}

fn is_seven_digit_imo(value: &str) -> bool {
    value.chars().count() == 7 && value.chars().all(|ch| ch.is_ascii_digit())
}

fn report_date_missing_or_default(raw: Option<&str>) -> bool {
    let Some(raw) = raw else {
        return true;
    };

    let value = raw.trim();
    if value.is_empty() {
        return true;
    }

    if value == "0001-01-01T00:00:00Z" {
        return true;
    }

    match DateTime::<FixedOffset>::parse_from_rfc3339(value) {
        Ok(parsed) => parsed.year() <= 1,
        Err(_) => true,
    }
}

pub fn format_validation_failure(errors: &[ValidationIssue]) -> String {
    if errors.is_empty() {
        return "Validation failed".to_string();
    }

    let mut out = String::from("Validation failed:\n");
    for error in errors {
        out.push_str(" -- ");
        out.push_str(&error.field);
        out.push_str(": ");
        out.push_str(&error.message);
        out.push_str(";\n");
    }

    out.trim_end().to_string()
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::model::{GeneralInformation, StandardisedVesselDataset};

    #[test]
    fn validates_nil_dataset() {
        let errors = validate(None);
        assert_eq!(errors.len(), 1);
        assert_eq!(errors[0].field, "SVD");
    }

    #[test]
    fn validates_general_rules() {
        let dataset = StandardisedVesselDataset {
            general: Some(GeneralInformation {
                imo: Some("".to_string()),
                ship_name: Some("".to_string()),
                ship_reporting_date: Some("0001-01-01T00:00:00Z".to_string()),
                ..Default::default()
            }),
            ..Default::default()
        };

        let errors = validate(Some(&dataset));
        assert!(errors.len() >= 3);
    }

    #[test]
    fn validates_non_numeric_imo() {
        let dataset = StandardisedVesselDataset {
            general: Some(GeneralInformation {
                imo: Some("12A4567".to_string()),
                ship_name: Some("MV Example".to_string()),
                ship_reporting_date: Some("2025-01-02T15:04:05Z".to_string()),
                ..Default::default()
            }),
            ..Default::default()
        };

        let errors = validate(Some(&dataset));
        assert!(errors.iter().any(|error| {
            error.field == "General.Imo" && error.message == "Imo must be seven digits."
        }));
    }
}
