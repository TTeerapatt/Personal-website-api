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

export class HomeBannerError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "HomeBannerError";
  }
}

export interface HomeBanner {
  id: number;
  name: string;
  media_type: MediaType;
  url: string;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListHomeBannersFilter {
  is_active?: boolean;
}

export interface CreateHomeBannerInput {
  name?: unknown;
  media_type?: unknown;
  url?: unknown;
  display_order?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

export interface UpdateHomeBannerInput {
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

function fail(
  result: { ok: false; message: string }
): never {
  throw new HomeBannerError(400, result.message);
}

async function getByIdForUpdate(
  client: PoolClient,
  id: number
): Promise<HomeBanner> {
  const result = await client.query<HomeBanner>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM home_banners
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    throw new HomeBannerError(404, "Home banner not found");
  }

  return result.rows[0];
}

export async function getActiveHomeBanners(
  filter: ListHomeBannersFilter = {}
): Promise<HomeBanner[]> {
  const conditions = ["deleted_at IS NULL"];
  const params: unknown[] = [];

  if (filter.is_active !== undefined) {
    params.push(filter.is_active);
    conditions.push(`is_active = $${params.length}`);
  }

  const result = await pool.query<HomeBanner>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM home_banners
      WHERE ${conditions.join(" AND ")}
      ORDER BY display_order ASC, id ASC
    `,
    params
  );

  return result.rows;
}

export async function getActiveHomeBannerById(
  id: number
): Promise<HomeBanner | null> {
  const result = await pool.query<HomeBanner>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM home_banners
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );
  return result.rows[0] ?? null;
}

const HOME_BANNER_MEDIA_TYPES = ["image", "video"] as const;

async function getNextDisplayOrder(client: PoolClient): Promise<number> {
  const result = await client.query<{ next: number }>(
    `
      SELECT COALESCE(MAX(display_order), -1) + 1 AS next
      FROM home_banners
      WHERE deleted_at IS NULL
    `
  );
  return Number(result.rows[0]?.next ?? 0);
}

export async function createHomeBanner(
  input: CreateHomeBannerInput
): Promise<HomeBanner> {
  const name = parseRequiredString(input.name, "name");
  if (!name.ok) fail(name);

  const mediaType = parseMediaType(input.media_type, "media_type", {
    required: true,
    allowed: HOME_BANNER_MEDIA_TYPES,
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

    const inserted = await client.query<HomeBanner>(
      `
        INSERT INTO home_banners (
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
        entityType: "home_banner",
        entityId: row.id,
        message: `Created home banner ${row.name}`,
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

export async function updateHomeBanner(
  id: number,
  input: UpdateHomeBannerInput
): Promise<HomeBanner> {
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

    let nextMediaType: MediaType = existing.media_type;
    if (input.media_type !== undefined) {
      const mediaType = parseMediaType(input.media_type, "media_type", {
        required: true,
        allowed: HOME_BANNER_MEDIA_TYPES,
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

    const updated = await client.query<HomeBanner>(
      `
        UPDATE home_banners
        SET name = $2,
            media_type = $3,
            url = $4,
            display_order = $5,
            is_active = $6
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id, nextName, nextMediaType, nextUrl, nextDisplayOrder, nextIsActive]
    );

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "home_banner",
        entityId: id,
        message: `Updated home banner ${nextName}`,
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

export async function setHomeBannerActive(
  id: number,
  isActiveRaw: unknown,
  adminId?: number | null
): Promise<HomeBanner> {
  const parsed = parseRequiredBoolean(isActiveRaw, "is_active");
  if (!parsed.ok) {
    throw new HomeBannerError(400, parsed.message);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await getByIdForUpdate(client, id);

    const updated = await client.query<HomeBanner>(
      `
        UPDATE home_banners
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
        entityType: "home_banner",
        entityId: id,
        message: `Set home banner #${id} is_active=${parsed.value}`,
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

export async function softDeleteHomeBanner(
  id: number,
  adminId?: number | null
): Promise<HomeBanner> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const updated = await client.query<HomeBanner>(
      `
        UPDATE home_banners
        SET deleted_at = NOW(),
            is_active = FALSE
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id]
    );

    if (updated.rows.length === 0) {
      throw new HomeBannerError(404, "Home banner not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "soft_delete",
        entityType: "home_banner",
        entityId: id,
        message: `Soft deleted home banner #${id}`,
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

export async function hardDeleteHomeBanner(
  id: number,
  adminId?: number | null
): Promise<{ id: number }> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const found = await client.query<{ id: number; name: string }>(
      `SELECT id, name FROM home_banners WHERE id = $1 LIMIT 1`,
      [id]
    );

    if (found.rows.length === 0) {
      throw new HomeBannerError(404, "Home banner not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "hard_delete",
        entityType: "home_banner",
        entityId: id,
        message: `Hard deleted home banner ${found.rows[0].name}`,
      },
      client
    );

    await client.query(`DELETE FROM home_banners WHERE id = $1`, [id]);
    await client.query("COMMIT");
    return { id };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export async function reorderHomeBanners(
  orderedIdsRaw: unknown,
  adminId?: number | null
): Promise<HomeBanner[]> {
  if (!Array.isArray(orderedIdsRaw) || orderedIdsRaw.length === 0) {
    throw new HomeBannerError(400, "ordered_ids is required");
  }

  const orderedIds: number[] = [];
  const seen = new Set<number>();
  for (const raw of orderedIdsRaw) {
    const id = toPositiveInt(raw);
    if (id === null) {
      throw new HomeBannerError(400, "ordered_ids contains an invalid id");
    }
    if (seen.has(id)) {
      throw new HomeBannerError(400, "ordered_ids must be unique");
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
        FROM home_banners
        WHERE deleted_at IS NULL
        ORDER BY display_order ASC, id ASC
      `
    );
    const existingIds = existing.rows.map((row) => Number(row.id));
    const existingSet = new Set(existingIds);

    const validOrderedIds = orderedIds.filter((id) => existingSet.has(id));
    if (validOrderedIds.length === 0) {
      throw new HomeBannerError(400, "No valid home banners to reorder");
    }

    // Keep any active banners missing from the payload at the end (stable).
    const orderedSet = new Set(validOrderedIds);
    for (const id of existingIds) {
      if (!orderedSet.has(id)) {
        validOrderedIds.push(id);
      }
    }

    for (let index = 0; index < validOrderedIds.length; index += 1) {
      await client.query(
        `
          UPDATE home_banners
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
        entityType: "home_banner",
        entityId: null,
        message: `Reordered ${validOrderedIds.length} home banners`,
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

  return getActiveHomeBanners();
}

export function parseHomeBannerListFilter(query: {
  is_active?: unknown;
}): ListHomeBannersFilter {
  const filter: ListHomeBannersFilter = {};
  if (query.is_active !== undefined && String(query.is_active).trim() !== "") {
    const parsed = parseOptionalBoolean(query.is_active, "is_active");
    if ("ok" in parsed && parsed.ok === false) {
      throw new HomeBannerError(400, parsed.message);
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
    throw new HomeBannerError(400, "Invalid id");
  }
  return id;
}
