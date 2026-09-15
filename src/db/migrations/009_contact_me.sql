-- 009_contact_me.sql
-- Singleton contact_me content + show_contact_me on site_settings
-- Idempotent — safe if already applied

BEGIN;

CREATE TABLE IF NOT EXISTS contact_me (
  id               BIGINT PRIMARY KEY DEFAULT 1
                     CHECK (id = 1),
  name_th          VARCHAR(255) NOT NULL DEFAULT '',
  name_en          VARCHAR(255) NOT NULL DEFAULT '',
  phone            VARCHAR(50),
  email            VARCHAR(255) NOT NULL DEFAULT '',
  github_url       TEXT,
  linkedin_url     TEXT,
  facebook_url     TEXT,
  instagram_url    TEXT,
  is_active        BOOLEAN      NOT NULL DEFAULT TRUE,
  created_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW(),
  updated_at       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE  contact_me IS 'ข้อมูลติดต่อ Contact Me บน personal website (singleton id=1)';
COMMENT ON COLUMN contact_me.id IS 'PK — บังคับเป็น 1 เท่านั้น';
COMMENT ON COLUMN contact_me.name_th IS 'ชื่อที่แสดงภาษาไทย';
COMMENT ON COLUMN contact_me.name_en IS 'ชื่อที่แสดงภาษาอังกฤษ';
COMMENT ON COLUMN contact_me.phone IS 'เบอร์โทร (nullable — ไม่บังคับโชว์บนเว็บ)';
COMMENT ON COLUMN contact_me.email IS 'อีเมลติดต่อหลัก';
COMMENT ON COLUMN contact_me.github_url IS 'ลิงก์ GitHub (nullable)';
COMMENT ON COLUMN contact_me.linkedin_url IS 'ลิงก์ LinkedIn (nullable)';
COMMENT ON COLUMN contact_me.facebook_url IS 'ลิงก์ Facebook (nullable)';
COMMENT ON COLUMN contact_me.instagram_url IS 'ลิงก์ Instagram (nullable)';
COMMENT ON COLUMN contact_me.is_active IS 'สถานะเปิดใช้งานเนื้อหาแถวนี้';
COMMENT ON COLUMN contact_me.created_at IS 'เวลาสร้าง';
COMMENT ON COLUMN contact_me.updated_at IS 'เวลาแก้ไขล่าสุด';

DROP TRIGGER IF EXISTS contact_me_set_updated_at ON contact_me;
CREATE TRIGGER contact_me_set_updated_at
  BEFORE UPDATE ON contact_me
  FOR EACH ROW
  EXECUTE FUNCTION set_updated_at();

INSERT INTO contact_me (id)
VALUES (1)
ON CONFLICT (id) DO NOTHING;

ALTER TABLE site_settings
  ADD COLUMN IF NOT EXISTS show_contact_me BOOLEAN NOT NULL DEFAULT TRUE;

COMMENT ON COLUMN site_settings.show_contact_me IS 'โชว์ section Contact Me บน landing';

COMMIT;
