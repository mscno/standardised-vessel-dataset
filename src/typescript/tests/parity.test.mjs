import assert from "node:assert/strict";
import test from "node:test";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

import {
  StandardisedVesselDatasetValidator,
  SvdJsonExporter,
  SvdXmlExporter,
  SvdCsvExporter,
} from "../lib/standardised-vessel-dataset.js";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const repoRoot = path.resolve(__dirname, "../../..");
const conformanceCasesDir = path.join(repoRoot, "conformance", "cases");

function loadCase(fileName) {
  const raw = fs.readFileSync(path.join(conformanceCasesDir, fileName), "utf8");
  return JSON.parse(raw);
}

function parseCsv(csvText) {
  const rows = [];
  let row = [];
  let value = "";
  let inQuotes = false;

  for (let index = 0; index < csvText.length; index += 1) {
    const char = csvText[index];
    const next = csvText[index + 1];

    if (char === '"') {
      if (inQuotes && next === '"') {
        value += '"';
        index += 1;
      } else {
        inQuotes = !inQuotes;
      }
      continue;
    }

    if (!inQuotes && char === ",") {
      row.push(value);
      value = "";
      continue;
    }

    if (!inQuotes && (char === "\n" || char === "\r")) {
      if (char === "\r" && next === "\n") {
        index += 1;
      }
      if (value.length > 0 || row.length > 0) {
        row.push(value);
        rows.push(row);
        row = [];
        value = "";
      }
      continue;
    }

    value += char;
  }

  if (value.length > 0 || row.length > 0) {
    row.push(value);
    rows.push(row);
  }

  return rows;
}

function csvMap(csvText) {
  const rows = parseCsv(csvText);
  assert.ok(rows.length >= 2, "CSV should include header and value rows");
  const [headers, values] = rows;
  const mapping = {};
  for (let index = 0; index < headers.length && index < values.length; index += 1) {
    const shortHeader = headers[index].split(".").at(-1);
    if (shortHeader && !(shortHeader in mapping)) {
      mapping[shortHeader] = values[index];
    }
  }
  return mapping;
}

test("valid_core conformance shape matches expected runtime output", () => {
  const caseData = loadCase("valid_core.json");
  const dataset = caseData.dataset;

  const validator = new StandardisedVesselDatasetValidator();
  const errors = validator.validate(dataset);
  assert.deepEqual(errors, []);

  const jsonExporter = new SvdJsonExporter(validator);
  const xmlExporter = new SvdXmlExporter(validator);
  const csvExporter = new SvdCsvExporter(validator);

  const jsonContent = jsonExporter.export(dataset);
  const xmlContent = xmlExporter.export(dataset);
  const csvContent = csvExporter.export(dataset);

  const jsonPayload = JSON.parse(jsonContent.data);
  assert.equal(jsonPayload.general.eventType, "NOON");
  assert.equal(jsonPayload.general.operationType, "SAILING");
  assert.equal(jsonPayload.general.shipName, "MV Example");
  assert.equal(jsonPayload.general.imo, "9876543");

  assert.match(xmlContent.data, /<EventType>NOON<\/EventType>/);
  assert.match(xmlContent.data, /<OperationType>SAILING<\/OperationType>/);
  assert.match(xmlContent.data, /<Imo>9876543<\/Imo>/);

  const csvShortMap = csvMap(csvContent.data);
  assert.equal(csvShortMap.EventType, "NOON");
  assert.equal(csvShortMap.OperationType, "SAILING");
  assert.equal(csvShortMap.Imo, "9876543");
  assert.equal(csvShortMap.ShipReportingDate, "2025-01-02T15:04:05.0000000Z");
});

test("invalid_general_imo_non_numeric fails validation and export", () => {
  const caseData = loadCase("invalid_general_imo_non_numeric.json");
  const dataset = caseData.dataset;

  const validator = new StandardisedVesselDatasetValidator();
  const errors = validator.validate(dataset);
  assert.ok(errors.some((error) => error.field === "General.Imo"));

  const jsonExporter = new SvdJsonExporter(validator);
  assert.throws(() => jsonExporter.export(dataset), /Validation failed/);
});

test("valid_required_fields_only validates and exports", () => {
  const caseData = loadCase("valid_required_fields_only.json");
  const dataset = caseData.dataset;

  const validator = new StandardisedVesselDatasetValidator();
  const errors = validator.validate(dataset);
  assert.deepEqual(errors, []);

  const xmlContent = new SvdXmlExporter(validator).export(dataset);
  assert.match(xmlContent.data, /<ShipName>MV Minimal<\/ShipName>/);
  assert.match(xmlContent.data, /<Imo>9876543<\/Imo>/);
});
