package models

// SpeedAndDistance represents the "Speed and Distance" section of SVD.
type SpeedAndDistance struct {
	DistanceThroughWater        float64 `json:"distanceThroughWater" xml:"DistanceThroughWater" csv:"DistanceThroughWater"`
	DistanceOverGround          float64 `json:"distanceOverGround" xml:"DistanceOverGround" csv:"DistanceOverGround"`
	DistanceSailedInIce         float64 `json:"distanceSailedInIce" xml:"DistanceSailedInIce" csv:"DistanceSailedInIce"`
	DistanceToNextPort          float64 `json:"distanceToNextPort" xml:"DistanceToNextPort" csv:"DistanceToNextPort"`
	DistanceToNextWaypoint      float64 `json:"distanceToNextWaypoint" xml:"DistanceToNextWaypoint" csv:"DistanceToNextWaypoint"`
	TotalDistanceOnSeaPassage   float64 `json:"totalDistanceOnSeaPassage" xml:"TotalDistanceOnSeaPassage" csv:"TotalDistanceOnSeaPassage"`
	DistanceExcluded            float64 `json:"distanceExcluded" xml:"DistanceExcluded" csv:"DistanceExcluded"`
	SpeedOverGround             float64 `json:"speedOverGround" xml:"SpeedOverGround" csv:"SpeedOverGround"`
	SpeedThroughWater           float64 `json:"speedThroughWater" xml:"SpeedThroughWater" csv:"SpeedThroughWater"`
	SpeedPropeller              float64 `json:"speedPropeller" xml:"SpeedPropeller" csv:"SpeedPropeller"`
	SpeedProjected              float64 `json:"speedProjected" xml:"SpeedProjected" csv:"SpeedProjected"`
	SpeedOrder                  float64 `json:"speedOrder" xml:"SpeedOrder" csv:"SpeedOrder"`
	Slip                        float64 `json:"slip" xml:"Slip" csv:"Slip"`
	CourseOverGround            float64 `json:"courseOverGround" xml:"CourseOverGround" csv:"CourseOverGround"`
	ShipTrueHeading             float64 `json:"shipTrueHeading" xml:"ShipTrueHeading" csv:"ShipTrueHeading"`
	ShipDraught                 string  `json:"shipDraught" xml:"ShipDraught" csv:"ShipDraught"`
	DraughtForward              float64 `json:"draughtForward" xml:"DraughtForward" csv:"DraughtForward"`
	DraughtAft                  float64 `json:"draughtAft" xml:"DraughtAft" csv:"DraughtAft"`
	ShipActualDeadweightTonnage float64 `json:"shipActualDeadweightTonnage" xml:"ShipActualDeadweightTonnage" csv:"ShipActualDeadweightTonnage"`
	ShipMaximumDeadweight       float64 `json:"shipMaximumDeadweight" xml:"ShipMaximumDeadweight" csv:"ShipMaximumDeadweight"`
	LadenIndicator              bool    `json:"ladenIndicator" xml:"LadenIndicator" csv:"LadenIndicator"`
	TotalBallastWaterOnboard    float64 `json:"totalBallastWaterOnboard" xml:"TotalBallastWaterOnboard" csv:"TotalBallastWaterOnboard"`
}
