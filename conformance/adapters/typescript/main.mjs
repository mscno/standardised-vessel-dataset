#!/usr/bin/env node

import { performance } from "node:perf_hooks";
import { stdin, stdout } from "node:process";

const IMPLEMENTATION = "typescript";

function readStdin() {
  return new Promise((resolve, reject) => {
    let raw = "";
    stdin.setEncoding("utf8");
    stdin.on("data", (chunk) => {
      raw += chunk;
    });
    stdin.on("end", () => resolve(raw));
    stdin.on("error", reject);
  });
}

function shouldRun(operations, operation) {
  if (!Array.isArray(operations) || operations.length === 0) {
    return true;
  }
  return operations.some((candidate) => String(candidate).toLowerCase() === operation.toLowerCase());
}

function validateDataset(dataset) {
  if (!dataset || typeof dataset !== "object" || Array.isArray(dataset)) {
    return [{ field: "SVD", message: "SVD cannot be nil" }];
  }

  const general = dataset.general;
  if (!general || typeof general !== "object" || Array.isArray(general)) {
    return [{ field: "General", message: "General is required" }];
  }

  const errors = [];
  const imo = String(general.imo ?? "").trim();
  const shipName = String(general.shipName ?? "").trim();
  const shipReportingDate = general.shipReportingDate;

  if (imo.length === 0) {
    errors.push({ field: "General.Imo", message: "Imo is required" });
  }
  if (!/^\d{7}$/.test(imo)) {
    errors.push({ field: "General.Imo", message: "Imo must be seven digits." });
  }
  if (shipName.length === 0) {
    errors.push({ field: "General.ShipName", message: "Ship Name is required" });
  }
  if (!isValidShipReportingDate(shipReportingDate)) {
    errors.push({
      field: "General.ShipReportingDate",
      message: "Ship Reporting Date (Datetime) must be greater than default.",
    });
  }

  return errors;
}

function isValidShipReportingDate(value) {
  if (typeof value !== "string") {
    return false;
  }
  const trimmed = value.trim();
  if (!trimmed) {
    return false;
  }

  const parsed = new Date(trimmed);
  if (Number.isNaN(parsed.valueOf())) {
    return false;
  }

  return parsed.getUTCFullYear() > 1;
}

function formatValidationFailure(errors) {
  if (!errors.length) {
    return "Validation failed";
  }
  const details = errors.map((error) => ` -- ${error.field}: ${error.message};`).join("\n");
  return `Validation failed:\n${details}`;
}

function runExport(dataset, extension, contentType, formatter) {
  if (!dataset || typeof dataset !== "object" || Array.isArray(dataset)) {
    return { ok: false, error: "svd cannot be nil" };
  }

  const errors = validateDataset(dataset);
  if (errors.length > 0) {
    return { ok: false, error: formatValidationFailure(errors) };
  }

  return {
    ok: true,
    file_name: generateFileName(dataset, extension),
    content_type: contentType,
    data: formatter(dataset),
  };
}

function generateFileName(dataset, extension) {
  const general = dataset?.general && typeof dataset.general === "object" ? dataset.general : null;
  const imo = String(general?.imo ?? "").trim();
  const date = fileDateFromReport(general?.shipReportingDate) ?? currentUtcDate();

  if (imo) {
    return `SVD_${imo}_${date}.${extension}`;
  }
  return `SVD_${date}.${extension}`;
}

function fileDateFromReport(value) {
  if (typeof value !== "string" || !value.trim()) {
    return null;
  }
  const parsed = new Date(value);
  if (Number.isNaN(parsed.valueOf())) {
    return null;
  }
  return parsed.toISOString().slice(0, 10);
}

function currentUtcDate() {
  return new Date().toISOString().slice(0, 10);
}

function exportJson(dataset) {
  return JSON.stringify(dataset, null, 2);
}

function exportXml(dataset) {
  const lines = [];
  lines.push('<?xml version="1.0" encoding="UTF-8"?>');
  lines.push("<StandardisedVesselDataset>");
  appendXmlObject(dataset, lines, 1);
  lines.push("</StandardisedVesselDataset>");
  return `${lines.join("\n")}`;
}

function appendXmlObject(object, lines, indent) {
  for (const [key, value] of Object.entries(object)) {
    appendXmlValue(pascalCaseToken(key), value, lines, indent);
  }
}

function appendXmlValue(tag, value, lines, indent) {
  if (value === null || value === undefined) {
    return;
  }

  const pad = "  ".repeat(indent);
  if (Array.isArray(value)) {
    for (const item of value) {
      appendXmlValue(tag, item, lines, indent);
    }
    return;
  }

  if (typeof value === "object") {
    if (Object.keys(value).length === 0) {
      return;
    }
    lines.push(`${pad}<${tag}>`);
    appendXmlObject(value, lines, indent + 1);
    lines.push(`${pad}</${tag}>`);
    return;
  }

  lines.push(`${pad}<${tag}>${xmlEscape(formatXmlPrimitive(value))}</${tag}>`);
}

function exportCsv(dataset) {
  const headers = [];
  const values = [];
  flattenCsv(dataset, "", headers, values);

  if (headers.length === 0) {
    throw new Error("dataset must contain at least one CSV-exportable field");
  }

  const headerLine = headers.map(csvEscape).join(",");
  const valueLine = values.map(csvEscape).join(",");
  return `${headerLine}\n${valueLine}\n`;
}

