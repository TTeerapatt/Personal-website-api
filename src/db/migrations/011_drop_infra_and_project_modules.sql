-- Drop infrastructure / project feature tables and soft-delete related menu seeds.
-- Run after deploying API that no longer mounts these routes.

BEGIN;

-- ---------------------------------------------------------------------------
-- Soft-delete menu / permissions for removed tabs
-- ---------------------------------------------------------------------------
UPDATE admin_permissions ap
SET deleted_at = NOW(),
    updated_at = NOW()
FROM admin_menu_tab_action mta
INNER JOIN admin_menu_tab mt
  ON mt.id = mta.menu_tab_id
WHERE ap.menu_tab_action_id = mta.id
  AND ap.deleted_at IS NULL
  AND mt.code IN ('vps', 'ci-cd', 'port', 'domain', 'database', 'projects');

UPDATE admin_menu_tab_action mta
SET deleted_at = NOW(),
    updated_at = NOW()
FROM admin_menu_tab mt
WHERE mta.menu_tab_id = mt.id
  AND mta.deleted_at IS NULL
  AND mt.code IN ('vps', 'ci-cd', 'port', 'domain', 'database', 'projects');

UPDATE admin_menu_tab
SET deleted_at = NOW(),
    updated_at = NOW(),
    is_active = FALSE
WHERE deleted_at IS NULL
  AND code IN ('vps', 'ci-cd', 'port', 'domain', 'database', 'projects');

UPDATE admin_menu_label
SET deleted_at = NOW(),
    updated_at = NOW(),
    is_active = FALSE
WHERE deleted_at IS NULL
  AND code = 'infrastructure';

UPDATE admin_menu_label
SET sort_order = 2,
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND code = 'management';

UPDATE admin_menu_label
SET sort_order = 3,
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND code = 'logs';

UPDATE admin_menu_tab
SET sort_order = 1,
    updated_at = NOW()
WHERE deleted_at IS NULL
  AND code = 'admins';

-- ---------------------------------------------------------------------------
-- Drop feature tables (FK order)
-- ---------------------------------------------------------------------------
DROP TABLE IF EXISTS databases CASCADE;
DROP TABLE IF EXISTS ports CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
DROP TABLE IF EXISTS all_database CASCADE;
DROP TABLE IF EXISTS resource_types CASCADE;

COMMIT;
