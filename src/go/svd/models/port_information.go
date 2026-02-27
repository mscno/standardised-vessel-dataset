package models

// PortInformation represents the "Port and Route" section of SVD.
type PortInformation struct {
	DeparturePortCode            string `json:"departurePortCode" xml:"DeparturePortCode" csv:"DeparturePortCode"`
	DeparturePortName            string `json:"departurePortName" xml:"DeparturePortName" csv:"DeparturePortName"`
	ArrivalPortCode              string `json:"arrivalPortCode" xml:"ArrivalPortCode" csv:"ArrivalPortCode"`
	ArrivalPortName              string `json:"arrivalPortName" xml:"ArrivalPortName" csv:"ArrivalPortName"`
	InboundPortJurisdictionCode  string `json:"inboundPortJurisdictionCode" xml:"InboundPortJurisdictionCode" csv:"InboundPortJurisdictionCode"`
	OutboundPortJurisdictionCode string `json:"outboundPortJurisdictionCode" xml:"OutboundPortJurisdictionCode" csv:"OutboundPortJurisdictionCode"`
	PilotBoardingPlaceName       string `json:"pilotBoardingPlaceName" xml:"PilotBoardingPlaceName" csv:"PilotBoardingPlaceName"`
	PilotBoardingPlaceLocation   string `json:"pilotBoardingPlaceLocation" xml:"PilotBoardingPlaceLocation" csv:"PilotBoardingPlaceLocation"`
	BerthName                    string `json:"berthName" xml:"BerthName" csv:"BerthName"`
}
