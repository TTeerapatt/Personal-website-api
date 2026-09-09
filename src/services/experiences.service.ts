import type { PoolClient } from "pg";
import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import {
  parseDateOnly,
  parseMediaType,
  parseOptionalBoolean,
  parseOptionalString,
  parseRequiredBoolean,
  parseRequiredString,
  toPositiveInt,
  type MediaType,
} from "../utils/parse";

export class ExperienceError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "ExperienceError";
  }
}

export interface Experience {
  id: number;
  name_th: string;
  name_en: string;
  description_th: string | null;
  description_en: string | null;
  position: string;
  start_date: string;
  end_date: string | null;
  media_type: MediaType | null;
  url: string | null;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListExperiencesFilter {
  is_active?: boolean;
}

export interface CreateExperienceInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  position?: unknown;
  start_date?: unknown;
  end_date?: unknown;
  media_type?: unknown;
  url?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

export interface UpdateExperienceInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  position?: unknown;
  start_date?: unknown;
  end_date?: unknown;
  media_type?: unknown;
  url?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  name_th,
  name_en,
  description_th,
  description_en,
  position,
  start_date,
  end_date,
  media_type,
  url,
  is_active,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new ExperienceError(400, result.message);
}

function isPgError(error: unknown): error is { code: string } {
  return typeof error === "object" && error !== null && "code" in error;
}

function rethrowExperienceDbError(error: unknown): never {
  if (isPgError(error) && error.code === "23514") {
    throw new ExperienceError(
      400,
      "end_date must be on or after start_date"
    );
  }
  throw error;
}

function assertDateRange(
  startDate: string,
  endDate: string | null
): void {
  if (endDate !== null && endDate < startDate) {
    throw new ExperienceError(
      400,
      "end_date must be on or after start_date"
    );
  }
}

async function getByIdForUpdate(
  client: PoolClient,
  id: number
): Promise<Experience> {
  const result = await client.query<Experience>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM experiences
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    throw new ExperienceError(404, "Experience not found");
  }

  return result.rows[0];
}

export async function getExperiences(
  filter: ListExperiencesFilter = {}
): Promise<Experience[]> {
  const conditions = ["deleted_at IS NULL"];
  const params: unknown[] = [];

  if (filter.is_active !== undefined) {
    params.push(filter.is_active);
    conditions.push(`is_active = $${params.length}`);
  }

  const result = await pool.query<Experience>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM experiences
      WHERE ${conditions.join(" AND ")}
      ORDER BY start_date DESC, id DESC
    `,
    params
  );

  return result.rows;
}

export async function getExperienceById(
  id: number
): Promise<Experience | null> {
  const result = await pool.query<Experience>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM experiences
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );
  return result.rows[0] ?? null;
}

export async function createExperience(
  input: CreateExperienceInput
): Promise<Experience> {
  const nameTh = parseRequiredString(input.name_th, "name_th");
  if (!nameTh.ok) fail(nameTh);

  const nameEn = parseRequiredString(input.name_en, "name_en");
  if (!nameEn.ok) fail(nameEn);

  const descriptionTh = parseOptionalString(input.description_th);
  const descriptionEn = parseOptionalString(input.description_en);

  const position = parseRequiredString(input.position, "position");
  if (!position.ok) fail(position);

  const startDate = parseDateOnly(input.start_date, "start_date", {
    required: true,
  });
  if (!startDate.ok) fail(startDate);

  const endDate = parseDateOnly(input.end_date, "end_date", {
    required: false,
  });
  if (!endDate.ok) fail(endDate);

  assertDateRange(startDate.value as string, endDate.value);

  const mediaType = parseMediaType(input.media_type, "media_type", {
    required: false,
    allowNull: true,
    allowed: ["image"],
  });
  if (!mediaType.ok) fail(mediaType);

  const url = parseOptionalString(input.url);

  let isActive = true;
  if (input.is_active !== undefined) {
    const parsed = parseRequiredBoolean(input.is_active, "is_active");
    if (!parsed.ok) fail(parsed);
    isActive = parsed.value;
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const inserted = await client.query<Experience>(
      `
        INSERT INTO experiences (
          name_th, name_en, description_th, description_en,
          position, start_date, end_date, media_type, url, is_active
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        nameTh.value,
        nameEn.value,
        descriptionTh.provided ? descriptionTh.value : null,
        descriptionEn.provided ? descriptionEn.value : null,
        position.value,
        startDate.value,
        endDate.value,
        mediaType.value,
        url.provided ? url.value : null,
        isActive,
      ]
    );

    const row = inserted.rows[0];
    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "create",
        entityType: "experience",
        entityId: row.id,
        message: `Created experience ${row.name_en}`,
      },
      client
    );

    await client.query("COMMIT");
    return row;
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowExperienceDbError(error);
  } finally {
    client.release();
  }
}

