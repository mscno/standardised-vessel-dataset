package models

import (
	"os"
	"path/filepath"
	"reflect"
	"regexp"
	"runtime"
	"strings"
	"testing"
)

var dotnetModelFiles = map[string]reflect.Type{
	"ArrivalTimes.cs":               reflect.TypeOf(ArrivalTimes{}),
	"CargoInformation.cs":           reflect.TypeOf(CargoInformation{}),
	"CylinderLubeOilInformation.cs": reflect.TypeOf(CylinderLubeOilInformation{}),
	"DeviationFromPlanned.cs":       reflect.TypeOf(DeviationFromPlanned{}),
	"ElectricityConsumption.cs":     reflect.TypeOf(ElectricityConsumption{}),
	"Emissions.cs":                  reflect.TypeOf(Emissions{}),
	"FreshWater.cs":                 reflect.TypeOf(FreshWater{}),
	"FuelAndBunkerInformation.cs":   reflect.TypeOf(FuelAndBunkerInformation{}),
	"GeneralInformation.cs":         reflect.TypeOf(GeneralInformation{}),
	"PortInformation.cs":            reflect.TypeOf(PortInformation{}),
	"SpeedAndDistance.cs":           reflect.TypeOf(SpeedAndDistance{}),
	"StandardizedVesselDataset.cs":  reflect.TypeOf(StandardisedVesselDataset{}),
	"WeatherInformation.cs":         reflect.TypeOf(WeatherInformation{}),
}

func TestModelTagsArePresent(t *testing.T) {
	types := []reflect.Type{
		reflect.TypeOf(StandardisedVesselDataset{}),
		reflect.TypeOf(GeneralInformation{}),
		reflect.TypeOf(PortInformation{}),
		reflect.TypeOf(ArrivalTimes{}),
		reflect.TypeOf(DeviationFromPlanned{}),
		reflect.TypeOf(SpeedAndDistance{}),
		reflect.TypeOf(WeatherInformation{}),
		reflect.TypeOf(FreshWater{}),
		reflect.TypeOf(ElectricityConsumption{}),
		reflect.TypeOf(CargoInformation{}),
		reflect.TypeOf(FuelAndBunkerInformation{}),
		reflect.TypeOf(Emissions{}),
		reflect.TypeOf(CylinderLubeOilInformation{}),
	}

	for _, typ := range types {
		for i := 0; i < typ.NumField(); i++ {
			field := typ.Field(i)
			if field.Name == "XMLName" {
				continue
			}
			if field.Tag.Get("json") == "" || field.Tag.Get("xml") == "" || field.Tag.Get("csv") == "" {
				t.Fatalf("missing tags for %s.%s", typ.Name(), field.Name)
			}
		}
	}
}

func TestDotNetModelParity(t *testing.T) {
	root := repoRoot(t)
	baseDir := filepath.Join(root, "src", "dotnet", "src", "StandardisedVesselDataset", "Models")
	propertyRegex := regexp.MustCompile(`public\s+[^\s]+\s+([A-Za-z0-9_]+)\s*\{\s*get;`)

	for fileName, goType := range dotnetModelFiles {
		content := mustReadFile(t, filepath.Join(baseDir, fileName))
		matches := propertyRegex.FindAllStringSubmatch(content, -1)
		goFields := fieldSet(goType, map[string]struct{}{"xmlname": {}})
		dotnetFields := make(map[string]string, len(matches))

		if len(matches) == 0 {
			t.Fatalf("no properties found in %s", fileName)
		}

		for _, m := range matches {
			property := m[1]
			dotnetFields[canonical(property)] = property
			if _, ok := goFields[canonical(property)]; !ok {
				t.Errorf("missing .NET property %s in Go type %s", property, goType.Name())
			}
		}

		for canonicalGoField, goField := range goFields {
			if _, ok := dotnetFields[canonicalGoField]; !ok {
				t.Errorf("extra Go field %s in type %s (not found in %s)", goField, goType.Name(), fileName)
			}
		}
	}
}

func fieldSet(typ reflect.Type, ignore map[string]struct{}) map[string]string {
	result := make(map[string]string, typ.NumField())
	for i := 0; i < typ.NumField(); i++ {
		fieldName := typ.Field(i).Name
		canonicalName := canonical(fieldName)
		if _, shouldIgnore := ignore[canonicalName]; shouldIgnore {
			continue
		}
		result[canonicalName] = fieldName
	}
	return result
}

func canonical(input string) string {
	var b strings.Builder
	for _, r := range input {
		if (r >= 'a' && r <= 'z') || (r >= 'A' && r <= 'Z') || (r >= '0' && r <= '9') {
			if r >= 'A' && r <= 'Z' {
				r = r + ('a' - 'A')
			}
			b.WriteRune(r)
		}
	}
	return b.String()
}

func repoRoot(t *testing.T) string {
	t.Helper()
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		t.Fatal("failed to resolve runtime caller")
	}
	return filepath.Clean(filepath.Join(filepath.Dir(file), "..", "..", "..", ".."))
}

func mustReadFile(t *testing.T, path string) string {
	t.Helper()
	content, err := os.ReadFile(path)
	if err != nil {
		t.Fatalf("read file %s: %v", path, err)
	}
	return string(content)
}
