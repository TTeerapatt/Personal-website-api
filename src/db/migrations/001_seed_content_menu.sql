-- Migration: 001_seed_content_menu
-- 1) Seed owner admin account
-- 2) Seed Content menu label + tabs/actions
-- 3) Grant all menu actions to owner admins
--
-- Default owner credentials (change after first login if needed):
--   email:    rznot778@gmail.com
--   password: 0946987087Notkz_

BEGIN;

-- ---------------------------------------------------------------------------
-- 1) admins (owner)
-- ---------------------------------------------------------------------------
INSERT INTO admins (email, display_name, role)
SELECT seed.email, seed.display_name, seed.role
FROM (
  VALUES
    ('rznot778@gmail.com', 'Owner', 'owner')
) AS seed(email, display_name, role)
WHERE NOT EXISTS (
  SELECT 1
  FROM admins a
  WHERE a.email = seed.email
    AND a.deleted_at IS NULL
);

-- ---------------------------------------------------------------------------
-- 2) admin_auth (bcrypt hash of 0946987087Notkz_, rounds=10)
-- ---------------------------------------------------------------------------
INSERT INTO admin_auth (admin_id, password_hash)
SELECT a.id, seed.password_hash
FROM admins a
CROSS JOIN (
  VALUES
    ('$2b$10$AzuI64bzZ..JJu7l4uXJ1eioEx/fQSz5k1B5vxnTvtLqnMFoXj1AG')
) AS seed(password_hash)
WHERE a.email = 'rznot778@gmail.com'
  AND a.deleted_at IS NULL
  AND NOT EXISTS (
    SELECT 1
    FROM admin_auth aa
    WHERE aa.admin_id = a.id
      AND aa.deleted_at IS NULL
  );

-- ---------------------------------------------------------------------------
-- 3) Content menu label
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 4) Content menu tabs
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 5) Content tab ↔ actions
-- ---------------------------------------------------------------------------
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

-- ---------------------------------------------------------------------------
-- 6) Grant every active tab action to owner admins (idempotent)
-- ---------------------------------------------------------------------------
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
  AND NOT EXISTS (
    SELECT 1
    FROM admin_permissions ap
    WHERE ap.admin_id = a.id
      AND ap.menu_tab_action_id = mta.id
      AND ap.deleted_at IS NULL
  );

COMMIT;
