--
-- PostgreSQL database dump
--

\restrict uy5XvxApyWcG7docc1hhuts4JUxC3YggFyZkhe5aFYaBmsFdEC9ox4CKyRVkHTU

-- Dumped from database version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)
-- Dumped by pg_dump version 16.15 (Ubuntu 16.15-0ubuntu0.24.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: set_updated_at(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$;


ALTER FUNCTION public.set_updated_at() OWNER TO postgres;

--
-- Name: FUNCTION set_updated_at(); Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON FUNCTION public.set_updated_at() IS 'อัปเดต updated_at อัตโนมัติทุกครั้งที่ UPDATE';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: about_me; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.about_me (
    id bigint DEFAULT 1 NOT NULL,
    title_th character varying(255) DEFAULT ''::character varying NOT NULL,
    title_en character varying(255) DEFAULT ''::character varying NOT NULL,
    text_animation_th character varying(255) DEFAULT ''::character varying NOT NULL,
    text_animation_en character varying(255) DEFAULT ''::character varying NOT NULL,
    description_th text,
    description_en text,
    image_url text,
    github_url text,
    resume_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT about_me_id_check CHECK ((id = 1))
);


ALTER TABLE public.about_me OWNER TO postgres;

--
-- Name: TABLE about_me; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.about_me IS 'เนื้อหา About Me บน personal website (singleton id=1)';


--
-- Name: COLUMN about_me.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.id IS 'PK — บังคับเป็น 1 เท่านั้น';


--
-- Name: COLUMN about_me.title_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.title_th IS 'หัวข้อภาษาไทย';


--
-- Name: COLUMN about_me.title_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.title_en IS 'หัวข้อภาษาอังกฤษ';


--
-- Name: COLUMN about_me.text_animation_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.text_animation_th IS 'ข้อความ animation / tagline ภาษาไทย (หลายคำคั่นด้วย | ได้)';


--
-- Name: COLUMN about_me.text_animation_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.text_animation_en IS 'ข้อความ animation / tagline ภาษาอังกฤษ (หลายคำคั่นด้วย | ได้)';


--
-- Name: COLUMN about_me.description_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.description_th IS 'รายละเอียดภาษาไทย — TEXT สำหรับข้อความยาว / Rich Text';


--
-- Name: COLUMN about_me.description_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.description_en IS 'รายละเอียดภาษาอังกฤษ — TEXT สำหรับข้อความยาว / Rich Text';


--
-- Name: COLUMN about_me.image_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.image_url IS 'URL รูปโปรไฟล์ / รูป About (nullable)';


--
-- Name: COLUMN about_me.github_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.github_url IS 'ลิงก์ GitHub (nullable)';


--
-- Name: COLUMN about_me.resume_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.resume_url IS 'ลิงก์ Resume / CV (nullable)';


--
-- Name: COLUMN about_me.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.is_active IS 'สถานะเปิดใช้งานเนื้อหาแถวนี้';


--
-- Name: COLUMN about_me.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN about_me.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.about_me.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: admin_auth; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_auth (
    id bigint NOT NULL,
    admin_id bigint NOT NULL,
    password_hash text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_auth OWNER TO postgres;

--
-- Name: TABLE admin_auth; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_auth IS 'ข้อมูล auth ของ admin เช่น password hash';


--
-- Name: COLUMN admin_auth.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.id IS 'PK';


--
-- Name: COLUMN admin_auth.admin_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.admin_id IS 'FK → admins.id (1 admin ต่อ 1 auth ที่ active)';


--
-- Name: COLUMN admin_auth.password_hash; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.password_hash IS 'รหัสผ่านที่ hash แล้ว';


--
-- Name: COLUMN admin_auth.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_auth.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_auth.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_auth.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_auth_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_auth ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_auth_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_log; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_log (
    id bigint NOT NULL,
    admin_id bigint NOT NULL,
    action character varying(64) NOT NULL,
    entity_type character varying(64),
    entity_id bigint,
    message text,
    meta jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_log OWNER TO postgres;

--
-- Name: TABLE admin_log; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_log IS 'ประวัติการใช้งานของ admin — โดยปกติ insert อย่างเดียว';


--
-- Name: COLUMN admin_log.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.id IS 'PK';


--
-- Name: COLUMN admin_log.admin_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.admin_id IS 'FK → admins.id ผู้ทำรายการ';


--
-- Name: COLUMN admin_log.action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.action IS 'ชนิดเหตุการณ์ เช่น login, create, update, soft_delete';


--
-- Name: COLUMN admin_log.entity_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.entity_type IS 'ชนิดข้อมูลที่เกี่ยวกับ action เช่น order, user, list_price, admin';


--
-- Name: COLUMN admin_log.entity_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.entity_id IS 'id ของข้อมูลที่เกี่ยวข้อง (nullable)';


--
-- Name: COLUMN admin_log.message; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.message IS 'ข้อความเพิ่มเติม';


--
-- Name: COLUMN admin_log.meta; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.meta IS 'รายละเอียดเพิ่มเติมแบบ JSON (optional)';


--
-- Name: COLUMN admin_log.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_log.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_log.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_log.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_log_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_log ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_menu_label; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_menu_label (
    id bigint NOT NULL,
    code character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_menu_label OWNER TO postgres;

--
-- Name: TABLE admin_menu_label; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_menu_label IS 'กลุ่ม label ของเมนูฝั่ง admin เช่น การจัดการข้อมูล, รายงาน';


--
-- Name: COLUMN admin_menu_label.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.id IS 'PK';


--
-- Name: COLUMN admin_menu_label.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.code IS 'รหัส label สำหรับระบบ (unique เฉพาะแถวที่ยังไม่ลบ)';


--
-- Name: COLUMN admin_menu_label.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.name IS 'ชื่อที่แสดงบนเมนู';


--
-- Name: COLUMN admin_menu_label.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.is_active IS 'สถานะเปิดใช้งาน label';


--
-- Name: COLUMN admin_menu_label.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.sort_order IS 'ลำดับการแสดงผล';


--
-- Name: COLUMN admin_menu_label.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_menu_label.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_menu_label.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_label.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_menu_label_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_menu_label ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_menu_label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_menu_tab; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_menu_tab (
    id bigint NOT NULL,
    menu_label_id bigint NOT NULL,
    code character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_menu_tab OWNER TO postgres;

--
-- Name: TABLE admin_menu_tab; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_menu_tab IS 'tab เมนูที่อยู่ภายใต้ label แต่ละกลุ่ม';


--
-- Name: COLUMN admin_menu_tab.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.id IS 'PK';


--
-- Name: COLUMN admin_menu_tab.menu_label_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.menu_label_id IS 'FK → admin_menu_label.id';


--
-- Name: COLUMN admin_menu_tab.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.code IS 'รหัส tab สำหรับอ้างอิงสิทธิ์ (unique เฉพาะแถวที่ยังไม่ลบ)';


--
-- Name: COLUMN admin_menu_tab.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.name IS 'ชื่อ tab ที่แสดงบน UI';


--
-- Name: COLUMN admin_menu_tab.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.is_active IS 'สถานะเปิดใช้งาน tab';


--
-- Name: COLUMN admin_menu_tab.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.sort_order IS 'ลำดับการแสดงผลในกลุ่ม';


--
-- Name: COLUMN admin_menu_tab.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_menu_tab.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_menu_tab.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_menu_tab_action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_menu_tab_action (
    id bigint NOT NULL,
    menu_tab_id bigint NOT NULL,
    permission_action_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_menu_tab_action OWNER TO postgres;

--
-- Name: TABLE admin_menu_tab_action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_menu_tab_action IS 'mapping ว่า tab ใดรองรับ action ใดได้บ้าง';


--
-- Name: COLUMN admin_menu_tab_action.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.id IS 'PK';


--
-- Name: COLUMN admin_menu_tab_action.menu_tab_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.menu_tab_id IS 'FK → admin_menu_tab.id';


--
-- Name: COLUMN admin_menu_tab_action.permission_action_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.permission_action_id IS 'FK → admin_permission_action.id';


--
-- Name: COLUMN admin_menu_tab_action.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_menu_tab_action.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_menu_tab_action.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_menu_tab_action.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_menu_tab_action_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_menu_tab_action ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_menu_tab_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_menu_tab_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_menu_tab ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_menu_tab_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_permission_action; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_permission_action (
    id bigint NOT NULL,
    code character varying(64) NOT NULL,
    name character varying(255) NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    description text,
    sort_order integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_permission_action OWNER TO postgres;

--
-- Name: TABLE admin_permission_action; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_permission_action IS 'master ของ action สิทธิ์ เช่น view/add/edit/delete/export';


--
-- Name: COLUMN admin_permission_action.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.id IS 'PK';


--
-- Name: COLUMN admin_permission_action.code; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.code IS 'รหัส action สำหรับระบบ (unique เฉพาะแถวที่ยังไม่ลบ)';


--
-- Name: COLUMN admin_permission_action.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.name IS 'ชื่อ action ที่แสดง';


--
-- Name: COLUMN admin_permission_action.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.is_active IS 'สถานะเปิดใช้งาน action';


--
-- Name: COLUMN admin_permission_action.description; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.description IS 'รายละเอียดเพิ่มเติม';


--
-- Name: COLUMN admin_permission_action.sort_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.sort_order IS 'ลำดับการแสดงผล';


--
-- Name: COLUMN admin_permission_action.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_permission_action.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_permission_action.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permission_action.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_permission_action_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_permission_action ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_permission_action_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admin_permissions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admin_permissions (
    id bigint NOT NULL,
    admin_id bigint NOT NULL,
    menu_tab_action_id bigint NOT NULL,
    is_allowed boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.admin_permissions OWNER TO postgres;

--
-- Name: TABLE admin_permissions; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admin_permissions IS 'สิทธิ์ราย admin ว่าอนุญาต action ใดใน tab ไหน';


--
-- Name: COLUMN admin_permissions.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.id IS 'PK';


--
-- Name: COLUMN admin_permissions.admin_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.admin_id IS 'FK → admins.id';


--
-- Name: COLUMN admin_permissions.menu_tab_action_id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.menu_tab_action_id IS 'FK → admin_menu_tab_action.id';


--
-- Name: COLUMN admin_permissions.is_allowed; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.is_allowed IS 'true = อนุญาต, false = ปฏิเสธ';


--
-- Name: COLUMN admin_permissions.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admin_permissions.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admin_permissions.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admin_permissions.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admin_permissions ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admin_permissions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    display_name character varying(255) NOT NULL,
    role character varying(32) DEFAULT 'staff'::character varying NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT admins_role_check CHECK (((role)::text = ANY ((ARRAY['owner'::character varying, 'admin'::character varying, 'staff'::character varying])::text[])))
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: TABLE admins; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.admins IS 'พนักงาน / ผู้ดูแลระบบ (ข้อมูลโปรไฟล์)';


--
-- Name: COLUMN admins.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.id IS 'PK';


--
-- Name: COLUMN admins.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.email IS 'อีเมล — unique เฉพาะแถวที่ยังไม่ลบ';


--
-- Name: COLUMN admins.display_name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.display_name IS 'ชื่อที่แสดง';


--
-- Name: COLUMN admins.role; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.role IS 'owner | admin | staff';


--
-- Name: COLUMN admins.last_login_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.last_login_at IS 'เวลา login ล่าสุด — อัปเดตตอน login สำเร็จ';


--
-- Name: COLUMN admins.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN admins.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN admins.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.admins.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.admins ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: contact_me; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.contact_me (
    id bigint DEFAULT 1 NOT NULL,
    name_th character varying(255) DEFAULT ''::character varying NOT NULL,
    name_en character varying(255) DEFAULT ''::character varying NOT NULL,
    phone character varying(50),
    email character varying(255) DEFAULT ''::character varying NOT NULL,
    github_url text,
    linkedin_url text,
    facebook_url text,
    instagram_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT contact_me_id_check CHECK ((id = 1))
);


ALTER TABLE public.contact_me OWNER TO postgres;

--
-- Name: TABLE contact_me; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.contact_me IS 'ข้อมูลติดต่อ Contact Me บน personal website (singleton id=1)';


--
-- Name: COLUMN contact_me.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.id IS 'PK — บังคับเป็น 1 เท่านั้น';


--
-- Name: COLUMN contact_me.name_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.name_th IS 'ชื่อที่แสดงภาษาไทย';


--
-- Name: COLUMN contact_me.name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.name_en IS 'ชื่อที่แสดงภาษาอังกฤษ';


--
-- Name: COLUMN contact_me.phone; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.phone IS 'เบอร์โทร (nullable — ไม่บังคับโชว์บนเว็บ)';


--
-- Name: COLUMN contact_me.email; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.email IS 'อีเมลติดต่อหลัก';


--
-- Name: COLUMN contact_me.github_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.github_url IS 'ลิงก์ GitHub (nullable)';


--
-- Name: COLUMN contact_me.linkedin_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.linkedin_url IS 'ลิงก์ LinkedIn (nullable)';


--
-- Name: COLUMN contact_me.facebook_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.facebook_url IS 'ลิงก์ Facebook (nullable)';


--
-- Name: COLUMN contact_me.instagram_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.instagram_url IS 'ลิงก์ Instagram (nullable)';


--
-- Name: COLUMN contact_me.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.is_active IS 'สถานะเปิดใช้งานเนื้อหาแถวนี้';


--
-- Name: COLUMN contact_me.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN contact_me.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.contact_me.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: education; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.education (
    id bigint NOT NULL,
    name_th character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    description_th text,
    description_en text,
    start_date date NOT NULL,
    end_date date,
    media_type character varying(32),
    url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    display_order integer DEFAULT 0 NOT NULL,
    CONSTRAINT education_end_date_check CHECK (((end_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT education_media_type_check CHECK (((media_type IS NULL) OR ((media_type)::text = ANY ((ARRAY['image'::character varying, 'video'::character varying])::text[]))))
);


ALTER TABLE public.education OWNER TO postgres;

--
-- Name: TABLE education; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.education IS 'ประวัติการศึกษา';


--
-- Name: COLUMN education.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.id IS 'PK';


--
-- Name: COLUMN education.name_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.name_th IS 'ชื่อสถานศึกษา / หลักสูตร ภาษาไทย';


--
-- Name: COLUMN education.name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.name_en IS 'ชื่อสถานศึกษา / หลักสูตร ภาษาอังกฤษ';


--
-- Name: COLUMN education.description_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.description_th IS 'รายละเอียดภาษาไทย — TEXT สำหรับ Rich Text Editor';


--
-- Name: COLUMN education.description_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.description_en IS 'รายละเอียดภาษาอังกฤษ — TEXT สำหรับ Rich Text Editor';


--
-- Name: COLUMN education.start_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.start_date IS 'วันเริ่มศึกษา';


--
-- Name: COLUMN education.end_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.end_date IS 'วันจบการศึกษา — NULL = กำลังศึกษา';


--
-- Name: COLUMN education.media_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.media_type IS 'ชนิดสื่อโลโก้: image | video | icon (nullable)';


--
-- Name: COLUMN education.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.url IS 'URL โลโก้ / สื่อ (nullable)';


--
-- Name: COLUMN education.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.is_active IS 'สถานะเปิดใช้งาน';


--
-- Name: COLUMN education.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN education.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN education.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: COLUMN education.display_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.education.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';


--
-- Name: education_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.education ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.education_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: experiences; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.experiences (
    id bigint NOT NULL,
    name_th character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    description_th text,
    description_en text,
    "position" character varying(255) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    media_type character varying(32),
    url text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    display_order integer DEFAULT 0 NOT NULL,
    CONSTRAINT experiences_end_date_check CHECK (((end_date IS NULL) OR (end_date >= start_date))),
    CONSTRAINT experiences_media_type_check CHECK (((media_type IS NULL) OR ((media_type)::text = ANY ((ARRAY['image'::character varying, 'video'::character varying])::text[]))))
);


ALTER TABLE public.experiences OWNER TO postgres;

--
-- Name: TABLE experiences; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.experiences IS 'ประวัติการทำงาน / ประสบการณ์';


--
-- Name: COLUMN experiences.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.id IS 'PK';


--
-- Name: COLUMN experiences.name_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.name_th IS 'ชื่อบริษัท / องค์กร ภาษาไทย';


--
-- Name: COLUMN experiences.name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.name_en IS 'ชื่อบริษัท / องค์กร ภาษาอังกฤษ';


--
-- Name: COLUMN experiences.description_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.description_th IS 'รายละเอียดงานภาษาไทย — TEXT สำหรับ Rich Text Editor';


--
-- Name: COLUMN experiences.description_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.description_en IS 'รายละเอียดงานภาษาอังกฤษ — TEXT สำหรับ Rich Text Editor';


--
-- Name: COLUMN experiences."position"; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences."position" IS 'ตำแหน่งงาน';


--
-- Name: COLUMN experiences.start_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.start_date IS 'วันเริ่มงาน';


--
-- Name: COLUMN experiences.end_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.end_date IS 'วันสิ้นสุดงาน — NULL = ปัจจุบัน';


--
-- Name: COLUMN experiences.media_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.media_type IS 'ชนิดสื่อโลโก้: image | video | icon (nullable)';


--
-- Name: COLUMN experiences.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.url IS 'URL โลโก้ / สื่อ (nullable)';


--
-- Name: COLUMN experiences.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.is_active IS 'สถานะเปิดใช้งาน';


--
-- Name: COLUMN experiences.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN experiences.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN experiences.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: COLUMN experiences.display_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.experiences.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';


--
-- Name: experiences_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.experiences ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.experiences_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: home_banners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.home_banners (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    media_type character varying(32) NOT NULL,
    url text NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT home_banners_media_type_check CHECK (((media_type)::text = ANY ((ARRAY['image'::character varying, 'video'::character varying])::text[])))
);


ALTER TABLE public.home_banners OWNER TO postgres;

--
-- Name: TABLE home_banners; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.home_banners IS 'แบนเนอร์หน้าแรกของ personal website';


--
-- Name: COLUMN home_banners.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.id IS 'PK';


--
-- Name: COLUMN home_banners.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.name IS 'ชื่อแบนเนอร์สำหรับอ้างอิงในแอดมิน';


--
-- Name: COLUMN home_banners.media_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.media_type IS 'ชนิดสื่อ: image | video | icon';


--
-- Name: COLUMN home_banners.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.url IS 'URL ของไฟล์สื่อ / path ที่อัปโหลด';


--
-- Name: COLUMN home_banners.display_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';


--
-- Name: COLUMN home_banners.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.is_active IS 'สถานะเปิดใช้งาน';


--
-- Name: COLUMN home_banners.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN home_banners.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN home_banners.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.home_banners.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: home_banners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.home_banners ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.home_banners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.projects (
    id bigint NOT NULL,
    name_th character varying(255) NOT NULL,
    name_en character varying(255) NOT NULL,
    description_th text,
    description_en text,
    thumbnail_url text,
    github_url text,
    demo_url text,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone
);


ALTER TABLE public.projects OWNER TO postgres;

--
-- Name: TABLE projects; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.projects IS 'ผลงาน / โปรเจกต์บน personal website';


--
-- Name: COLUMN projects.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.id IS 'PK';


--
-- Name: COLUMN projects.name_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.name_th IS 'ชื่อโปรเจกต์ภาษาไทย';


--
-- Name: COLUMN projects.name_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.name_en IS 'ชื่อโปรเจกต์ภาษาอังกฤษ';


--
-- Name: COLUMN projects.description_th; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.description_th IS 'รายละเอียดภาษาไทย — TEXT สำหรับ Rich Text Editor (HTML/string)';


--
-- Name: COLUMN projects.description_en; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.description_en IS 'รายละเอียดภาษาอังกฤษ — TEXT สำหรับ Rich Text Editor (HTML/string)';


--
-- Name: COLUMN projects.thumbnail_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.thumbnail_url IS 'URL รูป thumbnail';


--
-- Name: COLUMN projects.github_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.github_url IS 'ลิงก์ GitHub (nullable)';


--
-- Name: COLUMN projects.demo_url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.demo_url IS 'ลิงก์ demo / live site (nullable)';


--
-- Name: COLUMN projects.display_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';


--
-- Name: COLUMN projects.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.is_active IS 'สถานะเปิดใช้งาน';


--
-- Name: COLUMN projects.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN projects.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN projects.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.projects.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: projects_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.projects ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.projects_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: site_settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.site_settings (
    id bigint DEFAULT 1 NOT NULL,
    show_banners boolean DEFAULT true NOT NULL,
    show_skills boolean DEFAULT true NOT NULL,
    show_projects boolean DEFAULT true NOT NULL,
    show_experiences boolean DEFAULT true NOT NULL,
    show_education boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    show_about_me boolean DEFAULT true NOT NULL,
    show_contact_me boolean DEFAULT true NOT NULL,
    CONSTRAINT site_settings_id_check CHECK ((id = 1))
);


ALTER TABLE public.site_settings OWNER TO postgres;

--
-- Name: TABLE site_settings; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.site_settings IS 'ตั้งค่าทั้งไซต์ (singleton id=1) — สวิตช์โชว์/ซ่อน section บน landing';


--
-- Name: COLUMN site_settings.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.id IS 'PK — บังคับเป็น 1 เท่านั้น';


--
-- Name: COLUMN site_settings.show_banners; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_banners IS 'โชว์ section Home Banners บน landing';


--
-- Name: COLUMN site_settings.show_skills; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_skills IS 'โชว์ section Skills บน landing';


--
-- Name: COLUMN site_settings.show_projects; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_projects IS 'โชว์ section Projects บน landing';


--
-- Name: COLUMN site_settings.show_experiences; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_experiences IS 'โชว์ section Experiences บน landing';


--
-- Name: COLUMN site_settings.show_education; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_education IS 'โชว์ section Education บน landing';


--
-- Name: COLUMN site_settings.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN site_settings.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN site_settings.show_about_me; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_about_me IS 'โชว์ section About Me บน landing';


--
-- Name: COLUMN site_settings.show_contact_me; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.site_settings.show_contact_me IS 'โชว์ section Contact Me บน landing';


--
-- Name: skills; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.skills (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    media_type character varying(32) NOT NULL,
    url text NOT NULL,
    display_order integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    deleted_at timestamp with time zone,
    CONSTRAINT skills_media_type_check CHECK (((media_type)::text = 'image'::text))
);


ALTER TABLE public.skills OWNER TO postgres;

--
-- Name: TABLE skills; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.skills IS 'ทักษะ / เทคโนโลยีที่แสดงบน personal website';


--
-- Name: COLUMN skills.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.id IS 'PK';


--
-- Name: COLUMN skills.name; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.name IS 'ชื่อทักษะ เช่น React, PostgreSQL';


--
-- Name: COLUMN skills.media_type; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.media_type IS 'ชนิดสื่อ: image | video | icon';


--
-- Name: COLUMN skills.url; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.url IS 'URL ของไอคอน / รูป / path ที่อัปโหลด';


--
-- Name: COLUMN skills.display_order; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.display_order IS 'ลำดับการแสดงผล (น้อย = ก่อน)';


--
-- Name: COLUMN skills.is_active; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.is_active IS 'สถานะเปิดใช้งาน';


--
-- Name: COLUMN skills.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.created_at IS 'เวลาสร้าง';


--
-- Name: COLUMN skills.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.updated_at IS 'เวลาแก้ไขล่าสุด';


--
-- Name: COLUMN skills.deleted_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.skills.deleted_at IS 'NULL = ยังใช้, มีค่า = soft delete';


--
-- Name: skills_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.skills ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.skills_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: website_visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.website_visits (
    id bigint NOT NULL,
    visit_date date NOT NULL,
    visit_count bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT website_visits_visit_count_check CHECK ((visit_count >= 0))
);


ALTER TABLE public.website_visits OWNER TO postgres;

--
-- Name: TABLE website_visits; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON TABLE public.website_visits IS 'ยอดเข้าชม personal website รวมรายวัน';


--
-- Name: COLUMN website_visits.id; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.website_visits.id IS 'PK';


--
-- Name: COLUMN website_visits.visit_date; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.website_visits.visit_date IS 'วันที่นับยอด (1 แถวต่อ 1 วัน)';


--
-- Name: COLUMN website_visits.visit_count; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.website_visits.visit_count IS 'จำนวนครั้งที่เข้าชมในวันนั้น';


--
-- Name: COLUMN website_visits.created_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.website_visits.created_at IS 'เวลาสร้างแถว';


--
-- Name: COLUMN website_visits.updated_at; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.website_visits.updated_at IS 'เวลาแก้ไขล่าสุด (อัปเดตเมื่อเพิ่มยอด)';


--
-- Name: website_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.website_visits ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.website_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Data for Name: about_me; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.about_me (id, title_th, title_en, text_animation_th, text_animation_en, description_th, description_en, image_url, github_url, resume_url, is_active, created_at, updated_at) FROM stdin;
1	ธีรภัทร สมมะลวน	Teerapat Sommaloun	Full-stack developer | Devops Engineer	Full-stack developer | Devops Engineer	<p>ผมคือ Developer ที่เชื่อว่าการพัฒนา Software ไม่ได้มีเพียงแค่การเขียน Code แต่คือการสร้าง Solution ที่แก้ปัญหาได้จริง ผมเลยมุ่งมั่นเรียนรู้และพัฒนาตัวเองอยู่เสมอ เพื่อสร้าง Software ที่มีประสิทธิภาพ มีคุณค่า และสามารถนำไปใช้งานได้จริงในโลกของการทำงาน</p>	<p>I believe that software development is more than just writing code — it’s about creating solutions that solve real-world problems. I’m committed to continuously learning and improving my skills to build software that is efficient, valuable, and practical for real-world use.</p>	https://trpgls.com/upload/about-me/dd6af49f-c625-47d3-982e-5f45b76a818f.jpg	https://github.com/TTeerapatt	\N	t	2026-09-18 07:59:20.491523+00	2026-09-21 04:51:47.432867+00
\.


--
-- Data for Name: admin_auth; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_auth (id, admin_id, password_hash, created_at, updated_at, deleted_at) FROM stdin;
1	1	$2b$10$AzuI64bzZ..JJu7l4uXJ1eioEx/fQSz5k1B5vxnTvtLqnMFoXj1AG	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
\.


--
-- Data for Name: admin_log; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_log (id, admin_id, action, entity_type, entity_id, message, meta, created_at, updated_at, deleted_at) FROM stdin;
1	1	login	admin	1	Admin logged in	\N	2026-09-08 09:48:34.209999+00	2026-09-08 09:48:34.209999+00	\N
2	1	login	admin	1	Admin logged in	\N	2026-09-08 15:37:56.762038+00	2026-09-08 15:37:56.762038+00	\N
3	1	login	admin	1	Admin logged in	\N	2026-09-08 15:40:55.372692+00	2026-09-08 15:40:55.372692+00	\N
4	1	login	admin	1	Admin logged in	\N	2026-09-08 16:05:39.459337+00	2026-09-08 16:05:39.459337+00	\N
5	1	create	home_banner	1	Created home banner test101	\N	2026-09-08 16:38:20.464514+00	2026-09-08 16:38:20.464514+00	\N
6	1	create	home_banner	2	Created home banner test102	\N	2026-09-08 16:43:58.421068+00	2026-09-08 16:43:58.421068+00	\N
7	1	login	admin	1	Admin logged in	\N	2026-09-08 16:49:57.429623+00	2026-09-08 16:49:57.429623+00	\N
8	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-08 16:53:32.053243+00	2026-09-08 16:53:32.053243+00	\N
9	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-08 16:53:37.258556+00	2026-09-08 16:53:37.258556+00	\N
10	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-08 16:56:40.473087+00	2026-09-08 16:56:40.473087+00	\N
11	1	create	home_banner	3	Created home banner test103	\N	2026-09-08 16:56:59.878681+00	2026-09-08 16:56:59.878681+00	\N
12	1	update	home_banner	\N	Reordered 3 home banners	\N	2026-09-08 16:57:04.560532+00	2026-09-08 16:57:04.560532+00	\N
13	1	update	home_banner	\N	Reordered 3 home banners	\N	2026-09-08 16:57:08.494105+00	2026-09-08 16:57:08.494105+00	\N
14	1	create	skill	1	Created skill NestJS	\N	2026-09-08 17:19:31.878244+00	2026-09-08 17:19:31.878244+00	\N
15	1	create	skill	2	Created skill NestJS	\N	2026-09-08 17:20:02.258138+00	2026-09-08 17:20:02.258138+00	\N
16	1	update	home_banner	\N	Reordered 3 home banners	\N	2026-09-08 17:20:18.942138+00	2026-09-08 17:20:18.942138+00	\N
17	1	update	home_banner	\N	Reordered 3 home banners	\N	2026-09-08 17:20:22.555881+00	2026-09-08 17:20:22.555881+00	\N
18	1	create	skill	3	Created skill 101	\N	2026-09-08 17:34:31.597689+00	2026-09-08 17:34:31.597689+00	\N
19	1	create	skill	4	Created skill 102	\N	2026-09-08 17:34:46.856925+00	2026-09-08 17:34:46.856925+00	\N
20	1	update	skill	3	Updated skill 101010101	\N	2026-09-08 17:41:47.098718+00	2026-09-08 17:41:47.098718+00	\N
21	1	login	admin	1	Admin logged in	\N	2026-09-08 17:54:23.547357+00	2026-09-08 17:54:23.547357+00	\N
22	1	login	admin	1	Admin logged in	\N	2026-09-09 03:39:37.35677+00	2026-09-09 03:39:37.35677+00	\N
23	1	login	admin	1	Admin logged in	\N	2026-09-09 14:34:34.160364+00	2026-09-09 14:34:34.160364+00	\N
24	1	create	project	1	Created project test102	\N	2026-09-09 15:32:41.871565+00	2026-09-09 15:32:41.871565+00	\N
25	1	login	admin	1	Admin logged in	\N	2026-09-10 05:12:21.855216+00	2026-09-10 05:12:21.855216+00	\N
26	1	update	site_settings	1	Updated site settings	\N	2026-09-10 06:22:09.971386+00	2026-09-10 06:22:09.971386+00	\N
27	1	login	admin	1	Admin logged in	\N	2026-09-10 09:04:05.703851+00	2026-09-10 09:04:05.703851+00	\N
28	1	create	home_banner	4	Created home banner ฟหก	\N	2026-09-10 09:07:11.653965+00	2026-09-10 09:07:11.653965+00	\N
29	1	create	home_banner	5	Created home banner ฟหก	\N	2026-09-10 09:10:04.509642+00	2026-09-10 09:10:04.509642+00	\N
30	1	create	home_banner	1	Created home banner ฟหก	\N	2026-09-10 09:11:24.681152+00	2026-09-10 09:11:24.681152+00	\N
31	1	create	home_banner	1	Created home banner test101	\N	2026-09-10 09:15:01.272667+00	2026-09-10 09:15:01.272667+00	\N
32	1	update	home_banner	1	Updated home banner test101	\N	2026-09-10 09:21:17.140838+00	2026-09-10 09:21:17.140838+00	\N
33	1	update	home_banner	1	Updated home banner test101	\N	2026-09-10 09:23:06.077341+00	2026-09-10 09:23:06.077341+00	\N
34	1	update	home_banner	1	Updated home banner test101	\N	2026-09-10 09:23:24.676642+00	2026-09-10 09:23:24.676642+00	\N
35	1	update	home_banner	1	Updated home banner test101	\N	2026-09-10 09:23:57.525528+00	2026-09-10 09:23:57.525528+00	\N
36	1	login	admin	1	Admin logged in	\N	2026-09-10 09:31:32.177217+00	2026-09-10 09:31:32.177217+00	\N
37	1	create	project	1	Created project ฟหกฟหก	\N	2026-09-10 09:53:02.832778+00	2026-09-10 09:53:02.832778+00	\N
38	1	create	skill	1	Created skill ฟหก	\N	2026-09-10 09:59:10.844879+00	2026-09-10 09:59:10.844879+00	\N
39	1	create	home_banner	2	Created home banner ฟหกฟหก	\N	2026-09-10 10:01:36.627389+00	2026-09-10 10:01:36.627389+00	\N
40	1	create	experience	1	Created experience กฟกฟห	\N	2026-09-10 10:33:54.698875+00	2026-09-10 10:33:54.698875+00	\N
41	1	update	experience	1	Updated experience กฟกฟห	\N	2026-09-10 10:41:52.336324+00	2026-09-10 10:41:52.336324+00	\N
42	1	login	admin	1	Admin logged in	\N	2026-09-10 16:24:07.467863+00	2026-09-10 16:24:07.467863+00	\N
43	1	login	admin	1	Admin logged in	\N	2026-09-11 07:12:26.793257+00	2026-09-11 07:12:26.793257+00	\N
44	1	login	admin	1	Admin logged in	\N	2026-09-11 07:19:22.10052+00	2026-09-11 07:19:22.10052+00	\N
45	1	login	admin	1	Admin logged in	\N	2026-09-11 07:22:38.343438+00	2026-09-11 07:22:38.343438+00	\N
46	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-11 07:39:29.358383+00	2026-09-11 07:39:29.358383+00	\N
47	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-11 07:39:43.680812+00	2026-09-11 07:39:43.680812+00	\N
48	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-11 07:40:04.643657+00	2026-09-11 07:40:04.643657+00	\N
49	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-11 07:40:13.239593+00	2026-09-11 07:40:13.239593+00	\N
50	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-11 07:40:45.701991+00	2026-09-11 07:40:45.701991+00	\N
51	1	create	experience	2	Created experience dsfdsfdsf	\N	2026-09-11 07:42:11.184647+00	2026-09-11 07:42:11.184647+00	\N
52	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-11 07:53:34.954646+00	2026-09-11 07:53:34.954646+00	\N
53	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-11 07:53:38.597499+00	2026-09-11 07:53:38.597499+00	\N
54	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-11 07:53:42.147719+00	2026-09-11 07:53:42.147719+00	\N
55	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-11 07:53:45.914143+00	2026-09-11 07:53:45.914143+00	\N
56	1	update	home_banner	\N	Reordered 2 home banners	\N	2026-09-11 07:53:51.574427+00	2026-09-11 07:53:51.574427+00	\N
57	1	login	admin	1	Admin logged in	\N	2026-09-11 08:01:16.021085+00	2026-09-11 08:01:16.021085+00	\N
58	1	login	admin	1	Admin logged in	\N	2026-09-11 08:07:41.984893+00	2026-09-11 08:07:41.984893+00	\N
59	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:07:47.759657+00	2026-09-11 08:07:47.759657+00	\N
60	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:08:00.330831+00	2026-09-11 08:08:00.330831+00	\N
61	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:08:09.05899+00	2026-09-11 08:08:09.05899+00	\N
62	1	create	project	2	Created project กฟหกฟหก	\N	2026-09-11 08:08:23.655902+00	2026-09-11 08:08:23.655902+00	\N
63	1	update	project	\N	Reordered 2 projects	\N	2026-09-11 08:08:27.802886+00	2026-09-11 08:08:27.802886+00	\N
64	1	soft_delete	project	2	Soft deleted project #2	\N	2026-09-11 08:08:32.789859+00	2026-09-11 08:08:32.789859+00	\N
65	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:12:16.965974+00	2026-09-11 08:12:16.965974+00	\N
66	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:12:22.595687+00	2026-09-11 08:12:22.595687+00	\N
67	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:12:28.062464+00	2026-09-11 08:12:28.062464+00	\N
68	1	create	project	3	Created project ฟหกฟกฟห	\N	2026-09-11 08:12:35.64533+00	2026-09-11 08:12:35.64533+00	\N
69	1	update	project	\N	Reordered 2 projects	\N	2026-09-11 08:12:39.605058+00	2026-09-11 08:12:39.605058+00	\N
70	1	create	project	4	Created project ฟหกฟกฟห	\N	2026-09-11 08:12:43.689523+00	2026-09-11 08:12:43.689523+00	\N
71	1	update	project	4	Updated project ฟหกฟกฟหหหหหฟฟฟ	\N	2026-09-11 08:12:50.362638+00	2026-09-11 08:12:50.362638+00	\N
72	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:12:57.040589+00	2026-09-11 08:12:57.040589+00	\N
73	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:12:59.958649+00	2026-09-11 08:12:59.958649+00	\N
74	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:13:02.822759+00	2026-09-11 08:13:02.822759+00	\N
75	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:13:05.788583+00	2026-09-11 08:13:05.788583+00	\N
76	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:13:07.778496+00	2026-09-11 08:13:07.778496+00	\N
77	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:13:11.966078+00	2026-09-11 08:13:11.966078+00	\N
78	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:13:20.946861+00	2026-09-11 08:13:20.946861+00	\N
79	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:13:23.328099+00	2026-09-11 08:13:23.328099+00	\N
80	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:13:28.752624+00	2026-09-11 08:13:28.752624+00	\N
81	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:13:55.824272+00	2026-09-11 08:13:55.824272+00	\N
82	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:14:23.121491+00	2026-09-11 08:14:23.121491+00	\N
83	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:14:26.221429+00	2026-09-11 08:14:26.221429+00	\N
84	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:16:42.355233+00	2026-09-11 08:16:42.355233+00	\N
85	1	update	experience	\N	Reordered 2 experiences	\N	2026-09-11 08:16:46.99685+00	2026-09-11 08:16:46.99685+00	\N
86	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:17:38.63925+00	2026-09-11 08:17:38.63925+00	\N
87	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:17:41.002886+00	2026-09-11 08:17:41.002886+00	\N
88	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:17:43.733997+00	2026-09-11 08:17:43.733997+00	\N
89	1	update	project	\N	Reordered 3 projects	\N	2026-09-11 08:17:49.280959+00	2026-09-11 08:17:49.280959+00	\N
90	1	soft_delete	project	4	Soft deleted project #4	\N	2026-09-11 08:18:01.812323+00	2026-09-11 08:18:01.812323+00	\N
91	1	soft_delete	project	3	Soft deleted project #3	\N	2026-09-11 08:18:05.633921+00	2026-09-11 08:18:05.633921+00	\N
92	1	soft_delete	experience	2	Soft deleted experience #2	\N	2026-09-11 08:18:14.840244+00	2026-09-11 08:18:14.840244+00	\N
93	1	login	admin	1	Admin logged in	\N	2026-09-13 03:46:29.716988+00	2026-09-13 03:46:29.716988+00	\N
94	1	login	admin	1	Admin logged in	\N	2026-09-14 06:25:03.63363+00	2026-09-14 06:25:03.63363+00	\N
95	1	login	admin	1	Admin logged in	\N	2026-09-14 06:25:14.159124+00	2026-09-14 06:25:14.159124+00	\N
96	1	update	about_me	1	Updated about me	\N	2026-09-15 04:20:20.844977+00	2026-09-15 04:20:20.844977+00	\N
97	1	login	admin	1	Admin logged in	\N	2026-09-15 04:54:34.694768+00	2026-09-15 04:54:34.694768+00	\N
98	1	update	site_settings	1	Updated site settings	\N	2026-09-15 14:36:19.767172+00	2026-09-15 14:36:19.767172+00	\N
99	1	set_active	project	1	Set project #1 is_active=false	{"is_active": false}	2026-09-16 17:21:39.667234+00	2026-09-16 17:21:39.667234+00	\N
100	1	set_active	project	1	Set project #1 is_active=true	{"is_active": true}	2026-09-16 17:21:42.063547+00	2026-09-16 17:21:42.063547+00	\N
101	1	update	contact_me	1	Updated contact me	\N	2026-09-17 16:21:31.199114+00	2026-09-17 16:21:31.199114+00	\N
102	1	update	about_me	1	Updated about me	\N	2026-09-18 09:16:45.598932+00	2026-09-18 09:16:45.598932+00	\N
103	1	login	admin	1	Admin logged in	\N	2026-09-18 09:48:01.875274+00	2026-09-18 09:48:01.875274+00	\N
104	1	login	admin	1	Admin logged in	\N	2026-09-20 11:27:15.666647+00	2026-09-20 11:27:15.666647+00	\N
105	1	create	skill	1	Created skill Docker	\N	2026-09-20 11:41:27.465819+00	2026-09-20 11:41:27.465819+00	\N
106	1	create	skill	2	Created skill Jenkins	\N	2026-09-20 11:41:52.751874+00	2026-09-20 11:41:52.751874+00	\N
107	1	create	skill	3	Created skill Kubernetes	\N	2026-09-20 11:42:09.003178+00	2026-09-20 11:42:09.003178+00	\N
108	1	create	skill	4	Created skill SonarQube	\N	2026-09-20 11:42:30.705775+00	2026-09-20 11:42:30.705775+00	\N
109	1	create	skill	5	Created skill Next	\N	2026-09-20 11:42:46.416884+00	2026-09-20 11:42:46.416884+00	\N
110	1	create	skill	6	Created skill React	\N	2026-09-20 11:43:00.625581+00	2026-09-20 11:43:00.625581+00	\N
111	1	create	skill	7	Created skill Nest	\N	2026-09-20 11:43:15.938294+00	2026-09-20 11:43:15.938294+00	\N
112	1	create	skill	8	Created skill Express	\N	2026-09-20 11:43:33.538293+00	2026-09-20 11:43:33.538293+00	\N
113	1	create	skill	9	Created skill Django	\N	2026-09-20 11:43:46.134562+00	2026-09-20 11:43:46.134562+00	\N
114	1	create	skill	10	Created skill Postgres	\N	2026-09-20 11:44:05.264262+00	2026-09-20 11:44:05.264262+00	\N
115	1	create	skill	11	Created skill Mysql	\N	2026-09-20 11:44:20.710353+00	2026-09-20 11:44:20.710353+00	\N
116	1	create	skill	12	Created skill MongoDB	\N	2026-09-20 11:44:33.133502+00	2026-09-20 11:44:33.133502+00	\N
117	1	create	skill	13	Created skill Fireabse	\N	2026-09-20 11:44:51.663691+00	2026-09-20 11:44:51.663691+00	\N
118	1	create	skill	14	Created skill Redis	\N	2026-09-20 11:45:13.767382+00	2026-09-20 11:45:13.767382+00	\N
119	1	create	skill	15	Created skill Socket.io	\N	2026-09-20 11:45:37.31881+00	2026-09-20 11:45:37.31881+00	\N
120	1	update	about_me	1	Updated about me	\N	2026-09-21 04:32:20.854767+00	2026-09-21 04:32:20.854767+00	\N
121	1	create	home_banner	1	Created home banner 1	\N	2026-09-21 04:50:33.913661+00	2026-09-21 04:50:33.913661+00	\N
122	1	create	home_banner	2	Created home banner 2	\N	2026-09-21 04:50:54.066137+00	2026-09-21 04:50:54.066137+00	\N
123	1	create	home_banner	3	Created home banner 3	\N	2026-09-21 04:51:03.402334+00	2026-09-21 04:51:03.402334+00	\N
124	1	create	home_banner	4	Created home banner 4	\N	2026-09-21 04:51:16.312241+00	2026-09-21 04:51:16.312241+00	\N
125	1	create	home_banner	5	Created home banner 5	\N	2026-09-21 04:51:32.186651+00	2026-09-21 04:51:32.186651+00	\N
126	1	update	about_me	1	Updated about me	\N	2026-09-21 04:51:47.432867+00	2026-09-21 04:51:47.432867+00	\N
127	1	create	project	1	Created project Nexus	\N	2026-09-21 05:48:02.51432+00	2026-09-21 05:48:02.51432+00	\N
128	1	create	experience	1	Created experience Greenline synergy co. ltd	\N	2026-09-21 06:03:40.102477+00	2026-09-21 06:03:40.102477+00	\N
129	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-21 06:11:57.237973+00	2026-09-21 06:11:57.237973+00	\N
130	1	create	education	1	Created education Thepmitrsuksa School	\N	2026-09-21 06:34:33.632179+00	2026-09-21 06:34:33.632179+00	\N
131	1	create	education	2	Created education Walailak University	\N	2026-09-21 06:36:20.361869+00	2026-09-21 06:36:20.361869+00	\N
132	1	update	education	1	Updated education Thepmitrsuksa School	\N	2026-09-21 06:39:52.540789+00	2026-09-21 06:39:52.540789+00	\N
133	1	update	education	2	Updated education Walailak University	\N	2026-09-21 06:43:07.035155+00	2026-09-21 06:43:07.035155+00	\N
134	1	update	experience	1	Updated experience Greenline synergy co. ltd	\N	2026-09-21 06:43:31.205759+00	2026-09-21 06:43:31.205759+00	\N
135	1	create	experience	2	Created experience 3DTVTECH COMPANY LIMITED	\N	2026-09-21 06:45:31.561792+00	2026-09-21 06:45:31.561792+00	\N
136	1	update	education	2	Updated education Walailak University	\N	2026-09-21 06:48:57.109114+00	2026-09-21 06:48:57.109114+00	\N
137	1	update	contact_me	1	Updated contact me	\N	2026-09-21 06:51:23.684182+00	2026-09-21 06:51:23.684182+00	\N
138	1	login	admin	1	Admin logged in	\N	2026-09-30 08:32:34.083107+00	2026-09-30 08:32:34.083107+00	\N
\.


--
-- Data for Name: admin_menu_label; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_menu_label (id, code, name, is_active, sort_order, created_at, updated_at, deleted_at) FROM stdin;
1	dashboard	Dashboard	t	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
2	content	Content	t	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
3	management	Management	t	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
4	logs	Logs	t	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
\.


--
-- Data for Name: admin_menu_tab; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_menu_tab (id, menu_label_id, code, name, is_active, sort_order, created_at, updated_at, deleted_at) FROM stdin;
6	1	overview	Overview	t	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
7	1	bi	BI	t	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
8	4	logs	Logs	t	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
9	3	admins	Admins	t	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
1	2	home-banners	Home Banners	t	0	2026-09-08 05:16:11.078512+00	2026-09-15 04:53:25.801669+00	\N
2	2	skills	Skills	t	2	2026-09-08 05:16:11.078512+00	2026-09-15 04:53:25.801669+00	\N
3	2	projects	Projects	t	3	2026-09-08 05:16:11.078512+00	2026-09-15 04:53:25.801669+00	\N
4	2	experiences	Experiences	t	4	2026-09-08 05:16:11.078512+00	2026-09-15 04:53:25.801669+00	\N
5	2	education	Education	t	5	2026-09-08 05:16:11.078512+00	2026-09-15 04:53:25.801669+00	\N
11	2	about-me	About Me	t	1	2026-09-15 04:00:17.885745+00	2026-09-15 04:53:25.801669+00	\N
12	2	contact-me	Contact Me	t	6	2026-09-15 04:53:25.801669+00	2026-09-15 04:53:25.801669+00	\N
10	3	site-settings	Site Settings	t	7	2026-09-10 05:10:36.217425+00	2026-09-15 04:53:25.801669+00	\N
\.


--
-- Data for Name: admin_menu_tab_action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_menu_tab_action (id, menu_tab_id, permission_action_id, created_at, updated_at, deleted_at) FROM stdin;
1	6	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
2	7	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
3	1	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
4	1	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
5	1	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
6	1	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
7	1	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
8	2	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
9	2	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
10	2	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
11	2	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
12	2	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
13	3	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
14	3	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
15	3	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
16	3	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
17	3	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
18	4	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
19	4	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
20	4	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
21	4	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
22	4	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
23	5	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
24	5	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
25	5	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
26	5	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
27	5	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
28	9	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
29	9	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
30	9	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
31	9	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
32	9	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
33	8	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
34	10	1	2026-09-10 05:10:36.217425+00	2026-09-10 05:10:36.217425+00	\N
35	10	3	2026-09-10 05:10:36.217425+00	2026-09-10 05:10:36.217425+00	\N
36	11	1	2026-09-15 04:00:17.885745+00	2026-09-15 04:00:17.885745+00	\N
37	11	3	2026-09-15 04:00:17.885745+00	2026-09-15 04:00:17.885745+00	\N
38	12	1	2026-09-15 04:53:25.801669+00	2026-09-15 04:53:25.801669+00	\N
39	12	3	2026-09-15 04:53:25.801669+00	2026-09-15 04:53:25.801669+00	\N
\.


--
-- Data for Name: admin_permission_action; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_permission_action (id, code, name, is_active, description, sort_order, created_at, updated_at, deleted_at) FROM stdin;
1	view	View	t	ดูข้อมูล	1	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
2	add	Add	t	เพิ่มข้อมูล	2	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
3	edit	Edit	t	แก้ไขข้อมูล	3	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
4	delete	Delete	t	ลบข้อมูล	4	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
5	export	Export	t	ส่งออกข้อมูล	5	2026-09-08 05:16:11.078512+00	2026-09-08 05:16:11.078512+00	\N
\.


--
-- Data for Name: admin_permissions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admin_permissions (id, admin_id, menu_tab_action_id, is_allowed, created_at, updated_at, deleted_at) FROM stdin;
1	1	28	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
2	1	29	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
3	1	30	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
4	1	31	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
5	1	32	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
6	1	2	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
7	1	23	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
8	1	24	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
9	1	25	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
10	1	26	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
11	1	27	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
12	1	18	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
13	1	19	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
14	1	20	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
15	1	21	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
16	1	22	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
17	1	3	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
18	1	4	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
19	1	5	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
20	1	6	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
21	1	7	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
22	1	33	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
23	1	1	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
24	1	13	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
25	1	14	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
26	1	15	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
27	1	16	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
28	1	17	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
29	1	8	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
30	1	9	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
31	1	10	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
32	1	11	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
33	1	12	t	2026-09-08 05:16:22.88581+00	2026-09-08 05:16:22.88581+00	\N
34	1	34	t	2026-09-10 05:10:36.217425+00	2026-09-10 05:10:36.217425+00	\N
35	1	35	t	2026-09-10 05:10:36.217425+00	2026-09-10 05:10:36.217425+00	\N
36	1	36	t	2026-09-15 04:00:17.885745+00	2026-09-15 04:00:17.885745+00	\N
37	1	37	t	2026-09-15 04:00:17.885745+00	2026-09-15 04:00:17.885745+00	\N
38	1	38	t	2026-09-15 04:53:25.801669+00	2026-09-15 04:53:25.801669+00	\N
39	1	39	t	2026-09-15 04:53:25.801669+00	2026-09-15 04:53:25.801669+00	\N
\.


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, email, display_name, role, last_login_at, created_at, updated_at, deleted_at) FROM stdin;
1	rznot778@gmail.com	Owner	owner	2026-09-30 08:32:34.083107+00	2026-09-08 05:16:22.88581+00	2026-09-30 08:32:34.083107+00	\N
\.


--
-- Data for Name: contact_me; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.contact_me (id, name_th, name_en, phone, email, github_url, linkedin_url, facebook_url, instagram_url, is_active, created_at, updated_at) FROM stdin;
1	ธีรภัทร สมมะลวน	Teerapat Sommaloun	0837543886	rznot778@gmail.com	https://github.com/TTeerapatt	\N	https://www.facebook.com/teerapat.sommaloun/	https://www.instagram.com/teerxpxt/	t	2026-09-18 07:59:20.478977+00	2026-09-21 06:51:23.684182+00
\.


--
-- Data for Name: education; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.education (id, name_th, name_en, description_th, description_en, start_date, end_date, media_type, url, is_active, created_at, updated_at, deleted_at, display_order) FROM stdin;
1	โรงเรียนเทพมิตรศึกษา	Thepmitrsuksa School	<p>ศึกษาระดับมัธยมศึกษาตั้งแต่ชั้นมัธยมศึกษาปีที่ 1 ถึง 6 ณ โรงเรียนเทพมิตรศึกษา โดยในระดับชั้นมัธยมศึกษาปีที่ 4–6 ได้เลือกศึกษาในแผนการเรียน <strong>ศิลป์–คำนวณ</strong> และสำเร็จการศึกษาด้วยเกรดเฉลี่ยสะสม <strong>3.74</strong></p>	<p>Completed secondary education from Grade 7 to Grade 12 at <strong>Thepmitr Suksa School</strong>, specializing in the <strong>Arts–Mathematics Program</strong> during Grades 10–12, with a cumulative GPA of <strong>3.74</strong>.</p>	2016-05-16	2021-02-16	image	https://trpgls.com/upload/education/58a4c953-2ece-409b-b349-43a849ba31b4.png	t	2026-09-21 06:34:33.632179+00	2026-09-21 06:39:52.540789+00	\N	0
2	มหาวิทยาลัยวลัยลักษณ์	Walailak University	<p>สำเร็จการศึกษาระดับปริญญาตรีจาก <strong>คณะสารสนเทศศาสตร์ สาขานวัตกรรมสารสนเทศทางการแพทย์</strong> ได้รับวุฒิ <strong>วิทยาศาสตรบัณฑิต (วท.บ.)</strong> ด้วยเกรดเฉลี่ยสะสม <strong>3.78</strong></p><p>ตลอดระยะเวลาการศึกษา ทั้งหลักสูตรและอาจารย์ผู้สอนได้เปิดโอกาสให้ผมได้เรียนรู้และค้นพบความสนุก รวมถึงความหลงใหลในการ <strong>Coding</strong> ซึ่งกลายเป็นแรงผลักดันสำคัญในการพัฒนาทักษะด้าน Software Development และทำให้ผมสนุกกับการสร้างสรรค์ผลงาน รวมถึงการนำเทคโนโลยีมาใช้ในการแก้ไขปัญหาอย่างเป็นระบบ</p>	<p>I earned my Bachelor's degree from the <strong>Faculty of Informatics, majoring in Medical Information Innovation</strong>, receiving a <strong>Bachelor of Science (</strong><a target="_blank" rel="noopener noreferrer" href="http://B.Sc"><strong>B.Sc</strong></a><strong>.)</strong> with a cumulative GPA of <strong>3.78</strong>.</p><p>Throughout my studies, the curriculum and professors gave me the opportunity to discover the joy and passion I have for <strong>coding</strong>. This experience became an important driving force behind my journey in Software Development, inspiring me to create meaningful projects and use technology to solve problems in a structured and practical way.</p>	2022-03-21	2025-11-28	image	https://trpgls.com/upload/education/7139ab04-ee21-4e5b-92a0-fcef18b03d4a.png	t	2026-09-21 06:36:20.361869+00	2026-09-21 06:48:57.109114+00	\N	1
\.


--
-- Data for Name: experiences; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.experiences (id, name_th, name_en, description_th, description_en, "position", start_date, end_date, media_type, url, is_active, created_at, updated_at, deleted_at, display_order) FROM stdin;
1	บริษัท กรีนไลน์ ซินเนอร์จี้ จำกัด	Greenline synergy co. ltd	<p>เข้าร่วมโครงการสหกิจศึกษาเป็นระยะเวลา 8 เดือน ในตำแหน่ง <strong>Full-Stack Developer</strong> โดยมีหน้าที่พัฒนาและดูแลระบบ Software สำหรับใช้งานภายในองค์กร รวมถึงพัฒนา <strong>Internal Chat Application</strong> สำหรับบุคลากรภายในโรงพยาบาลในเครือ <strong>บริษัท กรุงเทพดุสิตเวชการ จำกัด (มหาชน)</strong> โดยให้ความสำคัญกับความปลอดภัยของข้อมูลและการใช้งานในระดับองค์กร</p>	<p>Completed an 8-month cooperative education program as a <strong>Full-Stack Developer</strong>, responsible for developing and maintaining internal software systems. One of the main projects was an <strong>Internal Chat Application</strong> designed for personnel within hospitals under <strong>Bangkok Dusit Medical Services Public Company Limited (BDMS)</strong>, with a strong focus on data security and enterprise-level usability.</p>	Full-stack Developer Intern	2025-04-14	2025-11-28	image	https://trpgls.com/upload/experiences/a89510fd-1b06-451e-9db3-489ac5d54112.png	t	2026-09-21 06:03:40.102477+00	2026-09-21 06:43:31.205759+00	\N	0
2	บริษัท สามดีทีวีเทค จำกัด	3DTVTECH COMPANY LIMITED	<p>ปฏิบัติงานในตำแหน่ง <strong>Full-Stack Developer</strong> โดยรับผิดชอบการออกแบบ พัฒนา และดูแลระบบ Software สำหรับหน่วยงานภาครัฐและองค์กรที่เกี่ยวข้องกับการพัฒนาสังคมและการศึกษา โดยมีส่วนร่วมในการพัฒนาระบบให้กับ <strong>สถาบันเทคโนโลยีและสารสนเทศเพื่อการพัฒนาที่ยั่งยืน</strong> และ <strong>กองทุนเพื่อความเสมอภาคทางการศึกษา (กสศ. / EEF)</strong></p>	<p>Working as a <strong>Full-Stack Developer</strong>, responsible for designing, developing, and maintaining software systems for government-related organizations and social development initiatives. My work includes contributing to software projects for the <strong>Institute of Technology and Information for Sustainable Development</strong> and the <strong>Equitable Education Fund (EEF)</strong>.</p>	Full-stack Developer	2025-12-16	\N	image	https://trpgls.com/upload/experiences/d90ec4e0-374b-4f9c-9210-59a5673e7a81.jpeg	t	2026-09-21 06:45:31.561792+00	2026-09-21 06:45:31.561792+00	\N	1
\.


--
-- Data for Name: home_banners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.home_banners (id, name, media_type, url, display_order, is_active, created_at, updated_at, deleted_at) FROM stdin;
1	1	image	https://trpgls.com/upload/home-banners/2aad15de-67fc-4089-acff-f3fc6857a30f.jpg	0	t	2026-09-21 04:50:33.913661+00	2026-09-21 04:50:33.913661+00	\N
2	2	image	https://trpgls.com/upload/home-banners/7576789c-02c7-46d9-a4f6-ec9c58bb928e.jpg	1	t	2026-09-21 04:50:54.066137+00	2026-09-21 04:50:54.066137+00	\N
3	3	image	https://trpgls.com/upload/home-banners/4078a751-70bb-4097-8f85-aa33aeff21a9.jpg	2	t	2026-09-21 04:51:03.402334+00	2026-09-21 04:51:03.402334+00	\N
4	4	image	https://trpgls.com/upload/home-banners/cab59077-f584-4216-9209-c5ac815bdefe.jpg	3	t	2026-09-21 04:51:16.312241+00	2026-09-21 04:51:16.312241+00	\N
5	5	image	https://trpgls.com/upload/home-banners/34d88886-a300-440d-9b2c-2bf3373b20b4.jpg	4	t	2026-09-21 04:51:32.186651+00	2026-09-21 04:51:32.186651+00	\N
\.


--
-- Data for Name: projects; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.projects (id, name_th, name_en, description_th, description_en, thumbnail_url, github_url, demo_url, display_order, is_active, created_at, updated_at, deleted_at) FROM stdin;
1	Nexus	Nexus	<p>Nexus เป็น Personal Project ที่ผมพัฒนาขึ้นเพื่อแก้ปัญหาและตอบสนองความต้องการในการจัดการระบบและ Infrastructure ของตัวเอง โดยมีแนวคิดในการรวบรวมข้อมูลสำคัญของแต่ละ Project, Server, Service และ Resource ให้อยู่ภายในระบบเดียว เพื่อให้สามารถติดตาม ตรวจสอบ และจัดการ Infrastructure ได้สะดวกมากยิ่งขึ้น</p><p>ระบบถูกออกแบบให้สามารถเชื่อมต่อกับเครื่องมือและ Services ที่ใช้งานในกระบวนการ Development และ DevOps เช่น Jenkins, GitHub, SonarQube และ VPS ผ่าน API เพื่อดึงข้อมูลมาแสดงผลแบบรวมศูนย์ โดย Nexus ไม่ได้มีหน้าที่เพียงแค่แสดงข้อมูล แต่ยังถูกออกแบบให้เป็นศูนย์กลางสำหรับ Monitoring และ Management ของระบบต่าง ๆ</p><p>โปรเจกต์นี้เป็นหนึ่งในโปรเจกต์ที่ผมใช้ศึกษาและพัฒนาทักษะด้าน Full-Stack Development, API Integration, DevOps และ System Architecture ตั้งแต่การออกแบบ Database, Backend API, Frontend Dashboard ไปจนถึงการ Deploy และจัดการระบบบน Server จริง</p>	<p>Nexus is a personal project I developed to address my own needs for managing and monitoring infrastructure. The idea is to bring important information about projects, servers, services, and resources into a single platform, making it easier to track, monitor, and manage different parts of my infrastructure.</p><p>The system is designed to integrate with development and DevOps tools such as Jenkins, GitHub, SonarQube, and VPS environments through APIs, allowing data from different services to be accessed and visualized in one place. Rather than simply displaying information, Nexus is designed to serve as a centralized platform for infrastructure monitoring and management.</p><p>This project has also been an opportunity for me to strengthen my skills in Full-Stack Development, API Integration, DevOps, and System Architecture — from designing the database and backend APIs to building the frontend dashboard, deploying applications, and managing services on real-world servers.</p>	https://trpgls.com/upload/projects/f6ac54b2-cf57-4fcc-838e-0fbd18c64925.png	\N	\N	0	t	2026-09-21 05:48:02.51432+00	2026-09-21 05:48:02.51432+00	\N
\.


--
-- Data for Name: site_settings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.site_settings (id, show_banners, show_skills, show_projects, show_experiences, show_education, created_at, updated_at, show_about_me, show_contact_me) FROM stdin;
1	t	t	t	t	t	2026-09-10 05:10:36.217425+00	2026-09-15 14:36:19.767172+00	t	t
\.


--
-- Data for Name: skills; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.skills (id, name, media_type, url, display_order, is_active, created_at, updated_at, deleted_at) FROM stdin;
1	Docker	image	https://trpgls.com/upload/skills/9c5b5504-527a-4607-94f8-3cfe2c36e5e5.png	0	t	2026-09-20 11:41:27.465819+00	2026-09-20 11:41:27.465819+00	\N
2	Jenkins	image	https://trpgls.com/upload/skills/32ebbd35-0bc1-44bf-a76b-133e14784fd8.png	1	t	2026-09-20 11:41:52.751874+00	2026-09-20 11:41:52.751874+00	\N
3	Kubernetes	image	https://trpgls.com/upload/skills/3a814685-d7cb-4b05-a497-23f358490275.png	2	t	2026-09-20 11:42:09.003178+00	2026-09-20 11:42:09.003178+00	\N
4	SonarQube	image	https://trpgls.com/upload/skills/758a536b-4d79-4f32-b97a-26085a7f1b1a.png	3	t	2026-09-20 11:42:30.705775+00	2026-09-20 11:42:30.705775+00	\N
5	Next	image	https://trpgls.com/upload/skills/768d232f-1380-4587-8149-1694c3106d79.png	4	t	2026-09-20 11:42:46.416884+00	2026-09-20 11:42:46.416884+00	\N
6	React	image	https://trpgls.com/upload/skills/eac5f741-41e3-4558-bfba-8b5e784d9017.png	5	t	2026-09-20 11:43:00.625581+00	2026-09-20 11:43:00.625581+00	\N
7	Nest	image	https://trpgls.com/upload/skills/192dfd15-1890-4180-8766-262c087c09d8.png	6	t	2026-09-20 11:43:15.938294+00	2026-09-20 11:43:15.938294+00	\N
8	Express	image	https://trpgls.com/upload/skills/e5ce4fb4-26b7-4181-8b40-314ef4359b2d.png	7	t	2026-09-20 11:43:33.538293+00	2026-09-20 11:43:33.538293+00	\N
9	Django	image	https://trpgls.com/upload/skills/248d438f-1ba5-4734-92d2-2cf828d6c0e8.png	8	t	2026-09-20 11:43:46.134562+00	2026-09-20 11:43:46.134562+00	\N
10	Postgres	image	https://trpgls.com/upload/skills/2b61b737-57b2-47fc-b928-93da40910496.png	9	t	2026-09-20 11:44:05.264262+00	2026-09-20 11:44:05.264262+00	\N
11	Mysql	image	https://trpgls.com/upload/skills/57a31994-cf62-4bc0-96df-77525ab66b1c.png	10	t	2026-09-20 11:44:20.710353+00	2026-09-20 11:44:20.710353+00	\N
12	MongoDB	image	https://trpgls.com/upload/skills/02a3977f-f057-46ed-aa0b-11e3d45467cd.png	11	t	2026-09-20 11:44:33.133502+00	2026-09-20 11:44:33.133502+00	\N
13	Fireabse	image	https://trpgls.com/upload/skills/9548be4f-2250-4b04-9280-78d67006c377.png	12	t	2026-09-20 11:44:51.663691+00	2026-09-20 11:44:51.663691+00	\N
14	Redis	image	https://trpgls.com/upload/skills/1cb4aa59-3f02-42c4-b6e2-88bded2e38ed.png	13	t	2026-09-20 11:45:13.767382+00	2026-09-20 11:45:13.767382+00	\N
15	Socket.io	image	https://trpgls.com/upload/skills/b1d53d43-1a1e-4c18-9d50-75325970950f.png	14	t	2026-09-20 11:45:37.31881+00	2026-09-20 11:45:37.31881+00	\N
\.


--
-- Data for Name: website_visits; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.website_visits (id, visit_date, visit_count, created_at, updated_at) FROM stdin;
1	2026-09-18	2	2026-09-18 03:32:08.461896+00	2026-09-18 08:56:32.784504+00
3	2026-09-20	1	2026-09-20 11:49:02.243354+00	2026-09-20 11:49:02.243354+00
4	2026-09-21	2	2026-09-21 04:17:39.070808+00	2026-09-21 07:00:34.929027+00
6	2026-09-30	3	2026-09-30 08:34:07.692177+00	2026-09-30 09:29:20.437592+00
\.


--
-- Name: admin_auth_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_auth_id_seq', 1, true);


--
-- Name: admin_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_log_id_seq', 138, true);


--
-- Name: admin_menu_label_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_menu_label_id_seq', 4, true);


--
-- Name: admin_menu_tab_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_menu_tab_action_id_seq', 39, true);


--
-- Name: admin_menu_tab_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_menu_tab_id_seq', 12, true);


--
-- Name: admin_permission_action_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_permission_action_id_seq', 5, true);


--
-- Name: admin_permissions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admin_permissions_id_seq', 39, true);


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: education_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.education_id_seq', 2, true);


--
-- Name: experiences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.experiences_id_seq', 2, true);


--
-- Name: home_banners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.home_banners_id_seq', 5, true);


--
-- Name: projects_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.projects_id_seq', 1, true);


--
-- Name: skills_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.skills_id_seq', 15, true);


--
-- Name: website_visits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.website_visits_id_seq', 8, true);


--
-- Name: about_me about_me_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.about_me
    ADD CONSTRAINT about_me_pkey PRIMARY KEY (id);


--
-- Name: admin_auth admin_auth_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_auth
    ADD CONSTRAINT admin_auth_pkey PRIMARY KEY (id);


--
-- Name: admin_log admin_log_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT admin_log_pkey PRIMARY KEY (id);


--
-- Name: admin_menu_label admin_menu_label_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_label
    ADD CONSTRAINT admin_menu_label_pkey PRIMARY KEY (id);


--
-- Name: admin_menu_tab_action admin_menu_tab_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_tab_action
    ADD CONSTRAINT admin_menu_tab_action_pkey PRIMARY KEY (id);


--
-- Name: admin_menu_tab admin_menu_tab_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_tab
    ADD CONSTRAINT admin_menu_tab_pkey PRIMARY KEY (id);


--
-- Name: admin_permission_action admin_permission_action_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_permission_action
    ADD CONSTRAINT admin_permission_action_pkey PRIMARY KEY (id);


--
-- Name: admin_permissions admin_permissions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_pkey PRIMARY KEY (id);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: contact_me contact_me_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.contact_me
    ADD CONSTRAINT contact_me_pkey PRIMARY KEY (id);


--
-- Name: education education_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_pkey PRIMARY KEY (id);


--
-- Name: experiences experiences_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.experiences
    ADD CONSTRAINT experiences_pkey PRIMARY KEY (id);


--
-- Name: home_banners home_banners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.home_banners
    ADD CONSTRAINT home_banners_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: site_settings site_settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.site_settings
    ADD CONSTRAINT site_settings_pkey PRIMARY KEY (id);


--
-- Name: skills skills_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.skills
    ADD CONSTRAINT skills_pkey PRIMARY KEY (id);


--
-- Name: website_visits website_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.website_visits
    ADD CONSTRAINT website_visits_pkey PRIMARY KEY (id);


--
-- Name: website_visits website_visits_visit_date_uidx; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.website_visits
    ADD CONSTRAINT website_visits_visit_date_uidx UNIQUE (visit_date);


--
-- Name: admin_auth_admin_id_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_auth_admin_id_active_uidx ON public.admin_auth USING btree (admin_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_log_action_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_log_action_idx ON public.admin_log USING btree (action) WHERE (deleted_at IS NULL);


--
-- Name: admin_log_admin_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_log_admin_id_idx ON public.admin_log USING btree (admin_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_log_created_at_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_log_created_at_idx ON public.admin_log USING btree (created_at DESC) WHERE (deleted_at IS NULL);


--
-- Name: admin_log_entity_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_log_entity_idx ON public.admin_log USING btree (entity_type, entity_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_label_code_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_menu_label_code_active_uidx ON public.admin_menu_label USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_tab_action_action_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_menu_tab_action_action_id_idx ON public.admin_menu_tab_action USING btree (permission_action_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_tab_action_pair_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_menu_tab_action_pair_active_uidx ON public.admin_menu_tab_action USING btree (menu_tab_id, permission_action_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_tab_action_tab_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_menu_tab_action_tab_id_idx ON public.admin_menu_tab_action USING btree (menu_tab_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_tab_code_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_menu_tab_code_active_uidx ON public.admin_menu_tab USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: admin_menu_tab_label_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_menu_tab_label_id_idx ON public.admin_menu_tab USING btree (menu_label_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_permission_action_code_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_permission_action_code_active_uidx ON public.admin_permission_action USING btree (code) WHERE (deleted_at IS NULL);


--
-- Name: admin_permissions_admin_action_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admin_permissions_admin_action_active_uidx ON public.admin_permissions USING btree (admin_id, menu_tab_action_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_permissions_admin_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_permissions_admin_id_idx ON public.admin_permissions USING btree (admin_id) WHERE (deleted_at IS NULL);


--
-- Name: admin_permissions_menu_tab_action_id_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX admin_permissions_menu_tab_action_id_idx ON public.admin_permissions USING btree (menu_tab_action_id) WHERE (deleted_at IS NULL);


--
-- Name: admins_email_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX admins_email_active_uidx ON public.admins USING btree (email) WHERE (deleted_at IS NULL);


--
-- Name: education_display_order_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX education_display_order_active_idx ON public.education USING btree (display_order, id) WHERE (deleted_at IS NULL);


--
-- Name: education_is_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX education_is_active_idx ON public.education USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- Name: experiences_display_order_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX experiences_display_order_active_idx ON public.experiences USING btree (display_order, id) WHERE (deleted_at IS NULL);


--
-- Name: experiences_is_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX experiences_is_active_idx ON public.experiences USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- Name: home_banners_display_order_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX home_banners_display_order_active_idx ON public.home_banners USING btree (display_order, id) WHERE (deleted_at IS NULL);


--
-- Name: home_banners_is_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX home_banners_is_active_idx ON public.home_banners USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- Name: projects_display_order_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_display_order_active_idx ON public.projects USING btree (display_order, id) WHERE (deleted_at IS NULL);


--
-- Name: projects_is_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX projects_is_active_idx ON public.projects USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- Name: skills_display_order_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX skills_display_order_active_idx ON public.skills USING btree (display_order, id) WHERE (deleted_at IS NULL);


--
-- Name: skills_is_active_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX skills_is_active_idx ON public.skills USING btree (is_active) WHERE (deleted_at IS NULL);


--
-- Name: skills_name_active_uidx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX skills_name_active_uidx ON public.skills USING btree (name) WHERE (deleted_at IS NULL);


--
-- Name: website_visits_visit_date_idx; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX website_visits_visit_date_idx ON public.website_visits USING btree (visit_date DESC);


--
-- Name: about_me about_me_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER about_me_set_updated_at BEFORE UPDATE ON public.about_me FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_auth admin_auth_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_auth_set_updated_at BEFORE UPDATE ON public.admin_auth FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_log admin_log_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_log_set_updated_at BEFORE UPDATE ON public.admin_log FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_menu_label admin_menu_label_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_menu_label_set_updated_at BEFORE UPDATE ON public.admin_menu_label FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_menu_tab_action admin_menu_tab_action_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_menu_tab_action_set_updated_at BEFORE UPDATE ON public.admin_menu_tab_action FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_menu_tab admin_menu_tab_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_menu_tab_set_updated_at BEFORE UPDATE ON public.admin_menu_tab FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_permission_action admin_permission_action_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_permission_action_set_updated_at BEFORE UPDATE ON public.admin_permission_action FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_permissions admin_permissions_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admin_permissions_set_updated_at BEFORE UPDATE ON public.admin_permissions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admins admins_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER admins_set_updated_at BEFORE UPDATE ON public.admins FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: contact_me contact_me_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER contact_me_set_updated_at BEFORE UPDATE ON public.contact_me FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: education education_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER education_set_updated_at BEFORE UPDATE ON public.education FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: experiences experiences_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER experiences_set_updated_at BEFORE UPDATE ON public.experiences FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: home_banners home_banners_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER home_banners_set_updated_at BEFORE UPDATE ON public.home_banners FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: projects projects_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER projects_set_updated_at BEFORE UPDATE ON public.projects FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: site_settings site_settings_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER site_settings_set_updated_at BEFORE UPDATE ON public.site_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: skills skills_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER skills_set_updated_at BEFORE UPDATE ON public.skills FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: website_visits website_visits_set_updated_at; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER website_visits_set_updated_at BEFORE UPDATE ON public.website_visits FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


--
-- Name: admin_auth admin_auth_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_auth
    ADD CONSTRAINT admin_auth_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: admin_log admin_log_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_log
    ADD CONSTRAINT admin_log_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: admin_menu_tab_action admin_menu_tab_action_menu_tab_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_tab_action
    ADD CONSTRAINT admin_menu_tab_action_menu_tab_id_fkey FOREIGN KEY (menu_tab_id) REFERENCES public.admin_menu_tab(id);


--
-- Name: admin_menu_tab_action admin_menu_tab_action_permission_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_tab_action
    ADD CONSTRAINT admin_menu_tab_action_permission_action_id_fkey FOREIGN KEY (permission_action_id) REFERENCES public.admin_permission_action(id);


--
-- Name: admin_menu_tab admin_menu_tab_menu_label_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_menu_tab
    ADD CONSTRAINT admin_menu_tab_menu_label_id_fkey FOREIGN KEY (menu_label_id) REFERENCES public.admin_menu_label(id);


--
-- Name: admin_permissions admin_permissions_admin_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_admin_id_fkey FOREIGN KEY (admin_id) REFERENCES public.admins(id);


--
-- Name: admin_permissions admin_permissions_menu_tab_action_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admin_permissions
    ADD CONSTRAINT admin_permissions_menu_tab_action_id_fkey FOREIGN KEY (menu_tab_action_id) REFERENCES public.admin_menu_tab_action(id);


--
-- PostgreSQL database dump complete
--

\unrestrict uy5XvxApyWcG7docc1hhuts4JUxC3YggFyZkhe5aFYaBmsFdEC9ox4CKyRVkHTU

