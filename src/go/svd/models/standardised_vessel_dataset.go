package models

import "encoding/xml"

// StandardisedVesselDataset represents the Standardised Vessel Dataset (SVD).
type StandardisedVesselDataset struct {
	XMLName                xml.Name                    `json:"-" xml:"StandardisedVesselDataset" csv:"-"`
	General                *GeneralInformation         `json:"general" xml:"General" csv:"General"`
	PortAndRoute           *PortInformation            `json:"portAndRoute" xml:"PortAndRoute" csv:"PortAndRoute"`
	ArrivalTimes           *ArrivalTimes               `json:"arrivalTimes" xml:"ArrivalTimes" csv:"ArrivalTimes"`
	DeviationFromPlanned   *DeviationFromPlanned       `json:"deviationFromPlanned" xml:"DeviationFromPlanned" csv:"DeviationFromPlanned"`
	SpeedAndDistance       *SpeedAndDistance           `json:"speedAndDistance" xml:"SpeedAndDistance" csv:"SpeedAndDistance"`
	Weather                *WeatherInformation         `json:"weather" xml:"Weather" csv:"Weather"`
	FreshWater             *FreshWater                 `json:"freshWater" xml:"FreshWater" csv:"FreshWater"`
	ElectricityConsumption *ElectricityConsumption     `json:"electricityConsumption" xml:"ElectricityConsumption" csv:"ElectricityConsumption"`
	Cargo                  *CargoInformation           `json:"cargo" xml:"Cargo" csv:"Cargo"`
	FuelAndBunker          *FuelAndBunkerInformation   `json:"fuelAndBunker" xml:"FuelAndBunker" csv:"FuelAndBunker"`
	Emissions              *Emissions                  `json:"emissions" xml:"Emissions" csv:"Emissions"`
	CylinderLubeOil        *CylinderLubeOilInformation `json:"cylinderLubeOil" xml:"CylinderLubeOil" csv:"CylinderLubeOil"`
}
