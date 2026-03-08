use serde::{Deserialize, Serialize};
use serde_json::Value;
use std::collections::BTreeMap;

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct StandardisedVesselDataset {
    #[serde(default)]
    pub general: Option<GeneralInformation>,
    #[serde(default)]
    pub port_and_route: Option<PortInformation>,
    #[serde(default)]
    pub emissions: Option<Emissions>,
    #[serde(flatten)]
    pub extra: BTreeMap<String, Value>,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct GeneralInformation {
    #[serde(default)]
    pub event_type: Option<String>,
    #[serde(default)]
    pub operation_type: Option<String>,
    #[serde(default)]
    pub operation_description: Option<String>,
    #[serde(default)]
    pub performance_report_type: Option<String>,
    #[serde(default)]
    pub elapsed_time: Option<Value>,
    #[serde(default)]
    pub ship_latitude: Option<f64>,
    #[serde(default)]
    pub ship_longitude: Option<f64>,
    #[serde(default)]
    pub ship_reporting_date: Option<String>,
    #[serde(default)]
    pub ship_flag_state: Option<String>,
    #[serde(default)]
    pub ship_registry_port_code: Option<String>,
    #[serde(default)]
    pub ship_registry_port_name: Option<String>,
    #[serde(default)]
    pub ship_name: Option<String>,
    #[serde(default)]
    pub imo: Option<String>,
    #[serde(default)]
    pub mmsi: Option<String>,
    #[serde(default)]
    pub ship_type: Option<String>,
    #[serde(default)]
    pub ship_type_marpol_annex_vi: Option<String>,
    #[serde(default)]
    pub number_of_passengers: Option<i64>,
    #[serde(default)]
    pub number_of_crew: Option<i64>,
    #[serde(default)]
    pub voyage_number: Option<String>,
    #[serde(default)]
    pub voyage_remarks: Option<String>,
    #[serde(default)]
    pub voyage_leg_identifier: Option<String>,
    #[serde(default)]
    pub voyage_leg_remarks: Option<String>,
    #[serde(flatten)]
    pub extra: BTreeMap<String, Value>,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct PortInformation {
    #[serde(default)]
    pub departure_port_code: Option<String>,
    #[serde(default)]
    pub departure_port_name: Option<String>,
    #[serde(default)]
    pub arrival_port_code: Option<String>,
    #[serde(default)]
    pub arrival_port_name: Option<String>,
    #[serde(default)]
    pub inbound_port_jurisdiction_code: Option<String>,
    #[serde(default)]
    pub outbound_port_jurisdiction_code: Option<String>,
    #[serde(default)]
    pub pilot_boarding_place_name: Option<String>,
    #[serde(default)]
    pub pilot_boarding_place_location: Option<String>,
    #[serde(default)]
    pub berth_name: Option<String>,
    #[serde(flatten)]
    pub extra: BTreeMap<String, Value>,
}

#[derive(Debug, Clone, Default, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
pub struct Emissions {
    #[serde(default)]
    pub total_co2: Option<f64>,
    #[serde(default)]
    pub total_co2_percentage: Option<f64>,
    #[serde(default)]
    pub total_co2_tank_to_wake: Option<f64>,
    #[serde(default)]
    pub total_co2_captured: Option<f64>,
    #[serde(default)]
    pub total_ch4: Option<f64>,
    #[serde(default)]
    pub total_ch4_converted_to_co2: Option<f64>,
    #[serde(default)]
    pub total_n2o: Option<f64>,
    #[serde(default)]
    pub total_n2o_converted_to_co2: Option<f64>,
    #[serde(default)]
    pub ch4_emission_conversion_factor: Option<f64>,
    #[serde(default)]
    pub n2o_emission_conversion_factor: Option<f64>,
    #[serde(flatten)]
    pub extra: BTreeMap<String, Value>,
}
