package models

// FreshWater represents the "Fresh Water" section of SVD.
type FreshWater struct {
	FreshWaterBunkered     float64 `json:"freshWaterBunkered" xml:"FreshWaterBunkered" csv:"FreshWaterBunkered"`
	FreshWaterProduced     float64 `json:"freshWaterProduced" xml:"FreshWaterProduced" csv:"FreshWaterProduced"`
	FreshWaterConsumed     float64 `json:"freshWaterConsumed" xml:"FreshWaterConsumed" csv:"FreshWaterConsumed"`
	TechnicalWaterProduced float64 `json:"technicalWaterProduced" xml:"TechnicalWaterProduced" csv:"TechnicalWaterProduced"`
	TechnicalWaterConsumed float64 `json:"technicalWaterConsumed" xml:"TechnicalWaterConsumed" csv:"TechnicalWaterConsumed"`
	WashWaterConsumed      float64 `json:"washWaterConsumed" xml:"WashWaterConsumed" csv:"WashWaterConsumed"`
	FreshWaterRemaining    float64 `json:"freshWaterRemaining" xml:"FreshWaterRemaining" csv:"FreshWaterRemaining"`
}
