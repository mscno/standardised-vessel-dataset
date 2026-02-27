package models

import "time"

// CargoInformation represents the "Cargo" section of SVD.
type CargoInformation struct {
	CargoDescription             string    `json:"cargoDescription" xml:"CargoDescription" csv:"CargoDescription"`
	GrossWeight                  float64   `json:"grossWeight" xml:"GrossWeight" csv:"GrossWeight"`
	GrossVolume                  float64   `json:"grossVolume" xml:"GrossVolume" csv:"GrossVolume"`
	BillOfLadingReference        string    `json:"billOfLadingReference" xml:"BillOfLadingReference" csv:"BillOfLadingReference"`
	BillOfLadingIssuedDate       time.Time `json:"billOfLadingIssuedDate" xml:"BillOfLadingIssuedDate" csv:"BillOfLadingIssuedDate"`
	TotalContainersTEU           int       `json:"totalContainersTEU" xml:"TotalContainersTEU" csv:"TotalContainersTEU"`
	TotalFullContainersTEU       int       `json:"totalFullContainersTEU" xml:"TotalFullContainersTEU" csv:"TotalFullContainersTEU"`
	TotalFullReeferContainersTEU int       `json:"totalFullReeferContainersTEU" xml:"TotalFullReeferContainersTEU" csv:"TotalFullReeferContainersTEU"`
	ReeferSocketsInUse           int       `json:"reeferSocketsInUse" xml:"ReeferSocketsInUse" csv:"ReeferSocketsInUse"`
	Chilled20FtReeferContainers  int       `json:"chilled20FtReeferContainers" xml:"Chilled20FtReeferContainers" csv:"Chilled20FtReeferContainers"`
	Chilled40FtReeferContainers  int       `json:"chilled40FtReeferContainers" xml:"Chilled40FtReeferContainers" csv:"Chilled40FtReeferContainers"`
	Frozen20FtReeferContainers   int       `json:"frozen20FtReeferContainers" xml:"Frozen20FtReeferContainers" csv:"Frozen20FtReeferContainers"`
	Frozen40FtReeferContainers   int       `json:"frozen40FtReeferContainers" xml:"Frozen40FtReeferContainers" csv:"Frozen40FtReeferContainers"`
	TotalVehiclesCEU             int       `json:"totalVehiclesCEU" xml:"TotalVehiclesCEU" csv:"TotalVehiclesCEU"`
}
