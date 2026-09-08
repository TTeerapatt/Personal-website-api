import type { PoolClient } from "pg";
import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import {
  parseDisplayOrder,
  parseMediaType,
  parseOptionalBoolean,
  parseRequiredBoolean,
  parseRequiredString,
  toPositiveInt,
  type MediaType,
} from "../utils/parse";

export class SkillError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "SkillError";
  }
}

export interface Skill {
  id: number;
  name: string;
  media_type: MediaType;
  url: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListSkillsFilter {
  is_active?: boolean;
}

export interface CreateSkillInput {
  name?: unknown;
  media_type?: unknown;
  url?: unknown;
  display_order?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

export interface UpdateSkillInput {
  name?: unknown;
  media_type?: unknown;
  url?: unknown;
  display_order?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  name,
  media_type,
  url,
  display_order,
  is_active,
  created_at,
  updated_at
`;

const SKILL_MEDIA_TYPES = ["image"] as const;

function fail(result: { ok: false; message: string }): never {
  throw new SkillError(400, result.message);
}

function isPgError(error: unknown): error is { code: string } {
  return typeof error === "object" && error !== null && "code" in error;
}

function rethrowSkillDbError(error: unknown): never {
  if (isPgError(error) && error.code === "23505") {
    throw new SkillError(409, "Skill already exists");
  }
  throw error;
}

async function getNextDisplayOrder(client: PoolClient): Promise<number> {
  const result = await client.query<{ next: number }>(
    `
      SELECT COALESCE(MAX(display_order), -1) + 1 AS next
      FROM skills
      WHERE deleted_at IS NULL
    `
  );
  return Number(result.rows[0]?.next ?? 0);
}

async function getByIdForUpdate(
  client: PoolClient,
  id: number
): Promise<Skill> {
  const result = await client.query<Skill>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM skills
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    throw new SkillError(404, "Skill not found");
  }

  return result.rows[0];
}

export async function getSkills(
  filter: ListSkillsFilter = {}
): Promise<Skill[]> {
  const conditions = ["deleted_at IS NULL"];
  const params: unknown[] = [];

  if (filter.is_active !== undefined) {
    params.push(filter.is_active);
    conditions.push(`is_active = $${params.length}`);
  }

  const result = await pool.query<Skill>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM skills
      WHERE ${conditions.join(" AND ")}
      ORDER BY display_order ASC, id ASC
    `,
    params
  );

  return result.rows;
}

export async function getSkillById(id: number): Promise<Skill | null> {
  const result = await pool.query<Skill>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM skills
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );
  return result.rows[0] ?? null;
}

export async function createSkill(input: CreateSkillInput): Promise<Skill> {
  const name = parseRequiredString(input.name, "name");
  if (!name.ok) fail(name);

  const mediaType = parseMediaType(input.media_type ?? "image", "media_type", {
    required: true,
    allowed: SKILL_MEDIA_TYPES,
  });
  if (!mediaType.ok) fail(mediaType);

  const url = parseRequiredString(input.url, "url");
  if (!url.ok) fail(url);

  let isActive = true;
  if (input.is_active !== undefined) {
    const parsed = parseRequiredBoolean(input.is_active, "is_active");
    if (!parsed.ok) fail(parsed);
    isActive = parsed.value;
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const nextOrder = await getNextDisplayOrder(client);

    const inserted = await client.query<Skill>(
      `
        INSERT INTO skills (
          name, media_type, url, display_order, is_active
        )
        VALUES ($1, $2, $3, $4, $5)
        RETURNING ${SELECT_COLUMNS}
      `,
      [name.value, mediaType.value, url.value, nextOrder, isActive]
    );

    const row = inserted.rows[0];
    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "create",
        entityType: "skill",
        entityId: row.id,
        message: `Created skill ${row.name}`,
      },
      client
    );

    await client.query("COMMIT");
    return row;
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowSkillDbError(error);
  } finally {
    client.release();
  }
}

