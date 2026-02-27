package testdata

import (
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

// ValidSVD returns a deterministic valid SVD payload.
func ValidSVD() *models.StandardisedVesselDataset {
	now := time.Date(2025, time.January, 2, 15, 4, 5, 0, time.UTC)
	past := now.Add(-2 * time.Hour)
	future := now.Add(24 * time.Hour)

	return &models.StandardisedVesselDataset{
		General: &models.GeneralInformation{
			EventType:         "NOON",
			OperationType:     "SAILING",
			ElapsedTime:       24 * time.Hour,
			ShipLatitude:      10.2,
			ShipLongitude:     12.3,
			ShipReportingDate: now,
			ShipName:          "MV Example",
			Imo:               "9876543",
			Mmsi:              "123456789",
		},
		PortAndRoute: &models.PortInformation{
			DeparturePortCode: "SGSIN",
			DeparturePortName: "Singapore",
			ArrivalPortCode:   "NLRTM",
			ArrivalPortName:   "Rotterdam",
		},
		ArrivalTimes: &models.ArrivalTimes{
			Arrival:   future,
			Departure: past,
		},
		DeviationFromPlanned: &models.DeviationFromPlanned{
			Reason:                   "Weather",
			Latitude:                 1.2,
			Longitude:                2.3,
			ShipDeviationStartedTime: past,
			ShipDeviationStoppedTime: now,
		},
		SpeedAndDistance: &models.SpeedAndDistance{
			DistanceOverGround: 200,
			SpeedOverGround:    14,
			LadenIndicator:     true,
			ShipDraught:        "10.4",
		},
		Weather: &models.WeatherInformation{
			WeatherRemarks: "calm",
			WindForce:      4,
			WindSpeed:      "4",
			WindDirection:  "18",
			StateOfSea:     "2",
		},
		FreshWater:             &models.FreshWater{FreshWaterProduced: 10},
		ElectricityConsumption: &models.ElectricityConsumption{GeneratorProduction: 200},
		Cargo: &models.CargoInformation{
			CargoDescription: "bulk",
			GrossWeight:      200,
		},
		FuelAndBunker: &models.FuelAndBunkerInformation{
			FuelType:             "MGO",
			FuelRemainingOnBoard: 100,
		},
		Emissions: &models.Emissions{TotalCo2: 10.5},
		CylinderLubeOil: &models.CylinderLubeOilInformation{
			RemainingOnBoard: 5,
		},
	}
}

// InvalidSVD returns invalid data according to validator rules.
func InvalidSVD() *models.StandardisedVesselDataset {
	now := time.Time{}
	return &models.StandardisedVesselDataset{
		General: &models.GeneralInformation{
			ShipName:          "",
			Imo:               "12",
			ShipReportingDate: now,
		},
	}
}
