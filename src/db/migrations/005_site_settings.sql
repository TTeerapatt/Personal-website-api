-- 005_site_settings.sql
-- Singleton site settings (section visibility only) + Content menu tab (view/edit)

BEGIN;

-- ---------------------------------------------------------------------------
-- 1) Table
-- ---------------------------------------------------------------------------
CREATE TABLE IF NOT EXISTS site_settings (
  id                 BIGINT PRIMARY KEY DEFAULT 1
                       CHECK (id = 1),
  show_banners       BOOLEAN      NOT NULL DEFAULT TRUE,
  show_skills        BOOLEAN      NOT NULL DEFAULT TRUE,
  show_projects      BOOLEAN      NOT NULL DEFAULT TRUE,
  show_experiences   BOOLEAN      NOT NULL DEFAULT TRUE,
  show_education     BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at         TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  site_settings IS 'ตั้งค่าทั้งไซต์ (singleton id=1) — สวิตช์โชว์/ซ่อน section บน landing';
COMMENT ON COLUMN site_settings.id IS 'PK — บังคับเป็น 1 เท่านั้น';
COMMENT ON COLUMN site_settings.show_banners IS 'โชว์ section Home Banners บน landing';
COMMENT ON COLUMN site_settings.show_skills IS 'โชว์ section Skills บน landing';
COMMENT ON COLUMN site_settings.show_projects IS 'โชว์ section Projects บน landing';
COMMENT ON COLUMN site_settings.show_experiences IS 'โชว์ section Experiences บน landing';
COMMENT ON COLUMN site_settings.show_education IS 'โชว์ section Education บน landing';
COMMENT ON COLUMN site_settings.created_at IS 'เวลาสร้าง';
COMMENT ON COLUMN site_settings.updated_at IS 'เวลาแก้ไขล่าสุด';

DROP TRIGGER IF EXISTS site_settings_set_updated_at ON site_settings;
CREATE TRIGGER site_settings_set_updated_at
  BEFORE UPDATE ON site_settings
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

INSERT INTO site_settings (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

-- ---------------------------------------------------------------------------
-- 2) Menu tab under Content
-- ---------------------------------------------------------------------------
INSERT INTO admin_menu_tab (menu_label_id, code, name, is_active, sort_order)
SELECT lbl.id, seed.code, seed.name, TRUE, seed.sort_order
FROM (
  VALUES
    ('content', 'site-settings', 'Site Settings', 0)
) AS seed(label_code, code, name, sort_order)
INNER JOIN admin_menu_label lbl
  ON lbl.code = seed.label_code
 AND lbl.deleted_at IS NULL
WHERE NOT EXISTS (
  SELECT 1
  FROM admin_menu_tab amt
  WHERE amt.code = seed.code
    AND amt.deleted_at IS NULL
);

INSERT INTO admin_menu_tab_action (menu_tab_id, permission_action_id)
SELECT mt.id, pa.id
FROM (
  VALUES
    ('site-settings', 'view'),
    ('site-settings', 'edit')
) AS seed(tab_code, action_code)
INNER JOIN admin_menu_tab mt
  ON mt.code = seed.tab_code
 AND mt.deleted_at IS NULL
INNER JOIN admin_permission_action pa
  ON pa.code = seed.action_code
 AND pa.deleted_at IS NULL
WHERE NOT EXISTS (
  SELECT 1
  FROM admin_menu_tab_action mta
  WHERE mta.menu_tab_id = mt.id
    AND mta.permission_action_id = pa.id
    AND mta.deleted_at IS NULL
);

-- Grant to owner admins (idempotent)
INSERT INTO admin_permissions (admin_id, menu_tab_action_id, is_allowed)
SELECT a.id, mta.id, TRUE
FROM admins a
CROSS JOIN admin_menu_tab_action mta
INNER JOIN admin_menu_tab mt
  ON mt.id = mta.menu_tab_id
 AND mt.deleted_at IS NULL
WHERE a.role = 'owner'
  AND a.deleted_at IS NULL
  AND mta.deleted_at IS NULL
  AND mt.code = 'site-settings'
  AND NOT EXISTS (
    SELECT 1
    FROM admin_permissions ap
    WHERE ap.admin_id = a.id
      AND ap.menu_tab_action_id = mta.id
      AND ap.deleted_at IS NULL
  );

COMMIT;
