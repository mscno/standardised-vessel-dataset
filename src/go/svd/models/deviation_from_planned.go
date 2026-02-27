package models

import "time"

// DeviationFromPlanned represents the "Deviation From Planned" section of SVD.
type DeviationFromPlanned struct {
	Reason                   string    `json:"reason" xml:"Reason" csv:"Reason"`
	Latitude                 float64   `json:"latitude" xml:"Latitude" csv:"Latitude"`
	Longitude                float64   `json:"longitude" xml:"Longitude" csv:"Longitude"`
	ShipDeviationStartedTime time.Time `json:"shipDeviationStartedTime" xml:"ShipDeviationStartedTime" csv:"ShipDeviationStartedTime"`
	ShipDeviationStoppedTime time.Time `json:"shipDeviationStoppedTime" xml:"ShipDeviationStoppedTime" csv:"ShipDeviationStoppedTime"`
}
