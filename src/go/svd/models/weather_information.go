package models

// WeatherInformation represents the "Weather" section of SVD.
type WeatherInformation struct {
	WeatherRemarks                       string  `json:"weatherRemarks" xml:"WeatherRemarks" csv:"WeatherRemarks"`
	BadWeatherHours                      float64 `json:"badWeatherHours" xml:"BadWeatherHours" csv:"BadWeatherHours"`
	BadWeatherDistance                   float64 `json:"badWeatherDistance" xml:"BadWeatherDistance" csv:"BadWeatherDistance"`
	WindForce                            int     `json:"windForce" xml:"WindForce" csv:"WindForce"`
	WindSpeed                            string  `json:"windSpeed" xml:"WindSpeed" csv:"WindSpeed"`
	WindDirection                        string  `json:"windDirection" xml:"WindDirection" csv:"WindDirection"`
	WindDirectionEstimatedRelative       float64 `json:"windDirectionEstimatedRelative" xml:"WindDirectionEstimatedRelative" csv:"WindDirectionEstimatedRelative"`
	WindDirectionEstimated               float64 `json:"windDirectionEstimated" xml:"WindDirectionEstimated" csv:"WindDirectionEstimated"`
	AirTemperature                       float64 `json:"airTemperature" xml:"AirTemperature" csv:"AirTemperature"`
	AtmosphericPressure                  float64 `json:"atmosphericPressure" xml:"AtmosphericPressure" csv:"AtmosphericPressure"`
	StateOfSea                           string  `json:"stateOfSea" xml:"StateOfSea" csv:"StateOfSea"`
	SeaDirectionRelative                 float64 `json:"seaDirectionRelative" xml:"SeaDirectionRelative" csv:"SeaDirectionRelative"`
	SeaDirection                         float64 `json:"seaDirection" xml:"SeaDirection" csv:"SeaDirection"`
	SeaHeight                            float64 `json:"seaHeight" xml:"SeaHeight" csv:"SeaHeight"`
	SwellDirectionRelative               float64 `json:"swellDirectionRelative" xml:"SwellDirectionRelative" csv:"SwellDirectionRelative"`
	SwellDirection                       float64 `json:"swellDirection" xml:"SwellDirection" csv:"SwellDirection"`
	SwellHeight                          float64 `json:"swellHeight" xml:"SwellHeight" csv:"SwellHeight"`
	OceanCurrentDirectionRelative        float64 `json:"oceanCurrentDirectionRelative" xml:"OceanCurrentDirectionRelative" csv:"OceanCurrentDirectionRelative"`
	OceanCurrentDirection                float64 `json:"oceanCurrentDirection" xml:"OceanCurrentDirection" csv:"OceanCurrentDirection"`
	OceanCurrentDirectionWeatherProvider float64 `json:"oceanCurrentDirectionWeatherProvider" xml:"OceanCurrentDirectionWeatherProvider" csv:"OceanCurrentDirectionWeatherProvider"`
}