export async function updateExperience(
  id: number,
  input: UpdateExperienceInput
): Promise<Experience> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const existing = await getByIdForUpdate(client, id);

    let nextNameTh = existing.name_th;
    if (input.name_th !== undefined) {
      const nameTh = parseRequiredString(input.name_th, "name_th");
      if (!nameTh.ok) fail(nameTh);
      nextNameTh = nameTh.value;
    }

    let nextNameEn = existing.name_en;
    if (input.name_en !== undefined) {
      const nameEn = parseRequiredString(input.name_en, "name_en");
      if (!nameEn.ok) fail(nameEn);
      nextNameEn = nameEn.value;
    }

    let nextDescriptionTh = existing.description_th;
    if (input.description_th !== undefined) {
      const parsed = parseOptionalString(input.description_th);
      nextDescriptionTh = parsed.provided ? parsed.value : null;
    }

    let nextDescriptionEn = existing.description_en;
    if (input.description_en !== undefined) {
      const parsed = parseOptionalString(input.description_en);
      nextDescriptionEn = parsed.provided ? parsed.value : null;
    }

    let nextPosition = existing.position;
    if (input.position !== undefined) {
      const position = parseRequiredString(input.position, "position");
      if (!position.ok) fail(position);
      nextPosition = position.value;
    }

    let nextStartDate = String(existing.start_date).slice(0, 10);
    if (input.start_date !== undefined) {
      const startDate = parseDateOnly(input.start_date, "start_date", {
        required: true,
      });
      if (!startDate.ok) fail(startDate);
      nextStartDate = startDate.value as string;
    }

    let nextEndDate: string | null =
      existing.end_date === null
        ? null
        : String(existing.end_date).slice(0, 10);
    if (input.end_date !== undefined) {
      const endDate = parseDateOnly(input.end_date, "end_date", {
        required: false,
      });
      if (!endDate.ok) fail(endDate);
      nextEndDate = endDate.value;
    }

    assertDateRange(nextStartDate, nextEndDate);

    let nextMediaType: MediaType | null = existing.media_type;
    if (input.media_type !== undefined) {
      const mediaType = parseMediaType(input.media_type, "media_type", {
        required: false,
        allowNull: true,
        allowed: ["image"],
      });
      if (!mediaType.ok) fail(mediaType);
      nextMediaType = mediaType.value;
    }

    let nextUrl = existing.url;
    if (input.url !== undefined) {
      const parsed = parseOptionalString(input.url);
      nextUrl = parsed.provided ? parsed.value : null;
    }

    let nextIsActive = existing.is_active;
    if (input.is_active !== undefined) {
      const parsed = parseRequiredBoolean(input.is_active, "is_active");
      if (!parsed.ok) fail(parsed);
      nextIsActive = parsed.value;
    }

    const updated = await client.query<Experience>(
      `
        UPDATE experiences
        SET name_th = $2,
            name_en = $3,
            description_th = $4,
            description_en = $5,
            position = $6,
            start_date = $7,
            end_date = $8,
            media_type = $9,
            url = $10,
            is_active = $11
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        id,
        nextNameTh,
        nextNameEn,
        nextDescriptionTh,
        nextDescriptionEn,
        nextPosition,
        nextStartDate,
        nextEndDate,
        nextMediaType,
        nextUrl,
        nextIsActive,
      ]
    );

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "experience",
        entityId: id,
        message: `Updated experience ${nextNameEn}`,
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowExperienceDbError(error);
  } finally {
    client.release();
  }
}

export async function setExperienceActive(
  id: number,
  isActiveRaw: unknown,
  adminId?: number | null
): Promise<Experience> {
  const parsed = parseRequiredBoolean(isActiveRaw, "is_active");
  if (!parsed.ok) {
    throw new ExperienceError(400, parsed.message);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await getByIdForUpdate(client, id);

    const updated = await client.query<Experience>(
      `
        UPDATE experiences
        SET is_active = $2
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id, parsed.value]
    );

    await insertAdminLog(
      {
        adminId,
        action: "set_active",
        entityType: "experience",
        entityId: id,
        message: `Set experience #${id} is_active=${parsed.value}`,
        meta: { is_active: parsed.value },
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function softDeleteExperience(
  id: number,
  adminId?: number | null
): Promise<Experience> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const updated = await client.query<Experience>(
      `
        UPDATE experiences
        SET deleted_at = NOW(),
            is_active = FALSE
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id]
    );

    if (updated.rows.length === 0) {
      throw new ExperienceError(404, "Experience not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "soft_delete",
        entityType: "experience",
        entityId: id,
        message: `Soft deleted experience #${id}`,
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function hardDeleteExperience(
  id: number,
  adminId?: number | null
): Promise<{ id: number }> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const found = await client.query<{ id: number; name_en: string }>(
      `SELECT id, name_en FROM experiences WHERE id = $1 LIMIT 1`,
      [id]
    );

    if (found.rows.length === 0) {
      throw new ExperienceError(404, "Experience not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "hard_delete",
        entityType: "experience",
        entityId: id,
        message: `Hard deleted experience ${found.rows[0].name_en}`,
      },
      client
    );

    await client.query(`DELETE FROM experiences WHERE id = $1`, [id]);
    await client.query("COMMIT");
    return { id };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export function parseExperienceListFilter(query: {
  is_active?: unknown;
}): ListExperiencesFilter {
  const filter: ListExperiencesFilter = {};
  if (query.is_active !== undefined && String(query.is_active).trim() !== "") {
    const parsed = parseOptionalBoolean(query.is_active, "is_active");
    if ("ok" in parsed && parsed.ok === false) {
      throw new ExperienceError(400, parsed.message);
    }
    if ("provided" in parsed && parsed.provided) {
      filter.is_active = parsed.value;
    }
  }
  return filter;
}

export function parseIdOrThrow(value: string): number {
  const id = toPositiveInt(value);
  if (id === null) {
    throw new ExperienceError(400, "Invalid id");
  }
  return id;
}
