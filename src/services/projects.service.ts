import type { PoolClient } from "pg";
import pool from "../config/database.config";
import { insertAdminLog } from "./admin_log.service";
import {
  parseDisplayOrder,
  parseOptionalBoolean,
  parseOptionalString,
  parseRequiredBoolean,
  parseRequiredString,
  toPositiveInt,
} from "../utils/parse";

export class ProjectError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "ProjectError";
  }
}

export interface Project {
  id: number;
  name_th: string;
  name_en: string;
  description_th: string | null;
  description_en: string | null;
  thumbnail_url: string | null;
  github_url: string | null;
  demo_url: string | null;
  display_order: number;
  is_active: boolean;
  created_at: string;
  updated_at: string;
}

export interface ListProjectsFilter {
  is_active?: boolean;
}

export interface CreateProjectInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  thumbnail_url?: unknown;
  github_url?: unknown;
  demo_url?: unknown;
  display_order?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

export interface UpdateProjectInput {
  name_th?: unknown;
  name_en?: unknown;
  description_th?: unknown;
  description_en?: unknown;
  thumbnail_url?: unknown;
  github_url?: unknown;
  demo_url?: unknown;
  display_order?: unknown;
  is_active?: unknown;
  adminId?: number | null;
}

const SELECT_COLUMNS = `
  id,
  name_th,
  name_en,
  description_th,
  description_en,
  thumbnail_url,
  github_url,
  demo_url,
  display_order,
  is_active,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new ProjectError(400, result.message);
}

function isPgError(error: unknown): error is { code: string } {
  return typeof error === "object" && error !== null && "code" in error;
}

function rethrowProjectDbError(error: unknown): never {
  if (isPgError(error) && error.code === "23505") {
    throw new ProjectError(409, "Project already exists");
  }
  throw error;
}

async function getByIdForUpdate(
  client: PoolClient,
  id: number
): Promise<Project> {
  const result = await client.query<Project>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM projects
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );

  if (result.rows.length === 0) {
    throw new ProjectError(404, "Project not found");
  }

  return result.rows[0];
}

export async function getProjects(
  filter: ListProjectsFilter = {}
): Promise<Project[]> {
  const conditions = ["deleted_at IS NULL"];
  const params: unknown[] = [];

  if (filter.is_active !== undefined) {
    params.push(filter.is_active);
    conditions.push(`is_active = $${params.length}`);
  }

  const result = await pool.query<Project>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM projects
      WHERE ${conditions.join(" AND ")}
      ORDER BY display_order ASC, id ASC
    `,
    params
  );

  return result.rows;
}

export async function getProjectById(id: number): Promise<Project | null> {
  const result = await pool.query<Project>(
    `
      SELECT ${SELECT_COLUMNS}
      FROM projects
      WHERE id = $1
        AND deleted_at IS NULL
      LIMIT 1
    `,
    [id]
  );
  return result.rows[0] ?? null;
}

