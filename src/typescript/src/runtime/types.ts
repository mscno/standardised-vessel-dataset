export type SvdObject = Record<string, unknown>;

export function asObject(value: unknown): SvdObject | null {
  if (value === null || value === undefined) {
    return null;
  }

  if (typeof value !== "object") {
    return null;
  }

  if (Array.isArray(value)) {
    return null;
  }

  return value as SvdObject;
}

export function readProperty(object: SvdObject, key: string): unknown {
  return Object.prototype.hasOwnProperty.call(object, key) ? object[key] : undefined;
}

export function readTrimmedString(object: SvdObject, key: string): string {
  const value = readProperty(object, key);
  if (typeof value !== "string") {
    return "";
  }
  return value.trim();
}
