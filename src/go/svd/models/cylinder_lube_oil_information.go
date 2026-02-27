package models

// CylinderLubeOilInformation represents the "Cylinder Lube Oil" section of SVD.
type CylinderLubeOilInformation struct {
	RemainingOnBoard        float64 `json:"remainingOnBoard" xml:"RemainingOnBoard" csv:"RemainingOnBoard"`
	FeedRate                float64 `json:"feedRate" xml:"FeedRate" csv:"FeedRate"`
	Consumption             float64 `json:"consumption" xml:"Consumption" csv:"Consumption"`
	ReceivedDuringBunkering float64 `json:"receivedDuringBunkering" xml:"ReceivedDuringBunkering" csv:"ReceivedDuringBunkering"`
}
