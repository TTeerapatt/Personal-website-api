-- Add display_order for experiences and education (drag reorder like skills/banners)

ALTER TABLE experiences
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

ALTER TABLE education
  ADD COLUMN IF NOT EXISTS display_order INTEGER NOT NULL DEFAULT 0;

-- Backfill: keep current chronological feel (newest start_date first → lower display_order)
WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY start_date DESC, id DESC) - 1 AS ord
  FROM experiences
  WHERE deleted_at IS NULL
)
UPDATE experiences e
SET display_order = ranked.ord
FROM ranked
WHERE e.id = ranked.id;

WITH ranked AS (
  SELECT id, ROW_NUMBER() OVER (ORDER BY start_date DESC, id DESC) - 1 AS ord
  FROM education
  WHERE deleted_at IS NULL
)
UPDATE education e
SET display_order = ranked.ord
FROM ranked
WHERE e.id = ranked.id;

DROP INDEX IF EXISTS experiences_start_date_active_idx;
CREATE INDEX IF NOT EXISTS experiences_display_order_active_idx
  ON experiences (display_order, id)
  WHERE deleted_at IS NULL;

DROP INDEX IF EXISTS education_start_date_active_idx;
CREATE INDEX IF NOT EXISTS education_display_order_active_idx
  ON education (display_order, id)
  WHERE deleted_at IS NULL;

COMMENT ON COLUMN experiences.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';
COMMENT ON COLUMN education.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';
