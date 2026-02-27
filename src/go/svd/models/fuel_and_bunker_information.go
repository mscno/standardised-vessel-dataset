package models

import "time"

// FuelAndBunkerInformation represents the "Fuel and Bunker" section of SVD.
type FuelAndBunkerInformation struct {
	FuelType                               string    `json:"fuelType" xml:"FuelType" csv:"FuelType"`
	FuelTypeTradeName                      string    `json:"fuelTypeTradeName" xml:"FuelTypeTradeName" csv:"FuelTypeTradeName"`
	BunkerDeliveryNoteNumber               string    `json:"bunkerDeliveryNoteNumber" xml:"BunkerDeliveryNoteNumber" csv:"BunkerDeliveryNoteNumber"`
	BunkerDeliveryDateTime                 time.Time `json:"bunkerDeliveryDateTime" xml:"BunkerDeliveryDateTime" csv:"BunkerDeliveryDateTime"`
	FuelProofOfSustainabilityReference     string    `json:"fuelProofOfSustainabilityReference" xml:"FuelProofOfSustainabilityReference" csv:"FuelProofOfSustainabilityReference"`
	FuelBunkered                           float64   `json:"fuelBunkered" xml:"FuelBunkered" csv:"FuelBunkered"`
	FuelMass                               float64   `json:"fuelMass" xml:"FuelMass" csv:"FuelMass"`
	FuelDensity                            float64   `json:"fuelDensity" xml:"FuelDensity" csv:"FuelDensity"`
	FuelSulphurContent                     float64   `json:"fuelSulphurContent" xml:"FuelSulphurContent" csv:"FuelSulphurContent"`
	FuelViscosity                          float64   `json:"fuelViscosity" xml:"FuelViscosity" csv:"FuelViscosity"`
	FuelWaterContent                       float64   `json:"fuelWaterContent" xml:"FuelWaterContent" csv:"FuelWaterContent"`
	FuelHigherHeatingValue                 float64   `json:"fuelHigherHeatingValue" xml:"FuelHigherHeatingValue" csv:"FuelHigherHeatingValue"`
	FuelLowerHeatingValue                  float64   `json:"fuelLowerHeatingValue" xml:"FuelLowerHeatingValue" csv:"FuelLowerHeatingValue"`
	FuelCalorificValueReportingSchemeCode  string    `json:"fuelCalorificValueReportingSchemeCode" xml:"FuelCalorificValueReportingSchemeCode" csv:"FuelCalorificValueReportingSchemeCode"`
	FuelLowerCalorificValue                float64   `json:"fuelLowerCalorificValue" xml:"FuelLowerCalorificValue" csv:"FuelLowerCalorificValue"`
	FuelGrade                              string    `json:"fuelGrade" xml:"FuelGrade" csv:"FuelGrade"`
	FuelGHGIntensityIMOManual              float64   `json:"fuelGHGIntensityIMOManual" xml:"FuelGHGIntensityIMOManual" csv:"FuelGHGIntensityIMOManual"`
	FuelGHGIntensityIMOVoyage              float64   `json:"fuelGHGIntensityIMOVoyage" xml:"FuelGHGIntensityIMOVoyage" csv:"FuelGHGIntensityIMOVoyage"`
	FuelBunkerPort                         string    `json:"fuelBunkerPort" xml:"FuelBunkerPort" csv:"FuelBunkerPort"`
	FuelBunkerPortName                     string    `json:"fuelBunkerPortName" xml:"FuelBunkerPortName" csv:"FuelBunkerPortName"`
	FuelCarbonDioxideEmission              float64   `json:"fuelCarbonDioxideEmission" xml:"FuelCarbonDioxideEmission" csv:"FuelCarbonDioxideEmission"`
	TotalFuelConsumed                      float64   `json:"totalFuelConsumed" xml:"TotalFuelConsumed" csv:"TotalFuelConsumed"`
	FuelConsumedByMainEngine               float64   `json:"fuelConsumedByMainEngine" xml:"FuelConsumedByMainEngine" csv:"FuelConsumedByMainEngine"`
	FuelConsumedByDieselElectricPropulsion float64   `json:"fuelConsumedByDieselElectricPropulsion" xml:"FuelConsumedByDieselElectricPropulsion" csv:"FuelConsumedByDieselElectricPropulsion"`
	FuelConsumedByDieselGenerator          float64   `json:"fuelConsumedByDieselGenerator" xml:"FuelConsumedByDieselGenerator" csv:"FuelConsumedByDieselGenerator"`
	FuelConsumedByAuxiliaryBoiler          float64   `json:"fuelConsumedByAuxiliaryBoiler" xml:"FuelConsumedByAuxiliaryBoiler" csv:"FuelConsumedByAuxiliaryBoiler"`
	FuelConsumedByAuxiliaryEngine          float64   `json:"fuelConsumedByAuxiliaryEngine" xml:"FuelConsumedByAuxiliaryEngine" csv:"FuelConsumedByAuxiliaryEngine"`
	FuelConsumedByCargoHeating             float64   `json:"fuelConsumedByCargoHeating" xml:"FuelConsumedByCargoHeating" csv:"FuelConsumedByCargoHeating"`
	FuelConsumedByReeferContainers         float64   `json:"fuelConsumedByReeferContainers" xml:"FuelConsumedByReeferContainers" csv:"FuelConsumedByReeferContainers"`
	FuelConsumedByDischargePump            float64   `json:"fuelConsumedByDischargePump" xml:"FuelConsumedByDischargePump" csv:"FuelConsumedByDischargePump"`
	FuelConsumedByOtherDevices             float64   `json:"fuelConsumedByOtherDevices" xml:"FuelConsumedByOtherDevices" csv:"FuelConsumedByOtherDevices"`
	FuelRemainingOnBoard                   float64   `json:"fuelRemainingOnBoard" xml:"FuelRemainingOnBoard" csv:"FuelRemainingOnBoard"`
	SludgeRemainingOnBoard                 float64   `json:"sludgeRemainingOnBoard" xml:"SludgeRemainingOnBoard" csv:"SludgeRemainingOnBoard"`
}