export async function updateSkill(
  id: number,
  input: UpdateSkillInput
): Promise<Skill> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    const existing = await getByIdForUpdate(client, id);

    let nextName = existing.name;
    if (input.name !== undefined) {
      const name = parseRequiredString(input.name, "name");
      if (!name.ok) fail(name);
      nextName = name.value;
    }

    let nextMediaType: MediaType = "image";
    if (input.media_type !== undefined) {
      const mediaType = parseMediaType(input.media_type, "media_type", {
        required: true,
        allowed: SKILL_MEDIA_TYPES,
      });
      if (!mediaType.ok) fail(mediaType);
      nextMediaType = mediaType.value as MediaType;
    }

    let nextUrl = existing.url;
    if (input.url !== undefined) {
      const url = parseRequiredString(input.url, "url");
      if (!url.ok) fail(url);
      nextUrl = url.value;
    }

    let nextDisplayOrder = existing.display_order;
    if (input.display_order !== undefined) {
      const displayOrder = parseDisplayOrder(
        input.display_order,
        existing.display_order
      );
      if (!displayOrder.ok) fail(displayOrder);
      nextDisplayOrder = displayOrder.value;
    }

    let nextIsActive = existing.is_active;
    if (input.is_active !== undefined) {
      const parsed = parseRequiredBoolean(input.is_active, "is_active");
      if (!parsed.ok) fail(parsed);
      nextIsActive = parsed.value;
    }

    const updated = await client.query<Skill>(
      `
        UPDATE skills
        SET name = $2,
            media_type = $3,
            url = $4,
            display_order = $5,
            is_active = $6
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        id,
        nextName,
        nextMediaType,
        nextUrl,
        nextDisplayOrder,
        nextIsActive,
      ]
    );

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "skill",
        entityId: id,
        message: `Updated skill ${nextName}`,
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowSkillDbError(error);
  } finally {
    client.release();
  }
}

export async function setSkillActive(
  id: number,
  isActiveRaw: unknown,
  adminId?: number | null
): Promise<Skill> {
  const parsed = parseRequiredBoolean(isActiveRaw, "is_active");
  if (!parsed.ok) {
    throw new SkillError(400, parsed.message);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await getByIdForUpdate(client, id);

    const updated = await client.query<Skill>(
      `
        UPDATE skills
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
        entityType: "skill",
        entityId: id,
        message: `Set skill #${id} is_active=${parsed.value}`,
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

export async function softDeleteSkill(
  id: number,
  adminId?: number | null
): Promise<Skill> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const updated = await client.query<Skill>(
      `
        UPDATE skills
        SET deleted_at = NOW(),
            is_active = FALSE
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id]
    );

    if (updated.rows.length === 0) {
      throw new SkillError(404, "Skill not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "soft_delete",
        entityType: "skill",
        entityId: id,
        message: `Soft deleted skill #${id}`,
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

export async function hardDeleteSkill(
  id: number,
  adminId?: number | null
): Promise<{ id: number }> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const found = await client.query<{ id: number; name: string }>(
      `SELECT id, name FROM skills WHERE id = $1 LIMIT 1`,
      [id]
    );

    if (found.rows.length === 0) {
      throw new SkillError(404, "Skill not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "hard_delete",
        entityType: "skill",
        entityId: id,
        message: `Hard deleted skill ${found.rows[0].name}`,
      },
      client
    );

    await client.query(`DELETE FROM skills WHERE id = $1`, [id]);
    await client.query("COMMIT");
    return { id };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function reorderSkills(
  orderedIdsRaw: unknown,
  adminId?: number | null
): Promise<Skill[]> {
  if (!Array.isArray(orderedIdsRaw) || orderedIdsRaw.length === 0) {
    throw new SkillError(400, "ordered_ids is required");
  }

  const orderedIds: number[] = [];
  const seen = new Set<number>();
  for (const raw of orderedIdsRaw) {
    const id = toPositiveInt(raw);
    if (id === null) {
      throw new SkillError(400, "ordered_ids contains an invalid id");
    }
    if (seen.has(id)) {
      throw new SkillError(400, "ordered_ids must be unique");
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
        FROM skills
        WHERE deleted_at IS NULL
          AND id = ANY($1::bigint[])
      `,
      [orderedIds]
    );

    const existingIds = new Set(existing.rows.map((row) => Number(row.id)));
    const validOrderedIds = orderedIds.filter((id) => existingIds.has(id));
    if (validOrderedIds.length === 0) {
      throw new SkillError(400, "No valid skills to reorder");
    }

    for (let index = 0; index < validOrderedIds.length; index += 1) {
      await client.query(
        `
          UPDATE skills
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
        entityType: "skill",
        entityId: null,
        message: `Reordered ${validOrderedIds.length} skills`,
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

  return getSkills();
}

export function parseSkillListFilter(query: {
  is_active?: unknown;
}): ListSkillsFilter {
  const filter: ListSkillsFilter = {};

  if (query.is_active !== undefined && String(query.is_active).trim() !== "") {
    const parsed = parseOptionalBoolean(query.is_active, "is_active");
    if ("ok" in parsed && parsed.ok === false) {
      throw new SkillError(400, parsed.message);
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
    throw new SkillError(400, "Invalid id");
  }
  return id;
}
