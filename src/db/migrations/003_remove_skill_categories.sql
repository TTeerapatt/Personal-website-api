-- 003_remove_skill_categories.sql
-- Remove skill_categories master + skills.category column

-- ---------------------------------------------------------------------------
-- 1) skills: drop category-dependent indexes, then column
-- ---------------------------------------------------------------------------
DROP INDEX IF EXISTS skills_name_category_active_uidx;
DROP INDEX IF EXISTS skills_category_display_order_active_idx;

ALTER TABLE skills DROP COLUMN IF EXISTS category;

-- Resolve duplicate names before unique(name) index
WITH dups AS (
  SELECT
    id,
    ROW_NUMBER() OVER (PARTITION BY name ORDER BY id) AS rn
  FROM skills
  WHERE deleted_at IS NULL
)
UPDATE skills s
SET name = s.name || ' #' || s.id,
    updated_at = NOW()
FROM dups d
WHERE s.id = d.id
  AND d.rn > 1;

CREATE UNIQUE INDEX IF NOT EXISTS skills_name_active_uidx
  ON skills (name)
  WHERE deleted_at IS NULL;

CREATE INDEX IF NOT EXISTS skills_display_order_active_idx
  ON skills (display_order, id)
  WHERE deleted_at IS NULL;

COMMENT ON COLUMN skills.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';

-- ---------------------------------------------------------------------------
-- 2) drop skill_categories master table
-- ---------------------------------------------------------------------------
DROP TRIGGER IF EXISTS skill_categories_set_updated_at ON skill_categories;
DROP TABLE IF EXISTS skill_categories;
