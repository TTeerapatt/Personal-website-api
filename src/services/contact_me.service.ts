import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import {
  parseOptionalString,
  parseRequiredBoolean,
} from "../utils/parse";

export class ContactMeError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "ContactMeError";
  }
}

export interface ContactMe {
  id: number;
  name_th: string;
  name_en: string;
  phone: string | null;
  email: string;
  github_url: string | null;
  linkedin_url: string | null;
  facebook_url: string | null;
  instagram_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface UpdateContactMeInput {
  name_th?: unknown;
  name_en?: unknown;
  phone?: unknown;
  email?: unknown;
  github_url?: unknown;
  linkedin_url?: unknown;
  facebook_url?: unknown;
  instagram_url?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  name_th,
  name_en,
  phone,
  email,
  github_url,
  linkedin_url,
  facebook_url,
  instagram_url,
  is_active,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new ContactMeError(400, result.message);
}

function toIsoTimestamp(value: unknown): string {
  if (value instanceof Date) {
    return value.toISOString();
  }
  const date = new Date(String(value));
  if (!Number.isNaN(date.getTime())) {
    return date.toISOString();
  }
  return String(value);
}

function mapRow(row: Record<string, unknown>): ContactMe {
  return {
    id: Number(row.id),
    name_th: String(row.name_th ?? ""),
    name_en: String(row.name_en ?? ""),
    phone: row.phone == null || row.phone === "" ? null : String(row.phone),
    email: String(row.email ?? ""),
    github_url: row.github_url == null ? null : String(row.github_url),
    linkedin_url: row.linkedin_url == null ? null : String(row.linkedin_url),
    facebook_url: row.facebook_url == null ? null : String(row.facebook_url),
    instagram_url:
      row.instagram_url == null ? null : String(row.instagram_url),
    is_active: Boolean(row.is_active),
    created_at: toIsoTimestamp(row.created_at),
    updated_at: toIsoTimestamp(row.updated_at),
  };
}

function parseTextField(
  value: unknown,
  field: string,
  fallback: string
): string {
  if (value === undefined) return fallback;
  if (value === null) {
    throw new ContactMeError(400, `${field} must be a string`);
  }
  return String(value).trim();
}

function parseNullableField(
  value: unknown,
  fallback: string | null
): string | null {
  const parsed = parseOptionalString(value);
  if (!parsed.provided) return fallback;
  return parsed.value;
}

async function ensureSingletonRow(): Promise<void> {
  await pool.query(
    `
      INSERT INTO contact_me (id)
      VALUES (1)
      ON CONFLICT (id) DO NOTHING
    `
  );
}

export async function getContactMe(): Promise<ContactMe> {
  await ensureSingletonRow();

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM contact_me
      WHERE id = 1
      LIMIT 1
    `
  );

  if (result.rows.length === 0) {
    throw new ContactMeError(500, "Contact Me row is missing");
  }

  return mapRow(result.rows[0]);
}

/** Public landing payload — only when content is active. */
export async function getPublicContactMe(): Promise<ContactMe | null> {
  await ensureSingletonRow();

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM contact_me
      WHERE id = 1
        AND is_active = TRUE
      LIMIT 1
    `
  );

  if (result.rows.length === 0) {
    return null;
  }

  return mapRow(result.rows[0]);
}

export async function updateContactMe(
  input: UpdateContactMeInput
): Promise<ContactMe> {
  await ensureSingletonRow();
  const current = await getContactMe();

  const next = {
    name_th: parseTextField(input.name_th, "name_th", current.name_th),
    name_en: parseTextField(input.name_en, "name_en", current.name_en),
    phone: parseNullableField(input.phone, current.phone),
    email: parseTextField(input.email, "email", current.email),
    github_url: parseNullableField(input.github_url, current.github_url),
    linkedin_url: parseNullableField(input.linkedin_url, current.linkedin_url),
    facebook_url: parseNullableField(input.facebook_url, current.facebook_url),
    instagram_url: parseNullableField(
      input.instagram_url,
      current.instagram_url
    ),
    is_active: (() => {
      if (input.is_active === undefined) return current.is_active;
      const parsed = parseRequiredBoolean(input.is_active, "is_active");
      if (!parsed.ok) fail(parsed);
      return parsed.value;
    })(),
  };

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const result = await client.query(
      `
        UPDATE contact_me
        SET
          name_th = $1,
          name_en = $2,
          phone = $3,
          email = $4,
          github_url = $5,
          linkedin_url = $6,
          facebook_url = $7,
          instagram_url = $8,
          is_active = $9
        WHERE id = 1
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        next.name_th,
        next.name_en,
        next.phone,
        next.email,
        next.github_url,
        next.linkedin_url,
        next.facebook_url,
        next.instagram_url,
        next.is_active,
      ]
    );

    const row = mapRow(result.rows[0]);

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "contact_me",
        entityId: 1,
        message: "Updated contact me",
      },
      client
    );

    await client.query("COMMIT");
    return row;
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}
