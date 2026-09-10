import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import { parseRequiredBoolean } from "../utils/parse";

export class SiteSettingsError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "SiteSettingsError";
  }
}

export interface SiteSettings {
  id: number;
  show_banners: boolean;
  show_skills: boolean;
  show_projects: boolean;
  show_experiences: boolean;
  show_education: boolean;
  created_at: string;
  updated_at: string;
}

export interface UpdateSiteSettingsInput {
  show_banners?: unknown;
  show_skills?: unknown;
  show_projects?: unknown;
  show_experiences?: unknown;
  show_education?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  show_banners,
  show_skills,
  show_projects,
  show_experiences,
  show_education,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new SiteSettingsError(400, result.message);
}

function mapRow(row: Record<string, unknown>): SiteSettings {
  return {
    id: Number(row.id),
    show_banners: Boolean(row.show_banners),
    show_skills: Boolean(row.show_skills),
    show_projects: Boolean(row.show_projects),
    show_experiences: Boolean(row.show_experiences),
    show_education: Boolean(row.show_education),
    created_at: String(row.created_at),
    updated_at: String(row.updated_at),
  };
}

function parseShowFlag(
  value: unknown,
  field: string,
  fallback: boolean
): boolean {
  const parsed = parseRequiredBoolean(
    value !== undefined ? value : fallback,
    field
  );
  if (!parsed.ok) fail(parsed);
  return parsed.value;
}

async function ensureSingletonRow(): Promise<void> {
  await pool.query(
    `
      INSERT INTO site_settings (id)
      VALUES (1)
      ON CONFLICT (id) DO NOTHING
    `
  );
}

export async function getSiteSettings(): Promise<SiteSettings> {
  await ensureSingletonRow();

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM site_settings
      WHERE id = 1
      LIMIT 1
    `
  );

  if (result.rows.length === 0) {
    throw new SiteSettingsError(500, "Site settings row is missing");
  }

  return mapRow(result.rows[0]);
}

/** Public landing payload (same fields; no auth). */
export async function getPublicSiteSettings(): Promise<SiteSettings> {
  return getSiteSettings();
}

export async function updateSiteSettings(
  input: UpdateSiteSettingsInput
): Promise<SiteSettings> {
  await ensureSingletonRow();
  const current = await getSiteSettings();

  const next = {
    show_banners: parseShowFlag(
      input.show_banners,
      "show_banners",
      current.show_banners
    ),
    show_skills: parseShowFlag(
      input.show_skills,
      "show_skills",
      current.show_skills
    ),
    show_projects: parseShowFlag(
      input.show_projects,
      "show_projects",
      current.show_projects
    ),
    show_experiences: parseShowFlag(
      input.show_experiences,
      "show_experiences",
      current.show_experiences
    ),
    show_education: parseShowFlag(
      input.show_education,
      "show_education",
      current.show_education
    ),
  };

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const result = await client.query(
      `
        UPDATE site_settings
        SET
          show_banners = $1,
          show_skills = $2,
          show_projects = $3,
          show_experiences = $4,
          show_education = $5
        WHERE id = 1
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        next.show_banners,
        next.show_skills,
        next.show_projects,
        next.show_experiences,
        next.show_education,
      ]
    );

    const row = mapRow(result.rows[0]);

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "site_settings",
        entityId: 1,
        message: "Updated site settings",
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
