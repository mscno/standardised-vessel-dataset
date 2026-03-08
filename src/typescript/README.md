## Installation

```bash
npm install standardised-vessel-dataset
```

## Usage

```typescript
import {
  StandardisedVesselDatasetValidator,
  SvdJsonExporter,
  SvdXmlExporter,
  SvdCsvExporter,
} from "standardised-vessel-dataset";

const dataset = {
  general: {
    eventType: "NOON",
    operationType: "SAILING",
    shipName: "MV Example",
    imo: "9876543",
    shipReportingDate: "2025-01-02T15:04:05Z",
  },
};

const validator = new StandardisedVesselDatasetValidator();
const errors = validator.validate(dataset);

if (errors.length > 0) {
  console.error(errors);
} else {
  const json = new SvdJsonExporter().export(dataset);
  const xml = new SvdXmlExporter().export(dataset);
  const csv = new SvdCsvExporter().export(dataset);

  console.log(json.fileName, json.contentType);
  console.log(xml.fileName, xml.contentType);
  console.log(csv.fileName, csv.contentType);
}
```
