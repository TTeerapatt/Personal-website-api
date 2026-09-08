-- 002_skill_categories_and_media_type.sql
-- Master data: skill categories + remove media_type 'icon'

-- ---------------------------------------------------------------------------
-- 1) skill_categories master
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS skill_categories (
  id             BIGSERIAL PRIMARY KEY,
  code           VARCHAR(64)  NOT NULL,
  name           VARCHAR(128) NOT NULL,
  display_order  INTEGER      NOT NULL DEFAULT 0,
  is_active      BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at     TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  deleted_at     TIMESTAMPTZ  NULL
);

COMMENT ON TABLE  skill_categories IS 'Master data หมวดทักษะ เช่น frontend, backend, tool';
COMMENT ON COLUMN skill_categories.code IS 'รหัสหมวด (ใช้ใน skills.category)';
COMMENT ON COLUMN skill_categories.name IS 'ชื่อแสดงผล';

CREATE UNIQUE INDEX IF NOT EXISTS skill_categories_code_active_uidx
  ON skill_categories (code)
  WHERE deleted_at IS NULL;

DROP TRIGGER IF EXISTS skill_categories_set_updated_at ON skill_categories;
CREATE TRIGGER skill_categories_set_updated_at
  BEFORE UPDATE ON skill_categories
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

INSERT INTO skill_categories (code, name, display_order, is_active)
SELECT seed.code, seed.name, seed.display_order, TRUE
FROM (
  VALUES
    ('frontend', 'Frontend', 1),
    ('backend', 'Backend', 2),
    ('tool', 'Tool', 3)
) AS seed(code, name, display_order)
WHERE NOT EXISTS (
  SELECT 1
  FROM skill_categories sc
  WHERE sc.code = seed.code
    AND sc.deleted_at IS NULL
);

-- Normalize legacy category values
UPDATE skills
SET category = 'tool',
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND LOWER(TRIM(category)) IN ('tools', 'tooling');

UPDATE skills
SET category = LOWER(TRIM(category)),
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND category IS NOT NULL
  AND category <> LOWER(TRIM(category));

-- ---------------------------------------------------------------------------
-- 2) media_type: drop icon, keep image | video
-- ---------------------------------------------------------------------------
UPDATE home_banners
SET media_type = 'image',
    updated_at = NOW()
WHERE media_type = 'icon'
  AND deleted_at IS NULL;

UPDATE skills
SET media_type = 'image',
    updated_at = NOW()
WHERE media_type = 'icon'
  AND deleted_at IS NULL;

UPDATE experiences
SET media_type = 'image',
    updated_at = NOW()
WHERE media_type = 'icon'
  AND deleted_at IS NULL;

UPDATE education
SET media_type = 'image',
    updated_at = NOW()
WHERE media_type = 'icon'
  AND deleted_at IS NULL;

ALTER TABLE home_banners DROP CONSTRAINT IF EXISTS home_banners_media_type_check;
ALTER TABLE home_banners
  ADD CONSTRAINT home_banners_media_type_check
  CHECK (media_type IN ('image', 'video'));

-- Skills: image only
UPDATE skills
SET media_type = 'image',
    updated_at = NOW()
WHERE media_type <> 'image'
  AND deleted_at IS NULL;

ALTER TABLE skills DROP CONSTRAINT IF EXISTS skills_media_type_check;
ALTER TABLE skills
  ADD CONSTRAINT skills_media_type_check
  CHECK (media_type = 'image');

ALTER TABLE experiences DROP CONSTRAINT IF EXISTS experiences_media_type_check;
ALTER TABLE experiences
  ADD CONSTRAINT experiences_media_type_check
  CHECK (media_type IS NULL OR media_type IN ('image', 'video'));

ALTER TABLE education DROP CONSTRAINT IF EXISTS education_media_type_check;
ALTER TABLE education
  ADD CONSTRAINT education_media_type_check
  CHECK (media_type IS NULL OR media_type IN ('image', 'video'));
