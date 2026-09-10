import pool from "../config/database.config";
import { parseDateOnly, toPositiveInt } from "../utils/parse";

export class WebsiteVisitError extends Error {
  constructor(
    public statusCode: number,
    message: string
  ) {
    super(message);
    this.name = "WebsiteVisitError";
  }
}

export interface WebsiteVisit {
  id: number;
  visit_date: string;
  visit_count: number;
  created_at: string;
  updated_at: string;
}

export interface WebsiteVisitSummary {
  total_visits: number;
  today_date: string;
  today_visits: number;
  day_count: number;
}

export interface ListWebsiteVisitsFilter {
  from?: string;
  to?: string;
}

const SELECT_COLUMNS = `
  id,
  visit_date,
  visit_count,
  created_at,
  updated_at
`;

function fail(result: { ok: false; message: string }): never {
  throw new WebsiteVisitError(400, result.message);
}

function normalizeVisitDate(value: unknown): string {
  if (value instanceof Date) {
    return value.toISOString().slice(0, 10);
  }
  return String(value).slice(0, 10);
}

function mapVisitRow(row: Record<string, unknown>): WebsiteVisit {
  return {
    id: Number(row.id),
    visit_date: normalizeVisitDate(row.visit_date),
    visit_count: Number(row.visit_count),
    created_at: String(row.created_at),
    updated_at: String(row.updated_at),
  };
}

function parseOptionalAmount(value: unknown): number {
  if (value === undefined || value === null || String(value).trim() === "") {
    return 1;
  }

  const amount = toPositiveInt(value);
  if (amount === null) {
    throw new WebsiteVisitError(400, "amount must be a positive integer");
  }
  if (amount > 100) {
    throw new WebsiteVisitError(400, "amount must be at most 100");
  }
  return amount;
}

export function parseWebsiteVisitListFilter(
  query: Record<string, unknown>
): ListWebsiteVisitsFilter {
  const fromResult = parseDateOnly(query.from, "from", { required: false });
  if (!fromResult.ok) fail(fromResult);

  const toResult = parseDateOnly(query.to, "to", { required: false });
  if (!toResult.ok) fail(toResult);

  const from = fromResult.value ?? undefined;
  const to = toResult.value ?? undefined;

  if (from && to && from > to) {
    throw new WebsiteVisitError(400, "from must be on or before to");
  }

  return { from, to };
}

/** Increment today's visit count (uses DB CURRENT_DATE). Public website use. */
export async function trackWebsiteVisit(input: {
  amount?: unknown;
} = {}): Promise<WebsiteVisit> {
  const amount = parseOptionalAmount(input.amount);

  const result = await pool.query(
    `
      INSERT INTO website_visits (visit_date, visit_count)
      VALUES (CURRENT_DATE, $1)
      ON CONFLICT (visit_date)
      DO UPDATE SET
        visit_count = website_visits.visit_count + EXCLUDED.visit_count
      RETURNING ${SELECT_COLUMNS}
    `,
    [amount]
  );

  return mapVisitRow(result.rows[0]);
}

export async function getWebsiteVisitSummary(): Promise<WebsiteVisitSummary> {
  const result = await pool.query(
    `
      SELECT
        COALESCE(SUM(visit_count), 0)::BIGINT AS total_visits,
        CURRENT_DATE AS today_date,
        COALESCE(
          (
            SELECT visit_count
            FROM website_visits
            WHERE visit_date = CURRENT_DATE
          ),
          0
        )::BIGINT AS today_visits,
        COUNT(*)::BIGINT AS day_count
      FROM website_visits
    `
  );

  const row = result.rows[0] ?? {};
  return {
    total_visits: Number(row.total_visits ?? 0),
    today_date: normalizeVisitDate(row.today_date ?? new Date()),
    today_visits: Number(row.today_visits ?? 0),
    day_count: Number(row.day_count ?? 0),
  };
}

export async function getWebsiteVisits(
  filter: ListWebsiteVisitsFilter = {}
): Promise<WebsiteVisit[]> {
  const where: string[] = [];
  const params: unknown[] = [];

  if (filter.from) {
    params.push(filter.from);
    where.push(`visit_date >= $${params.length}`);
  }
  if (filter.to) {
    params.push(filter.to);
    where.push(`visit_date <= $${params.length}`);
  }

  const whereSql = where.length > 0 ? `WHERE ${where.join(" AND ")}` : "";

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM website_visits
      ${whereSql}
      ORDER BY visit_date DESC, id DESC
    `,
    params
  );

  return result.rows.map((row) => mapVisitRow(row));
}

export async function getWebsiteVisitByDate(
  visitDate: string
): Promise<WebsiteVisit | null> {
  const dateResult = parseDateOnly(visitDate, "visit_date", { required: true });
  if (!dateResult.ok) fail(dateResult);

  const result = await pool.query(
    `
      SELECT ${SELECT_COLUMNS}
      FROM website_visits
      WHERE visit_date = $1
      LIMIT 1
    `,
    [dateResult.value]
  );

  if (result.rows.length === 0) {
    return null;
  }

  return mapVisitRow(result.rows[0]);
}
