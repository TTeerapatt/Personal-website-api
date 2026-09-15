-- 008_about_me_menu.sql
-- Seed About Me admin menu tab (view/edit) under Content + owner grants
-- Idempotent — safe if already applied

BEGIN;

INSERT INTO admin_menu_tab (menu_label_id, code, name, is_active, sort_order)
SELECT lbl.id, seed.code, seed.name, TRUE, seed.sort_order
FROM (
  VALUES
    ('content', 'about-me', 'About Me', 1)
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

UPDATE admin_menu_tab
SET sort_order = CASE code
  WHEN 'home-banners' THEN 0
  WHEN 'about-me' THEN 1
  WHEN 'skills' THEN 2
  WHEN 'projects' THEN 3
  WHEN 'experiences' THEN 4
  WHEN 'education' THEN 5
  WHEN 'site-settings' THEN 6
  ELSE sort_order
END,
updated_at = NOW()
WHERE deleted_at IS NULL
  AND code IN (
    'home-banners',
    'about-me',
    'skills',
    'projects',
    'experiences',
    'education',
    'site-settings'
  );

INSERT INTO admin_menu_tab_action (menu_tab_id, permission_action_id)
SELECT mt.id, pa.id
FROM (
  VALUES
    ('about-me', 'view'),
    ('about-me', 'edit')
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
  AND mt.code = 'about-me'
  AND NOT EXISTS (
    SELECT 1
    FROM admin_permissions ap
    WHERE ap.admin_id = a.id
      AND ap.menu_tab_action_id = mta.id
      AND ap.deleted_at IS NULL
  );

COMMIT;