export async function createProject(
  input: CreateProjectInput
): Promise<Project> {
  const nameTh = parseRequiredString(input.name_th, "name_th");
  if (!nameTh.ok) fail(nameTh);

  const nameEn = parseRequiredString(input.name_en, "name_en");
  if (!nameEn.ok) fail(nameEn);

  const descriptionTh = parseOptionalString(input.description_th);
  const descriptionEn = parseOptionalString(input.description_en);
  const thumbnailUrl = parseOptionalString(input.thumbnail_url);
  const githubUrl = parseOptionalString(input.github_url);
  const demoUrl = parseOptionalString(input.demo_url);

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
        FROM projects
        WHERE deleted_at IS NULL
      `
    );
    const nextOrder = Number(nextOrderResult.rows[0]?.next ?? 0);

    const inserted = await client.query<Project>(
      `
        INSERT INTO projects (
          name_th, name_en, description_th, description_en,
          thumbnail_url, github_url, demo_url, display_order, is_active
        )
        VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        RETURNING ${SELECT_COLUMNS}
      `,
      [
        nameTh.value,
        nameEn.value,
        descriptionTh.provided ? descriptionTh.value : null,
        descriptionEn.provided ? descriptionEn.value : null,
        thumbnailUrl.provided ? thumbnailUrl.value : null,
        githubUrl.provided ? githubUrl.value : null,
        demoUrl.provided ? demoUrl.value : null,
        nextOrder,
        isActive,
      ]
    );

    const row = inserted.rows[0];
    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "create",
        entityType: "project",
        entityId: row.id,
        message: `Created project ${row.name_en}`,
      },
      client
    );

    await client.query("COMMIT");
    return row;
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowProjectDbError(error);
  } finally {
    client.release();
  }
}

export async function updateProject(
  id: number,
  input: UpdateProjectInput
): Promise<Project> {
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

    let nextThumbnailUrl = existing.thumbnail_url;
    if (input.thumbnail_url !== undefined) {
      const parsed = parseOptionalString(input.thumbnail_url);
      nextThumbnailUrl = parsed.provided ? parsed.value : null;
    }

    let nextGithubUrl = existing.github_url;
    if (input.github_url !== undefined) {
      const parsed = parseOptionalString(input.github_url);
      nextGithubUrl = parsed.provided ? parsed.value : null;
    }

    let nextDemoUrl = existing.demo_url;
    if (input.demo_url !== undefined) {
      const parsed = parseOptionalString(input.demo_url);
      nextDemoUrl = parsed.provided ? parsed.value : null;
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

    const updated = await client.query<Project>(
      `
        UPDATE projects
        SET name_th = $2,
            name_en = $3,
            description_th = $4,
            description_en = $5,
            thumbnail_url = $6,
            github_url = $7,
            demo_url = $8,
            display_order = $9,
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
        nextThumbnailUrl,
        nextGithubUrl,
        nextDemoUrl,
        nextDisplayOrder,
        nextIsActive,
      ]
    );

    await insertAdminLog(
      {
        adminId: input.adminId,
        action: "update",
        entityType: "project",
        entityId: id,
        message: `Updated project ${nextNameEn}`,
      },
      client
    );

    await client.query("COMMIT");
    return updated.rows[0];
  } catch (error) {
    await client.query("ROLLBACK");
    rethrowProjectDbError(error);
  } finally {
    client.release();
  }
}

export async function setProjectActive(
  id: number,
  isActiveRaw: unknown,
  adminId?: number | null
): Promise<Project> {
  const parsed = parseRequiredBoolean(isActiveRaw, "is_active");
  if (!parsed.ok) {
    throw new ProjectError(400, parsed.message);
  }

  const client = await pool.connect();
  try {
    await client.query("BEGIN");
    await getByIdForUpdate(client, id);

    const updated = await client.query<Project>(
      `
        UPDATE projects
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
        entityType: "project",
        entityId: id,
        message: `Set project #${id} is_active=${parsed.value}`,
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

export async function softDeleteProject(
  id: number,
  adminId?: number | null
): Promise<Project> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const updated = await client.query<Project>(
      `
        UPDATE projects
        SET deleted_at = NOW(),
            is_active = FALSE
        WHERE id = $1
          AND deleted_at IS NULL
        RETURNING ${SELECT_COLUMNS}
      `,
      [id]
    );

    if (updated.rows.length === 0) {
      throw new ProjectError(404, "Project not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "soft_delete",
        entityType: "project",
        entityId: id,
        message: `Soft deleted project #${id}`,
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

export async function hardDeleteProject(
  id: number,
  adminId?: number | null
): Promise<{ id: number }> {
  const client = await pool.connect();
  try {
    await client.query("BEGIN");

    const found = await client.query<{ id: number; name_en: string }>(
      `SELECT id, name_en FROM projects WHERE id = $1 LIMIT 1`,
      [id]
    );

    if (found.rows.length === 0) {
      throw new ProjectError(404, "Project not found");
    }

    await insertAdminLog(
      {
        adminId,
        action: "hard_delete",
        entityType: "project",
        entityId: id,
        message: `Hard deleted project ${found.rows[0].name_en}`,
      },
      client
    );

    await client.query(`DELETE FROM projects WHERE id = $1`, [id]);
    await client.query("COMMIT");
    return { id };
  } catch (error) {
    await client.query("ROLLBACK");
    throw error;
  } finally {
    client.release();
  }
}

export function parseProjectListFilter(query: {
  is_active?: unknown;
}): ListProjectsFilter {
  const filter: ListProjectsFilter = {};
  if (query.is_active !== undefined && String(query.is_active).trim() !== "") {
    const parsed = parseOptionalBoolean(query.is_active, "is_active");
    if ("ok" in parsed && parsed.ok === false) {
      throw new ProjectError(400, parsed.message);
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
    throw new ProjectError(400, "Invalid id");
  }
  return id;
}
