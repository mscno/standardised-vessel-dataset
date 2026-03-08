import { asObject, readProperty, readTrimmedString } from "../runtime/types";
import { ValidationError } from "./ValidationError";

export class GeneralValidator {
  public validate(general: unknown): ValidationError[] {
    const generalObject = asObject(general);
    if (generalObject === null) {
      return [{ field: "General", message: "General is required", value: general }];
    }

    const errors: ValidationError[] = [];
    const imo = readTrimmedString(generalObject, "imo");
    const shipName = readTrimmedString(generalObject, "shipName");
    const shipReportingDate = readProperty(generalObject, "shipReportingDate");

    if (imo.length === 0) {
      errors.push({
        field: "General.Imo",
        message: "Imo is required",
        value: imo,
      });
    }

    if (!/^\d{7}$/.test(imo)) {
      errors.push({
        field: "General.Imo",
        message: "Imo must be seven digits.",
        value: imo,
      });
    }

    if (shipName.length === 0) {
      errors.push({
        field: "General.ShipName",
        message: "Ship Name is required",
        value: shipName,
      });
    }

    if (!isValidShipReportingDate(shipReportingDate)) {
      errors.push({
        field: "General.ShipReportingDate",
        message: "Ship Reporting Date (Datetime) must be greater than default.",
        value: shipReportingDate,
      });
    }

    return errors;
  }
}

function isValidShipReportingDate(value: unknown): boolean {
  const parsed = parseDate(value);
  if (parsed === null) {
    return false;
  }

  return parsed.getUTCFullYear() > 1;
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
