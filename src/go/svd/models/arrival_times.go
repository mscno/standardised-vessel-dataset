package models

import "time"

// ArrivalTimes represents the "Arrival Times" section of SVD.
type ArrivalTimes struct {
	Arrival                  time.Time `json:"arrival" xml:"Arrival" csv:"Arrival"`
	Departure                time.Time `json:"departure" xml:"Departure" csv:"Departure"`
	LocationEta              time.Time `json:"locationEta" xml:"LocationEta" csv:"LocationEta"`
	LocationActual           time.Time `json:"locationActual" xml:"LocationActual" csv:"LocationActual"`
	PilotBoardingPlaceEta    time.Time `json:"pilotBoardingPlaceEta" xml:"PilotBoardingPlaceEta" csv:"PilotBoardingPlaceEta"`
	PilotBoardingPlaceActual time.Time `json:"pilotBoardingPlaceActual" xml:"PilotBoardingPlaceActual" csv:"PilotBoardingPlaceActual"`
	VtsEta                   time.Time `json:"vtsEta" xml:"VtsEta" csv:"VtsEta"`
	VtsActual                time.Time `json:"vtsActual" xml:"VtsActual" csv:"VtsActual"`
	NextPortEta              time.Time `json:"nextPortEta" xml:"NextPortEta" csv:"NextPortEta"`
	VoyageTime               int       `json:"voyageTime" xml:"VoyageTime" csv:"VoyageTime"`
}
