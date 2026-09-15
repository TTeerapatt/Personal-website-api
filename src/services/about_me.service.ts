import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import {
  parseOptionalString,
  parseRequiredBoolean,
} from "../utils/parse";

export class AboutMeError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "AboutMeError";
  }
}

export interface AboutMe {
  id: number;
  title_th: string;
  title_en: string;
  text_animation_th: string;
  text_animation_en: string;
  description_th: string | null;
  description_en: string | null;
  image_url: string | null;
  github_url: string | null;
  resume_url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface UpdateAboutMeInput {
  title_th?: unknown;
  title_en?: unknown;
  text_animation_th?: unknown;
  text_animation_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  image_url?: unknown;
  github_url?: unknown;
  resume_url?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  title_th,
  title_en,
  text_animation_th,
  text_animation_en,
  description_th,
  description_en,
  image_url,
  github_url,
  resume_url,
  is_active,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new AboutMeError(400, result.message);
}

function mapRow(row: Record<string, unknown>): AboutMe {
  return {
    id: Number(row.id),
    title_th: String(row.title_th ?? ""),
    title_en: String(row.title_en ?? ""),
    text_animation_th: String(row.text_animation_th ?? ""),
    text_animation_en: String(row.text_animation_en ?? ""),
    description_th:
      row.description_th == null ? null : String(row.description_th),
    description_en:
      row.description_en == null ? null : String(row.description_en),
    image_url: row.image_url == null ? null : String(row.image_url),
    github_url: row.github_url == null ? null : String(row.github_url),
    resume_url: row.resume_url == null ? null : String(row.resume_url),
    is_active: Boolean(row.is_active),
    created_at: String(row.created_at),
    updated_at: String(row.updated_at),
  };
}

function parseTextField(
  value: unknown,
  field: string,
  fallback: string
): string {
  if (value === undefined) return fallback;
  if (value === null) {
    throw new AboutMeError(400, `${field} must be a string`);
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
      INSERT INTO about_me (id)
      VALUES (1)
      ON CONFLICT (id) DO NOTHING
    `
  );
}

export async function getAboutMe(): Promise<AboutMe> {
  await ensureSingletonRow();

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM about_me
      WHERE id = 1
      LIMIT 1
    `
  );

  if (result.rows.length === 0) {
    throw new AboutMeError(500, "About Me row is missing");
  }

  return mapRow(result.rows[0]);
}

/** Public landing payload — only when content is active. */
export async function getPublicAboutMe(): Promise<AboutMe | null> {
  await ensureSingletonRow();

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM about_me
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

export async function updateAboutMe(
  input: UpdateAboutMeInput
): Promise<AboutMe> {
  await ensureSingletonRow();
  const current = await getAboutMe();

  const next = {
    title_th: parseTextField(input.title_th, "title_th", current.title_th),
    title_en: parseTextField(input.title_en, "title_en", current.title_en),
    text_animation_th: parseTextField(
      input.text_animation_th,
      "text_animation_th",
      current.text_animation_th
    ),
    text_animation_en: parseTextField(
      input.text_animation_en,
      "text_animation_en",
      current.text_animation_en
    ),
    description_th: parseNullableField(
      input.description_th,
      current.description_th
    ),
    description_en: parseNullableField(
      input.description_en,
      current.description_en
    ),
    image_url: parseNullableField(input.image_url, current.image_url),
    github_url: parseNullableField(input.github_url, current.github_url),
    resume_url: parseNullableField(input.resume_url, current.resume_url),
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
        UPDATE about_me
        SET
          title_th = $1,
          title_en = $2,
          text_animation_th = $3,
          text_animation_en = $4,
          description_th = $5,
          description_en = $6,
          image_url = $7,
          github_url = $8,
          resume_url = $9,
          is_active = $10
        WHERE id = 1
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        next.title_th,
        next.title_en,
        next.text_animation_th,
        next.text_animation_en,
        next.description_th,
        next.description_en,
        next.image_url,
        next.github_url,
        next.resume_url,
        next.is_active,
      ]
    );

    const row = mapRow(result.rows[0]);

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "about_me",
        entityId: 1,
        message: "Updated about me",
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
