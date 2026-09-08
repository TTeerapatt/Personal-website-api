export const MEDIA_TYPES = ["image", "video"] as const;
export type MediaType = (typeof MEDIA_TYPES)[number];

export function toPositiveInt(value: unknown): number | null {
  const n = Number(value);
  if (!Number.isInteger(n) || n <= 0) {
    return null;
  }
  return n;
}

export function toTrimmedString(value: unknown): string | null {
  if (value === undefined || value === null) {
    return null;
  }
  const text = String(value).trim();
  return text === "" ? null : text;
}

export function parseRequiredString(
  value: unknown,
  field: string
): { ok: true; value: string } | { ok: false; message: string } {
  const text = toTrimmedString(value);
  if (!text) {
    return { ok: false, message: `${field} is required` };
  }
  return { ok: true, value: text };
}

export function parseOptionalString(
  value: unknown
): { provided: false } | { provided: true; value: string | null } {
  if (value === undefined) {
    return { provided: false };
  }
  if (value === null) {
    return { provided: true, value: null };
  }
  const text = String(value).trim();
  return { provided: true, value: text === "" ? null : text };
}

export function parseMediaType(
  value: unknown,
  field = "media_type",
  options: {
    required: boolean;
    allowNull?: boolean;
    allowed?: readonly MediaType[];
  } = { required: true }
):
  | { ok: true; value: MediaType | null }
  | { ok: false; message: string } {
  const allowed = options.allowed ?? MEDIA_TYPES;

  if (value === undefined || value === null || String(value).trim() === "") {
    if (options.required) {
      return { ok: false, message: `${field} is required` };
    }
    if (options.allowNull || value === null || value === undefined) {
      return { ok: true, value: null };
    }
  }

  const raw = String(value).trim().toLowerCase();
  if (!(allowed as readonly string[]).includes(raw)) {
    return {
      ok: false,
      message: `${field} must be one of: ${allowed.join(", ")}`,
    };
  }
  return { ok: true, value: raw as MediaType };
}

export function parseDisplayOrder(
  value: unknown,
  fallback = 0
): { ok: true; value: number } | { ok: false; message: string } {
  if (value === undefined || value === null || String(value).trim() === "") {
    return { ok: true, value: fallback };
  }
  const n = Number(value);
  if (!Number.isInteger(n)) {
    return { ok: false, message: "display_order must be an integer" };
  }
  return { ok: true, value: n };
}

export function parseOptionalBoolean(
  value: unknown,
  field: string
):
  | { provided: false }
  | { provided: true; value: boolean }
  | { ok: false; message: string } {
  if (value === undefined) {
    return { provided: false };
  }
  if (typeof value === "boolean") {
    return { provided: true, value };
  }
  if (typeof value === "number" && (value === 0 || value === 1)) {
    return { provided: true, value: value === 1 };
  }
  if (typeof value === "string") {
    const raw = value.trim().toLowerCase();
    if (raw === "true" || raw === "1") {
      return { provided: true, value: true };
    }
    if (raw === "false" || raw === "0") {
      return { provided: true, value: false };
    }
  }
  return { ok: false, message: `${field} must be a boolean` };
}

export function parseRequiredBoolean(
  value: unknown,
  field: string
): { ok: true; value: boolean } | { ok: false; message: string } {
  const parsed = parseOptionalBoolean(value, field);
  if ("ok" in parsed && parsed.ok === false) {
    return parsed;
  }
  if (!("provided" in parsed) || !parsed.provided) {
    return { ok: false, message: `${field} is required` };
  }
  return { ok: true, value: parsed.value };
}

export function parseDateOnly(
  value: unknown,
  field: string,
  options: { required: boolean } = { required: true }
):
  | { ok: true; value: string | null }
  | { ok: false; message: string } {
  if (value === undefined || value === null || String(value).trim() === "") {
    if (options.required) {
      return { ok: false, message: `${field} is required` };
    }
    return { ok: true, value: null };
  }

  const raw = String(value).trim();
  if (!/^\d{4}-\d{2}-\d{2}$/.test(raw)) {
    return { ok: false, message: `${field} must be YYYY-MM-DD` };
  }

  const date = new Date(`${raw}T00:00:00.000Z`);
  if (Number.isNaN(date.getTime()) || date.toISOString().slice(0, 10) !== raw) {
    return { ok: false, message: `${field} is invalid` };
  }

  return { ok: true, value: raw };
}

export function parseQueryBoolean(
  value: unknown
): boolean | undefined {
  if (value === undefined || value === null || String(value).trim() === "") {
    return undefined;
  }
  const parsed = parseOptionalBoolean(value, "is_active");
  if ("ok" in parsed && parsed.ok === false) {
    return undefined;
  }
  if ("provided" in parsed && parsed.provided) {
    return parsed.value;
  }
  return undefined;
}
