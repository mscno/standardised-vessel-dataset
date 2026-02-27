package models

import "time"

// GeneralInformation represents the "General" section of SVD.
type GeneralInformation struct {
	EventType             string        `json:"eventType" xml:"EventType" csv:"EventType"`
	OperationType         string        `json:"operationType" xml:"OperationType" csv:"OperationType"`
	OperationDescription  string        `json:"operationDescription" xml:"OperationDescription" csv:"OperationDescription"`
	PerformanceReportType string        `json:"performanceReportType" xml:"PerformanceReportType" csv:"PerformanceReportType"`
	ElapsedTime           time.Duration `json:"elapsedTime" xml:"ElapsedTime" csv:"ElapsedTime"`
	ShipLatitude          float64       `json:"shipLatitude" xml:"ShipLatitude" csv:"ShipLatitude"`
	ShipLongitude         float64       `json:"shipLongitude" xml:"ShipLongitude" csv:"ShipLongitude"`
	ShipReportingDate     time.Time     `json:"shipReportingDate" xml:"ShipReportingDate" csv:"ShipReportingDate"`
	ShipFlagState         string        `json:"shipFlagState" xml:"ShipFlagState" csv:"ShipFlagState"`
	ShipRegistryPortCode  string        `json:"shipRegistryPortCode" xml:"ShipRegistryPortCode" csv:"ShipRegistryPortCode"`
	ShipRegistryPortName  string        `json:"shipRegistryPortName" xml:"ShipRegistryPortName" csv:"ShipRegistryPortName"`
	ShipName              string        `json:"shipName" xml:"ShipName" csv:"ShipName"`
	Imo                   string        `json:"imo" xml:"Imo" csv:"Imo"`
	Mmsi                  string        `json:"mmsi" xml:"Mmsi" csv:"Mmsi"`
	ShipType              string        `json:"shipType" xml:"ShipType" csv:"ShipType"`
	ShipTypeMarpolAnnexVi string        `json:"shipTypeMarpolAnnexVi" xml:"ShipTypeMarpolAnnexVi" csv:"ShipTypeMarpolAnnexVi"`
	NumberOfPassengers    int           `json:"numberOfPassengers" xml:"NumberOfPassengers" csv:"NumberOfPassengers"`
	NumberOfCrew          int           `json:"numberOfCrew" xml:"NumberOfCrew" csv:"NumberOfCrew"`
	VoyageNumber          string        `json:"voyageNumber" xml:"VoyageNumber" csv:"VoyageNumber"`
	VoyageRemarks         string        `json:"voyageRemarks" xml:"VoyageRemarks" csv:"VoyageRemarks"`
	VoyageLegIdentifier   string        `json:"voyageLegIdentifier" xml:"VoyageLegIdentifier" csv:"VoyageLegIdentifier"`
	VoyageLegRemarks      string        `json:"voyageLegRemarks" xml:"VoyageLegRemarks" csv:"VoyageLegRemarks"`
}
