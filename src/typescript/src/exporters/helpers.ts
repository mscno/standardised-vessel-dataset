import { asObject, SvdObject } from "../runtime/types";
import { StandardisedVesselDatasetValidator } from "../validators/StandardisedVesselDatasetValidator";
import { ValidationError } from "../validators/ValidationError";

export function ensureValidDataset(
  dataset: unknown,
  validator: StandardisedVesselDatasetValidator,
): SvdObject {
  const datasetObject = asObject(dataset);
  if (datasetObject === null) {
    throw new Error("svd cannot be nil");
  }

  const errors = validator.validate(datasetObject);
  if (errors.length > 0) {
    throw new Error(formatValidationFailure(errors));
  }

  return datasetObject;
}

export function formatValidationFailure(errors: ValidationError[]): string {
  if (errors.length === 0) {
    return "Validation failed";
  }

  const lines = errors.map((error) => ` -- ${error.field}: ${error.message};`);
  return `Validation failed:\n${lines.join("\n")}`;
}

export function generateFileName(dataset: SvdObject, extension: string): string {
  const general = asObject(dataset.general);
  const imo = general !== null && typeof general.imo === "string" ? general.imo.trim() : "";
  const date = reportingDateSegment(general?.shipReportingDate) ?? currentUtcDate();

  if (imo.length > 0) {
    return `SVD_${imo}_${date}.${extension}`;
  }

  return `SVD_${date}.${extension}`;
}

export function toJson(dataset: SvdObject): string {
  return JSON.stringify(dataset, null, 2);
}

export function toXml(dataset: SvdObject): string {
  const lines: string[] = [];
  lines.push('<?xml version="1.0" encoding="UTF-8"?>');
  lines.push("<StandardisedVesselDataset>");
  appendXmlObject(dataset, lines, 1);
  lines.push("</StandardisedVesselDataset>");
  return lines.join("\n");
}

export function toCsv(dataset: SvdObject): string {
  const headers: string[] = [];
  const values: string[] = [];
  flattenCsvObject(dataset, "", headers, values);

  if (headers.length === 0) {
    throw new Error("dataset must contain at least one CSV-exportable field");
  }

  const headerLine = headers.map(csvEscape).join(",");
  const valueLine = values.map(csvEscape).join(",");
  return `${headerLine}\n${valueLine}\n`;
}

function appendXmlObject(object: SvdObject, lines: string[], indent: number): void {
  for (const [key, value] of Object.entries(object)) {
    appendXmlValue(toPascalCaseToken(key), value, lines, indent);
  }
}

function appendXmlValue(tag: string, value: unknown, lines: string[], indent: number): void {
  if (value === null || value === undefined) {
    return;
  }

  const padding = "  ".repeat(indent);

  if (Array.isArray(value)) {
    for (const item of value) {
      appendXmlValue(tag, item, lines, indent);
    }
    return;
  }

  const objectValue = asObject(value);
  if (objectValue !== null) {
    if (Object.keys(objectValue).length === 0) {
      return;
    }

    lines.push(`${padding}<${tag}>`);
    appendXmlObject(objectValue, lines, indent + 1);
    lines.push(`${padding}</${tag}>`);
    return;
  }

  lines.push(`${padding}<${tag}>${xmlEscape(formatXmlPrimitive(value))}</${tag}>`);
}

function flattenCsvObject(
  object: SvdObject,
  prefix: string,
  headers: string[],
  values: string[],
): void {
  for (const [key, value] of Object.entries(object)) {
    if (value === null || value === undefined) {
      continue;
    }

    const token = toPascalCaseToken(key);
    const path = prefix.length > 0 ? `${prefix}.${token}` : token;

    if (Array.isArray(value)) {
      for (let index = 0; index < value.length; index += 1) {
        const item = value[index];
        if (item === null || item === undefined) {
          continue;
        }

        const arrayPath = `${path}[${index}]`;
        const arrayItemAsObject = asObject(item);
        if (arrayItemAsObject !== null) {
          flattenCsvObject(arrayItemAsObject, arrayPath, headers, values);
        } else {
          headers.push(arrayPath);
          values.push(formatCsvPrimitive(arrayPath, item));
        }
      }
      continue;
    }

    const valueAsObject = asObject(value);
    if (valueAsObject !== null) {
      flattenCsvObject(valueAsObject, path, headers, values);
      continue;
    }

    headers.push(path);
    values.push(formatCsvPrimitive(path, value));
  }
}

function formatXmlPrimitive(value: unknown): string {
  if (typeof value === "boolean") {
    return value ? "true" : "false";
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return String(value);
}

function formatCsvPrimitive(path: string, value: unknown): string {
  if (typeof value === "boolean") {
    return value ? "True" : "False";
  }

  if (path.endsWith("ShipReportingDate")) {
    return formatDotNetDateTime(value);
  }

  if (value instanceof Date) {
    return value.toISOString();
  }

  return String(value);
}

function formatDotNetDateTime(value: unknown): string {
  const date = parseDate(value);
  if (date === null) {
    return String(value ?? "");
  }

  const base = date.toISOString().slice(0, 19);
  const fraction = `${String(date.getUTCMilliseconds()).padStart(3, "0")}0000`;
  return `${base}.${fraction}Z`;
}

function parseDate(value: unknown): Date | null {
  if (value instanceof Date) {
    return Number.isNaN(value.valueOf()) ? null : value;
  }

  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  if (trimmed.length === 0) {
    return null;
  }

  const parsed = new Date(trimmed);
  if (Number.isNaN(parsed.valueOf())) {
    return null;
  }

  return parsed;
}

function reportingDateSegment(value: unknown): string | null {
  const date = parseDate(value);
  if (date === null) {
    return null;
  }
  return date.toISOString().slice(0, 10);
}

function currentUtcDate(): string {
  return new Date().toISOString().slice(0, 10);
}

function toPascalCaseToken(token: string): string {
  if (token.length === 0) {
    return token;
  }
  return `${token.charAt(0).toUpperCase()}${token.slice(1)}`;
}

function xmlEscape(value: string): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/\"/g, "&quot;")
    .replace(/'/g, "&apos;");
}

function csvEscape(value: string): string {
  if (/[",\n\r]/.test(value)) {
    return `"${value.replace(/"/g, "\"\"")}"`;
  }
  return value;
}
