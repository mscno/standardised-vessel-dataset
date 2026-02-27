//go:build example

package main

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"

	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/extensions"
	"github.com/WMS-Ceataec/standardised-vessel-dataset/src/go/svd/models"
)

func main() {
	provider := extensions.NewServiceProvider()
	svd := createSampleSVD()

	validator := provider.GetValidator()
	if errs := validator.Validate(svd); len(errs) > 0 {
		for _, err := range errs {
			log.Printf("validation error: %s - %s", err.Field, err.Message)
		}
		return
	}

	ctx := context.Background()
	jsonExporter := provider.GetJSONExporter()
	jsonResult, err := jsonExporter.ExportAsync(ctx, svd)
	if err != nil {
		log.Fatalf("json export failed: %v", err)
	}
	if err := os.WriteFile(jsonResult.FileName, jsonResult.Data, 0o644); err != nil {
		log.Printf("write json failed: %v", err)
	}

	fmt.Printf("Exported %s\n", jsonResult.FileName)
}

func createSampleSVD() *models.StandardisedVesselDataset {
	now := time.Now().UTC()
	return &models.StandardisedVesselDataset{
		General: &models.GeneralInformation{
			EventType:         "NOON",
			OperationType:     "SAILING",
			ShipLatitude:      51.5074,
			ShipLongitude:     -0.1278,
			ShipReportingDate: now,
			ShipName:          "MV Ocean Explorer",
			Imo:               "9876543",
			Mmsi:              "123456789",
		},
		PortAndRoute: &models.PortInformation{
			DeparturePortCode: "SGSIN",
			ArrivalPortCode:   "NLRTM",
		},
		Weather: &models.WeatherInformation{
			WindForce:      4,
			WindSpeed:      "4",
			WindDirection:  "22",
			AirTemperature: 22.5,
			StateOfSea:     "3",
			SwellHeight:    1.8,
			SeaHeight:      1.4,
		},
		Emissions: &models.Emissions{TotalCo2: 12.4},
	}
}
