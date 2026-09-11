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

export class EducationError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "EducationError";
  }
}

export interface Education {
  id: number;
  name_th: string;
  name_en: string;
  description_th: string | null;
  description_en: string | null;
  start_date: string;
  end_date: string | null;
  media_type: MediaType | null;
  url: string | null;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListEducationFilter {
  is_active?: boolean;
}

export interface CreateEducationInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  start_date?: unknown;
  end_date?: unknown;
  media_type?: unknown;
  url?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

export interface UpdateEducationInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
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
  start_date,
  end_date,
  media_type,
  url,
  display_order,
  is_active,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new EducationError(400, result.message);
}

function isPgError(error: unknown): error is { code: string } {
  return typeof error === "object" && error !== null && "code" in error;
}

function rethrowEducationDbError(error: unknown): never {
  if (isPgError(error) && error.code === "23514") {
    throw new EducationError(
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
    throw new EducationError(
      400,
      "end_date must be on or after start_date"
    );
  }
}

async function getByIdForUpdate(
  client: PoolClient,
  id: number
): Promise<Education> {
  const result = await client.query<Education>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM education
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    throw new EducationError(404, "Education not found");
  }

  return result.rows[0];
}

export async function getEducationList(
  filter: ListEducationFilter = {}
): Promise<Education[]> {
  const conditions = ["deleted_at IS NULL"];
  const params: unknown[] = [];

  if (filter.is_active !== undefined) {
    params.push(filter.is_active);
    conditions.push(`is_active = $${params.length}`);
  }

  const result = await pool.query<Education>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM education
      WHERE ${conditions.join(" AND ")}
      ORDER BY display_order ASC, id ASC
    `,
    params
  );

  return result.rows;
}

export async function getEducationById(
  id: number
): Promise<Education | null> {
  const result = await pool.query<Education>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM education
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );
  return result.rows[0] ?? null;
}

export async function createEducation(
  input: CreateEducationInput
): Promise<Education> {
  const nameTh = parseRequiredString(input.name_th, "name_th");
  if (!nameTh.ok) fail(nameTh);

  const nameEn = parseRequiredString(input.name_en, "name_en");
  if (!nameEn.ok) fail(nameEn);

  const descriptionTh = parseOptionalString(input.description_th);
  const descriptionEn = parseOptionalString(input.description_en);

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

    const nextOrderResult = await client.query<{ next: number }>(
      `
        SELECT COALESCE(MAX(display_order), -1) + 1 AS next
        FROM education
        WHERE deleted_at IS NULL
      `
    );
    const nextOrder = Number(nextOrderResult.rows[0]?.next ?? 0);

    const inserted = await client.query<Education>(
      `
        INSERT INTO education (
          name_th, name_en, description_th, description_en,
          start_date, end_date, media_type, url, display_order, is_active
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        nameTh.value,
        nameEn.value,
        descriptionTh.provided ? descriptionTh.value : null,
        descriptionEn.provided ? descriptionEn.value : null,
        startDate.value,
        endDate.value,
        mediaType.value,
        url.provided ? url.value : null,
        nextOrder,
        isActive,
      ]
    );

    const row = inserted.rows[0];
    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "create",
        entityType: "education",
        entityId: row.id,
        message: `Created education ${row.name_en}`,
      },
      client
    );

    await client.query("COMMIT");
    return row;
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowEducationDbError(error);
  } finally {
    client.release();
  }
}

export async function updateEducation(
  id: number,
  input: UpdateEducationInput
): Promise<Education> {
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

    const updated = await client.query<Education>(
      `
        UPDATE education
        SET name_th = $2,
            name_en = $3,
            description_th = $4,
            description_en = $5,
            start_date = $6,
            end_date = $7,
            media_type = $8,
            url = $9,
            is_active = $10
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
        entityType: "education",
        entityId: id,
        message: `Updated education ${nextNameEn}`,
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowEducationDbError(error);
  } finally {
    client.release();
  }
}

export async function setEducationActive(
  id: number,
  isActiveRaw: unknown,
  adminId?: number | null
): Promise<Education> {
  const parsed = parseRequiredBoolean(isActiveRaw, "is_active");
  if (!parsed.ok) {
    throw new EducationError(400, parsed.message);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await getByIdForUpdate(client, id);

    const updated = await client.query<Education>(
      `
        UPDATE education
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
        entityType: "education",
        entityId: id,
        message: `Set education #${id} is_active=${parsed.value}`,
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

export async function softDeleteEducation(
  id: number,
  adminId?: number | null
): Promise<Education> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const updated = await client.query<Education>(
      `
        UPDATE education
        SET deleted_at = NOW(),
            is_active = FALSE
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id]
    );

    if (updated.rows.length === 0) {
      throw new EducationError(404, "Education not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "soft_delete",
        entityType: "education",
        entityId: id,
        message: `Soft deleted education #${id}`,
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

export async function hardDeleteEducation(
  id: number,
  adminId?: number | null
): Promise<{ id: number }> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const found = await client.query<{ id: number; name_en: string }>(
      `SELECT id, name_en FROM education WHERE id = $1 LIMIT 1`,
      [id]
    );

    if (found.rows.length === 0) {
      throw new EducationError(404, "Education not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "hard_delete",
        entityType: "education",
        entityId: id,
        message: `Hard deleted education ${found.rows[0].name_en}`,
      },
      client
    );

    await client.query(`DELETE FROM education WHERE id = $1`, [id]);
    await client.query("COMMIT");
    return { id };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function reorderEducation(
  orderedIdsRaw: unknown,
  adminId?: number | null
): Promise<Education[]> {
  if (!Array.isArray(orderedIdsRaw) || orderedIdsRaw.length === 0) {
    throw new EducationError(400, "ordered_ids is required");
  }

  const orderedIds: number[] = [];
  const seen = new Set<number>();
  for (const raw of orderedIdsRaw) {
    const id = toPositiveInt(raw);
    if (id === null) {
      throw new EducationError(400, "ordered_ids contains an invalid id");
    }
    if (seen.has(id)) {
      throw new EducationError(400, "ordered_ids must be unique");
    }
    seen.add(id);
    orderedIds.push(id);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const existing = await client.query<{ id: number }>(
      `
        SELECT id
        FROM education
        WHERE deleted_at IS NULL
          AND id = ANY($1::bigint[])
      `,
      [orderedIds]
    );

    const existingIds = new Set(existing.rows.map((row) => Number(row.id)));
    const validOrderedIds = orderedIds.filter((id) => existingIds.has(id));
    if (validOrderedIds.length === 0) {
      throw new EducationError(400, "No valid education to reorder");
    }

    for (let index = 0; index < validOrderedIds.length; index += 1) {
      await client.query(
        `
          UPDATE education
          SET display_order = $2
          WHERE id = $1
            AND deleted_at IS NULL
        `,
        [validOrderedIds[index], index]
      );
    }

    await insertAdminLog(
      {
        adminId,
        action: "update",
        entityType: "education",
        entityId: null,
        message: `Reordered ${validOrderedIds.length} education`,
      },
      client
    );

    await client.query("COMMIT");
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }

  return getEducationList();
}

export function parseEducationListFilter(query: {
  is_active?: unknown;
}): ListEducationFilter {
  const filter: ListEducationFilter = {};
  if (query.is_active !== undefined && String(query.is_active).trim() !== "") {
    const parsed = parseOptionalBoolean(query.is_active, "is_active");
    if ("ok" in parsed && parsed.ok === false) {
      throw new EducationError(400, parsed.message);
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
    throw new EducationError(400, "Invalid id");
  }
  return id;
}
