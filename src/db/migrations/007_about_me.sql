-- 007_about_me.sql
-- Singleton about_me content + show_about_me on site_settings
-- Idempotent — safe if already applied on the database

BEGIN;

CREATE TABLE IF NOT EXISTS about_me (
  id                   BIGINT PRIMARY KEY DEFAULT 1
                         CHECK (id = 1),
  title_th             VARCHAR(255) NOT NULL DEFAULT '',
  title_en             VARCHAR(255) NOT NULL DEFAULT '',
  text_animation_th    VARCHAR(255) NOT NULL DEFAULT '',
  text_animation_en    VARCHAR(255) NOT NULL DEFAULT '',
  description_th       TEXT,
  description_en       TEXT,
  image_url            TEXT,
  github_url           TEXT,
  resume_url           TEXT,
  is_active            BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at           TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  about_me IS 'เนื้อหา About Me บน personal website (singleton id=1)';
COMMENT ON COLUMN about_me.id IS 'PK — บังคับเป็น 1 เท่านั้น';
COMMENT ON COLUMN about_me.title_th IS 'หัวข้อภาษาไทย';
COMMENT ON COLUMN about_me.title_en IS 'หัวข้อภาษาอังกฤษ';
COMMENT ON COLUMN about_me.text_animation_th IS 'ข้อความ animation / tagline ภาษาไทย (หลายคำคั่นด้วย | ได้)';
COMMENT ON COLUMN about_me.text_animation_en IS 'ข้อความ animation / tagline ภาษาอังกฤษ (หลายคำคั่นด้วย | ได้)';
COMMENT ON COLUMN about_me.description_th IS 'รายละเอียดภาษาไทย — TEXT สำหรับข้อความยาว / Rich Text';
COMMENT ON COLUMN about_me.description_en IS 'รายละเอียดภาษาอังกฤษ — TEXT สำหรับข้อความยาว / Rich Text';
COMMENT ON COLUMN about_me.image_url IS 'URL รูปโปรไฟล์ / รูป About (nullable)';
COMMENT ON COLUMN about_me.github_url IS 'ลิงก์ GitHub (nullable)';
COMMENT ON COLUMN about_me.resume_url IS 'ลิงก์ Resume / CV (nullable)';
COMMENT ON COLUMN about_me.is_active IS 'สถานะเปิดใช้งานเนื้อหาแถวนี้';
COMMENT ON COLUMN about_me.created_at IS 'เวลาสร้าง';
COMMENT ON COLUMN about_me.updated_at IS 'เวลาแก้ไขล่าสุด';

DROP TRIGGER IF EXISTS about_me_set_updated_at ON about_me;
CREATE TRIGGER about_me_set_updated_at
  BEFORE UPDATE ON about_me
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

INSERT INTO about_me (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE site_settings
  ADD COLUMN IF NOT EXISTS show_about_me BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN site_settings.show_about_me IS 'โชว์ section About Me บน landing';

COMMIT;
