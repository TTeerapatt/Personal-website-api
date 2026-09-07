-- Migration: 013_seed_content_menu
-- Seed Content menu label + tabs/actions for home-banners, skills, projects,
-- experiences, education. Also re-grant missing permissions to owner admins.

BEGIN;

INSERT INTO admin_menu_label (code, name, is_active, sort_order)
SELECT seed.code, seed.name, TRUE, seed.sort_order
FROM (
  VALUES
    ('content', 'Content', 2)
) AS seed(code, name, sort_order)
WHERE NOT EXISTS (
  SELECT 1
  FROM admin_menu_label aml
  WHERE aml.code = seed.code
    AND aml.deleted_at IS NULL
);

UPDATE admin_menu_label
SET sort_order = 3,
    updated_at = NOW()
WHERE code = 'management'
  AND deleted_at IS NULL
  AND sort_order <> 3;

UPDATE admin_menu_label
SET sort_order = 4,
    updated_at = NOW()
WHERE code = 'logs'
  AND deleted_at IS NULL
  AND sort_order <> 4;

INSERT INTO admin_menu_tab (menu_label_id, code, name, is_active, sort_order)
SELECT lbl.id, seed.code, seed.name, TRUE, seed.sort_order
FROM (
  VALUES
    ('content', 'home-banners', 'Home Banners', 1),
    ('content', 'skills', 'Skills', 2),
    ('content', 'projects', 'Projects', 3),
    ('content', 'experiences', 'Experiences', 4),
    ('content', 'education', 'Education', 5)
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
    ('home-banners', 'view'),
    ('home-banners', 'add'),
    ('home-banners', 'edit'),
    ('home-banners', 'delete'),
    ('home-banners', 'export'),
    ('skills', 'view'),
    ('skills', 'add'),
    ('skills', 'edit'),
    ('skills', 'delete'),
    ('skills', 'export'),
    ('projects', 'view'),
    ('projects', 'add'),
    ('projects', 'edit'),
    ('projects', 'delete'),
    ('projects', 'export'),
    ('experiences', 'view'),
    ('experiences', 'add'),
    ('experiences', 'edit'),
    ('experiences', 'delete'),
    ('experiences', 'export'),
    ('education', 'view'),
    ('education', 'add'),
    ('education', 'edit'),
    ('education', 'delete'),
    ('education', 'export')
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

-- Grant new content tab actions to all active owners (idempotent)
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
  AND mt.code IN (
    'home-banners', 'skills', 'projects', 'experiences', 'education'
  )
  AND NOT EXISTS (
    SELECT 1
    FROM admin_permissions ap
    WHERE ap.admin_id = a.id
      AND ap.menu_tab_action_id = mta.id
      AND ap.deleted_at IS NULL
  );

COMMIT;