function flattenCsv(object, prefix, headers, values) {
  for (const [key, value] of Object.entries(object)) {
    if (value === null || value === undefined) {
      continue;
    }

    const token = pascalCaseToken(key);
    const path = prefix ? `${prefix}.${token}` : token;

    if (Array.isArray(value)) {
      for (let index = 0; index < value.length; index += 1) {
        const item = value[index];
        const indexedPath = `${path}[${index}]`;
        if (item !== null && typeof item === "object" && !Array.isArray(item)) {
          flattenCsv(item, indexedPath, headers, values);
        } else if (item !== null && item !== undefined) {
          headers.push(indexedPath);
          values.push(formatCsvPrimitive(indexedPath, item));
        }
      }
      continue;
    }

    if (typeof value === "object") {
      flattenCsv(value, path, headers, values);
      continue;
    }

    headers.push(path);
    values.push(formatCsvPrimitive(path, value));
  }
}

function formatXmlPrimitive(value) {
  if (typeof value === "boolean") {
    return value ? "true" : "false";
  }
  return String(value);
}

function formatCsvPrimitive(path, value) {
  if (typeof value === "boolean") {
    return value ? "True" : "False";
  }
  if (typeof value === "string" && path.endsWith("ShipReportingDate")) {
    return formatDotNetDateTime(value);
  }
  return String(value);
}

function formatDotNetDateTime(value) {
  const parsed = new Date(value);
  if (Number.isNaN(parsed.valueOf())) {
    return value;
  }

  const base = parsed.toISOString().slice(0, 19);
  const fraction = `${String(parsed.getUTCMilliseconds()).padStart(3, "0")}0000`;
  return `${base}.${fraction}Z`;
}

function xmlEscape(input) {
  return input
    .replaceAll("&", "&amp;")
    .replaceAll("<", "&lt;")
    .replaceAll(">", "&gt;")
    .replaceAll('"', "&quot;")
    .replaceAll("'", "&apos;");
}

function csvEscape(input) {
  const text = String(input ?? "");
  if (/[",\n\r]/.test(text)) {
    return `"${text.replaceAll('"', '""')}"`;
  }
  return text;
}

function pascalCaseToken(input) {
  if (!input) {
    return "";
  }
  return input.charAt(0).toUpperCase() + input.slice(1);
}

function timeLoop(iterations, operation) {
  const start = performance.now();
  let errorCount = 0;

  for (let i = 0; i < iterations; i += 1) {
    try {
      operation();
    } catch {
      errorCount += 1;
    }
  }

  const totalMs = performance.now() - start;
  return {
    total_ms: totalMs,
    avg_ms: totalMs / iterations,
    error_count: errorCount,
  };
}

function runBenchmark(dataset, requestedIterations) {
  if (!dataset || typeof dataset !== "object" || Array.isArray(dataset)) {
    return { ok: false, error: "svd cannot be nil" };
  }

  const iterations = Number.isInteger(requestedIterations) && requestedIterations > 0 ? requestedIterations : 100;

  return {
    ok: true,
    iterations,
    metrics: {
      validate: timeLoop(iterations, () => {
        validateDataset(dataset);
      }),
      export_json: timeLoop(iterations, () => {
        const result = runExport(dataset, "json", "application/json", exportJson);
        if (!result.ok) {
          throw new Error(result.error);
        }
      }),
      export_xml: timeLoop(iterations, () => {
        const result = runExport(dataset, "xml", "application/xml", exportXml);
        if (!result.ok) {
          throw new Error(result.error);
        }
      }),
      export_csv: timeLoop(iterations, () => {
        const result = runExport(dataset, "csv", "text/csv", exportCsv);
        if (!result.ok) {
          throw new Error(result.error);
        }
      }),
    },
  };
}

async function main() {
  try {
    const raw = await readStdin();
    if (!raw.trim()) {
      stdout.write(JSON.stringify({ implementation: IMPLEMENTATION, results: {}, error: "empty request" }));
      process.exitCode = 1;
      return;
    }

    let request;
    try {
      request = JSON.parse(raw);
    } catch (error) {
      stdout.write(
        JSON.stringify({
          implementation: IMPLEMENTATION,
          results: {},
          error: `invalid request: ${error.message}`,
        }),
      );
      process.exitCode = 1;
      return;
    }

    const dataset = Object.prototype.hasOwnProperty.call(request, "dataset") ? request.dataset : null;
    const operations = Array.isArray(request.operations) ? request.operations : [];
    const results = {};

    if (shouldRun(operations, "validate")) {
      results.validate = { ok: true, errors: validateDataset(dataset) };
    }

    if (shouldRun(operations, "export_json")) {
      results.export_json = runExport(dataset, "json", "application/json", exportJson);
    }

    if (shouldRun(operations, "export_xml")) {
      results.export_xml = runExport(dataset, "xml", "application/xml", exportXml);
    }

    if (shouldRun(operations, "export_csv")) {
      results.export_csv = runExport(dataset, "csv", "text/csv", exportCsv);
    }

    if (shouldRun(operations, "benchmark")) {
      results.benchmark = runBenchmark(dataset, request?.benchmark?.iterations);
    }

    stdout.write(JSON.stringify({ implementation: IMPLEMENTATION, results }));
  } catch (error) {
    stdout.write(
      JSON.stringify({
        implementation: IMPLEMENTATION,
        results: {},
        error: error instanceof Error ? error.message : String(error),
      }),
    );
    process.exitCode = 1;
  }
}

await main();
