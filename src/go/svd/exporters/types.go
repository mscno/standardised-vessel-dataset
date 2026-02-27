package exporters

// StandardisedVesselDatasetContent represents the exported content of a Standardised Vessel Dataset
type StandardisedVesselDatasetContent struct {
	// The exported data as byte array
	Data []byte
	// Suggested filename for the export
	FileName string
	// MIME type of the exported content
	ContentType string
}
