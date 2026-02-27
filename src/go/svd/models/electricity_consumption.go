package models

// ElectricityConsumption represents the "Electricity Consumption" section of SVD.
type ElectricityConsumption struct {
	BoilerElectricityConsumption            float64 `json:"boilerElectricityConsumption" xml:"BoilerElectricityConsumption" csv:"BoilerElectricityConsumption"`
	GeneratorProduction                     float64 `json:"generatorProduction" xml:"GeneratorProduction" csv:"GeneratorProduction"`
	OffsetElectricityConsumption            float64 `json:"offsetElectricityConsumption" xml:"OffsetElectricityConsumption" csv:"OffsetElectricityConsumption"`
	PowerConsumptionForPlant                float64 `json:"powerConsumptionForPlant" xml:"PowerConsumptionForPlant" csv:"PowerConsumptionForPlant"`
	ElectricalForCargoCooling               float64 `json:"electricalForCargoCooling" xml:"ElectricalForCargoCooling" csv:"ElectricalForCargoCooling"`
	ElectricalForDischargePump              float64 `json:"electricalForDischargePump" xml:"ElectricalForDischargePump" csv:"ElectricalForDischargePump"`
	ElectricalForReeferContainers           float64 `json:"electricalForReeferContainers" xml:"ElectricalForReeferContainers" csv:"ElectricalForReeferContainers"`
	ElectricalFromOnShorePowerSupply        float64 `json:"electricalFromOnShorePowerSupply" xml:"ElectricalFromOnShorePowerSupply" csv:"ElectricalFromOnShorePowerSupply"`
	ElectricalFromZeroEmissionsTechnologies float64 `json:"electricalFromZeroEmissionsTechnologies" xml:"ElectricalFromZeroEmissionsTechnologies" csv:"ElectricalFromZeroEmissionsTechnologies"`
	FuelTypeUsedForCargoCooling             string  `json:"fuelTypeUsedForCargoCooling" xml:"FuelTypeUsedForCargoCooling" csv:"FuelTypeUsedForCargoCooling"`
	FuelTypeUsedForDischargePump            string  `json:"fuelTypeUsedForDischargePump" xml:"FuelTypeUsedForDischargePump" csv:"FuelTypeUsedForDischargePump"`
	FuelTypeUsedForReeferContainers         string  `json:"fuelTypeUsedForReeferContainers" xml:"FuelTypeUsedForReeferContainers" csv:"FuelTypeUsedForReeferContainers"`
	FuelOilConsumptionForCargoCooling       float64 `json:"fuelOilConsumptionForCargoCooling" xml:"FuelOilConsumptionForCargoCooling" csv:"FuelOilConsumptionForCargoCooling"`
	FuelOilConsumptionForDischargePump      float64 `json:"fuelOilConsumptionForDischargePump" xml:"FuelOilConsumptionForDischargePump" csv:"FuelOilConsumptionForDischargePump"`
	FuelOilConsumptionForReeferContainers   float64 `json:"fuelOilConsumptionForReeferContainers" xml:"FuelOilConsumptionForReeferContainers" csv:"FuelOilConsumptionForReeferContainers"`
}
