package models

// Emissions represents emissions metrics for SVD.
type Emissions struct {
	TotalCo2                    float64 `json:"totalCo2" xml:"TotalCo2" csv:"TotalCo2"`
	TotalCo2Percentage          float64 `json:"totalCo2Percentage" xml:"TotalCo2Percentage" csv:"TotalCo2Percentage"`
	TotalCo2TankToWake          float64 `json:"totalCo2TankToWake" xml:"TotalCo2TankToWake" csv:"TotalCo2TankToWake"`
	TotalCo2Captured            float64 `json:"totalCo2Captured" xml:"TotalCo2Captured" csv:"TotalCo2Captured"`
	TotalCh4                    float64 `json:"totalCh4" xml:"TotalCh4" csv:"TotalCh4"`
	TotalCh4ConvertedToCo2      float64 `json:"totalCh4ConvertedToCo2" xml:"TotalCh4ConvertedToCo2" csv:"TotalCh4ConvertedToCo2"`
	TotalN2o                    float64 `json:"totalN2o" xml:"TotalN2o" csv:"TotalN2o"`
	TotalN2oConvertedToCo2      float64 `json:"totalN2oConvertedToCo2" xml:"TotalN2oConvertedToCo2" csv:"TotalN2oConvertedToCo2"`
	Ch4EmissionConversionFactor float64 `json:"ch4EmissionConversionFactor" xml:"Ch4EmissionConversionFactor" csv:"Ch4EmissionConversionFactor"`
	N2oEmissionConversionFactor float64 `json:"n2oEmissionConversionFactor" xml:"N2oEmissionConversionFactor" csv:"N2oEmissionConversionFactor"`
}
