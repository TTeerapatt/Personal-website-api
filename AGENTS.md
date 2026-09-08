# AGENTS.md — Personal Website API

แนวทางสำหรับ AI agent / คนที่มาแก้โค้ดหรือ prompt ต่อในโปรเจกต์นี้  
อ่านไฟล์นี้ก่อนเปลี่ยน architecture, schema, หรือ flow สำคัญ

---

## 0) ภาพรวมระบบทั้งชุด (สำคัญมาก)

โปรเจกต์นี้เป็น **Personal Website** 

| โฟลเดอร์ | บทบาท |
|----------|--------|
| `Personal-website-web` | Landing page สาธารณะ — แสดงข้อมูลส่วนตัว / โปรเจกต์ / skill / ประสบการณ์ / การศึกษา |
| `Personal-website-admin` | Web admin (CMS) — เขียน แก้ไข ควบคุมคอนเทนต์ที่จะไปโชว์บนเว็บ |
| `Personal-website-api` | Backend API + PostgreSQL — แหล่งข้อมูลเดียวของทั้ง web และ admin |

### หลักการผลิตภัณฑ์

1. **Landing page นำเสนอตัวตน** — hero/banner, skills, projects, experiences, education
2. **Admin ควบคุมคอนเทนต์** — CRUD + เปิด/ปิดแสดง (`is_active`) + soft/hard delete + เรียงลำดับ
3. **รองรับ 2 ภาษา: ไทย + อังกฤษ** — ฟิลด์ข้อความคู่ `*_th` / `*_en` (และ rich text เป็น string/HTML ใน `TEXT`)
4. **Responsive** — web/admin ต้องใช้ได้หลายขนาดหน้าจอ (รายละเอียด UX อยู่ใน AGENTS ของแต่ละฝั่ง)
5. **ข้อมูลที่โชว์บนเว็บสาธารณะ** มาจากแถวที่ `deleted_at IS NULL` และโดยปกติ `is_active = TRUE`

เมื่อ prompt งานใดๆ ให้ยึดบริบทนี้ — อย่าเอา pattern ร้านซักผ้า / ออเดอร์ / ลูกค้า กลับมา

---

## 1) ภาพรวมโปรเจกต์ API

- **ชื่อ:** `personal-website-api` (โฟลเดอร์ `Personal-website-api`)
- **Stack:** Express 5 + TypeScript + PostgreSQL (`pg`)
- **Entry:** `src/app.ts` (listen ที่นี่ ไม่แยก `server.ts`)
- **API prefix:** `/personal-website/api`
- **พอร์ตเริ่มต้น:** `3001` (`PORT` จาก `.env`)
- **Auth:** JWT Bearer ของ admin (`Authorization: Bearer <token>`)
- **Static upload:** `/upload` → โฟลเดอร์ `upload/`
- **Postman:** `postman_collection.json` ที่ root — แก้ endpoint แล้วควรอัปเดตไฟล์นี้ด้วย

### คำสั่งที่ใช้บ่อย

```bash
npm run dev      # nodemon + ts-node src/app.ts
npm run build    # tsc → dist/
npm start        # node dist/app.js
```

### Env ที่สำคัญ

```
PORT=
NODE_ENV=
DATABASE_URL=          # ใช้ก่อน DB_HOST/DB_USER/... ถ้ามี
DB_HOST=
DB_PORT=
DB_USER=
DB_PASS=
DB_NAME=
JWT_SECRET=
CORS_ORIGIN=           # origin ของ web/admin คั่นด้วย comma หรือ *
```

---

## 2) โครงสร้างโฟลเดอร์ (ต้องทำตามนี้)

```
Personal-website-api/
├── postman_collection.json
├── package.json
├── tsconfig.json
├── AGENTS.md
├── .env.example
└── src/
    ├── app.ts
    ├── config/
    │   └── database.config.ts
    ├── middleware/
    │   ├── auth.middleware.ts
    │   └── permission.middleware.ts
    ├── utils/
    │   └── parse.ts                 # helpers ตรวจชนิดค่า input ร่วม
    ├── routes/
    ├── controllers/
    ├── services/
    └── db/
        ├── personal_website_table.sql   # schema รวม (source of truth)
        └── migrations/                  # SQL ทีละขั้น รันตามลำดับ
```

### หน้าที่แต่ละชั้น (อย่าข้ามชั้น)

| ชั้น | เก็บอะไร | ห้ามทำ |
|------|----------|--------|
| `routes/*.route.ts` | path, method, `authMiddleware`, `requirePermission` | ห้าม SQL / business logic |
| `controllers/*.controller.ts` | parse param/body/query, เรียก service, จัด response | ห้าม SQL ตรงๆ |
| `services/*.service.ts` | validation, query, transaction, `insertAdminLog` | ห้ามผูก Express `req`/`res` |
| `middleware/` | auth / permission | — |
| `utils/` | parse/validate ร่วม | ห้ามเรียก DB |
| `db/` | schema + migrations | ห้ามใส่ logic แอป |

### กฎตั้งชื่อไฟล์

- หนึ่ง domain ต่อชุด: `projects.route.ts` / `projects.controller.ts` / `projects.service.ts`
- ใช้ `snake_case` ตามชื่อตารางเมื่อหลายคำ: `home_banners`, `admin_log`
- URL ใช้ kebab-case: `/home-banners`, `/admin-log`, `/admin-menu`

### ตอนเพิ่ม module ใหม่ ทำตามลำดับนี้

1. ออกแบบตาราง → ใส่ใน `personal_website_table.sql` + สร้าง `migrations/00X_....sql`
2. เขียน `services/<name>.service.ts`
3. เขียน `controllers/<name>.controller.ts`
4. เขียน `routes/<name>.route.ts` (+ permission tab ถ้าจำเป็น)
5. mount ใน `src/app.ts` ภายใต้ `/personal-website/api/...`
6. seed เมนู/สิทธิ์ถ้ามี tab ใหม่
7. อัปเดต `postman_collection.json`
8. `npm run build` ให้ผ่าน

---

## 3) Database

### หลักการทั่วไป

- DB: **PostgreSQL**
- Soft delete: ตารางหลักมี `deleted_at` — query ปกติ `WHERE deleted_at IS NULL`
- Unique สำคัญใช้ **partial unique index** เฉพาะแถวที่ยังไม่ลบ
- มี `created_at`, `updated_at` + trigger `set_updated_at()`
- สถานะแสดงผลใช้ `is_active` (ไม่ใช้ชื่อคอลัมน์ `active`)
- Schema รวม: `src/db/personal_website_table.sql`
- เปลี่ยน schema บน DB ที่รันแล้ว: เพิ่ม migration ใหม่ **ห้ามแก้ migration ที่รันไปแล้ว**

### ลำดับ bootstrap DB ใหม่

1. รัน `src/db/personal_website_table.sql`
2. รัน `src/db/migrations/001_seed_content_menu.sql` (owner + เมนู Content + สิทธิ์)

### ตารางระบบ (admin)

| ตาราง | ความหมาย |
|--------|----------|
| `admins` | โปรไฟล์แอดมิน + role (`owner` / `admin` / `staff`) |
| `admin_auth` | password hash แยกจากโปรไฟล์ |
| `admin_log` | audit ว่า admin ใครทำอะไร — API อ่านอย่างเดียว |
| `admin_menu_label` / `admin_menu_tab` / `admin_permission_action` / `admin_menu_tab_action` / `admin_permissions` | เมนู + RBAC |

### ตารางคอนเทนต์ (โชว์บน landing)

| ตาราง | ความหมาย | ภาษา |
|--------|----------|------|
| `home_banners` | แบนเนอร์/สื่อหน้าแรก | ชื่ออ้างอิง + media |
| `skills` | ทักษะ/เทคโนโลยี (+ `category`) | ชื่อส่วนใหญ่เป็นกลาง |
| `projects` | ผลงาน/โปรเจกต์ | `name_th/en`, `description_th/en` (Rich Text → `TEXT`) |
| `experiences` | ประวัติงาน | `name_th/en`, `description_th/en`, `position`, ช่วงวันที่ |
| `education` | ประวัติการศึกษา | `name_th/en`, `description_th/en`, ช่วงวันที่ |

`description_*` เก็บเป็น **string/HTML ใน `TEXT`** เพื่อรองรับ Rich Text Editor ฝั่ง admin  
`media_type` ที่บังคับ/อนุญาต: `image` | `video` | `icon`  
`end_date` เป็น `NULL` ได้ = ปัจจุบัน / กำลังศึกษา

### i18n ในฐานข้อมูล

- ฟิลด์ที่ต้องแปล: คู่ `*_th` และ `*_en`
- อย่าทำตารางแปลแยกถ้ายังไม่จำเป็น — ใช้คอลัมน์คู่ตาม schema ปัจจุบัน
- API ส่งทั้งสองภาษาใน response; การเลือกภาษาเป็นหน้าที่ของ **web/admin**

---

## 4) API / Auth conventions

### Prefix และ response

- Base: `http://localhost:3001/personal-website/api`
- สำเร็จ: `{ "success": true, "data": ... }`
- ผิดพลาด domain: `{ "success": false, "message": "..." }` + status ที่เหมาะสม
- Error class ใน service เช่น `ProjectError`, `AuthError` มี `statusCode`

### Modules ที่ mount อยู่

| Mount | หน้าที่ |
|-------|---------|
| `/auth` | login / register / me |
| `/admins` | จัดการแอดมิน + สิทธิ์ |
| `/admin-log` | อ่าน audit log |
| `/admin-menu` | อ่านโครงสร้างเมนู |
| `/home-banners` | CRUD แบนเนอร์ |
| `/skills` | CRUD ทักษะ |
| `/projects` | CRUD โปรเจกต์ |
| `/experiences` | CRUD ประสบการณ์ |
| `/education` | CRUD การศึกษา |
| `/health` | health check (ไม่ต้อง auth) |

### CRUD มาตรฐานของคอนเทนต์

ทุก content module ควรมีครบ:

| Method | Path | ความหมาย |
|--------|------|----------|
| `GET` | `/` | list (filter เช่น `is_active`, skills มี `category`) |
| `GET` | `/:id` | รายการเดียว |
| `POST` | `/` | สร้าง |
| `PUT` | `/:id` | แก้ไข |
| `PATCH` | `/:id/is-active` | เปิด/ปิดแสดง body `{ "is_active": true\|false }` |
| `DELETE` | `/:id` | soft delete (`deleted_at`, มักตั้ง `is_active=false`) |
| `DELETE` | `/:id/hard` | hard delete |

Permission tab codes: `home-banners`, `skills`, `projects`, `experiences`, `education`, `admins`, `logs`  
`role === "owner"` bypass permission check

### Auth

- Login: `POST /auth/login` `{ email, password }` → `{ token, admin }`
- Register: `POST /auth/register` (พิจารณาจำกัดใน production)
- `GET /auth/me` ต้องมี token
- Middleware ใส่ `req.admin = { adminId, email, role }`

### ส่ง `adminId` ตอน mutate

Controller ส่ง `adminId: req.admin?.adminId ?? null` เข้า service เสมอเมื่อสร้าง/แก้/ลบ/set active  
เพื่อให้ `insertAdminLog` บันทึกได้

### `insertAdminLog`

- อยู่ที่ `services/admin_log.service.ts`
- เรียกหลังงานหลักสำเร็จ; ถ้าอยู่ใน transaction ส่ง `PoolClient` เป็น arg ที่ 2
- ถ้าไม่มี `adminId` ที่ถูกต้อง → ข้าม ไม่ throw
- ตัวอย่าง action: `login`, `create`, `update`, `set_active`, `soft_delete`, `hard_delete`
- ตัวอย่าง entityType: `admin`, `home_banner`, `skill`, `project`, `experience`, `education`

### Soft vs Hard delete

- `DELETE /:id` → soft
- `DELETE /:id/hard` → hard (ระวังข้อมูลอ้างอิง)
- production ใช้ soft เป็นหลัก

### Public read สำหรับ landing (แนวทาง)

ตอนนี้ content routes ส่วนใหญ่ล็อกด้วย admin auth  
ถ้าทำเว็บสาธารณะ ให้แยกแนวทางชัด:

- **Admin API** (มีอยู่): auth + permission — จัดการทุกสถานะ
- **Public API** (เพิ่มเมื่อจำเป็น): อ่านอย่างเดียวเฉพาะ `deleted_at IS NULL AND is_active = TRUE` ไม่ต้อง JWT  
  เช่น `GET /public/projects` — อย่าเปิด mutate สาธารณะ

อย่าให้ landing ใช้ token ของ admin

---

## 5) แนวทางตอนเขียน / แก้โค้ด

### ทำ

- รักษา route → controller → service
- Soft delete + `deleted_at IS NULL` ใน query ปกติ
- Transaction เมื่อ mutate ที่ควร atomic + `insertAdminLog`
- คู่ภาษา `*_th` / `*_en` ให้ครบตาม schema
- อัปเดต Postman เมื่อเพิ่ม/เปลี่ยน endpoint
- `npm run build` หลังแก้ TypeScript
- เปลี่ยน schema → migration ใหม่ + อัปเดต `personal_website_table.sql`

### ห้าม

- อย่าใส่ SQL ใน controller/route
- อย่าแก้ migration ที่รันไปแล้ว — สร้างไฟล์ใหม่
- อย่าเปิด mutate ข้อมูลโดยไม่มี auth
- อย่านำ domain laundry/order/user ลูกค้ากลับมา
- อย่ารีแฟกเตอร์กว้างเกินงานที่ถูกขอ
- อย่า commit / push นอกจากผู้ใช้ขอ

---

## 6) แนวทาง prompt ในอนาคต

ระบุให้ชัด:

1. **ขอบเขต:** module ไหน (เช่น projects เท่านั้น)
2. **ผลลัพธ์:** endpoint / schema / behavior
3. **อย่าทำอะไร:** เช่น ห้ามแก้ admin UI, ห้าม hard delete
4. **ของที่อัปเดตคู่กัน:** migration + schema รวม + Postman + build

ตัวอย่างที่ดี:

> เพิ่ม `GET /public/projects` อ่านเฉพาะ `is_active=true` ไม่ต้อง auth  
> อย่าแก้ CRUD ฝั่ง admin  
> อัปเดต Postman และรัน build

---

## 7) Backlog แนะนำ (อย่าทำเองถ้ายังไม่ขอ)

1. Public read endpoints สำหรับ landing
2. จำกัด `POST /auth/register` ใน production
3. Upload API (ตอนนี้มีแค่ static `/upload` + เก็บ URL ใน DB)
4. Pagination มาตรฐานสำหรับ list ใหญ่
5. เก็บ diff ใน `admin_log.meta` ตอน update สำคัญ

---

## 8) เช็กลิสต์สั้นก่อนจบงาน

- [ ] โครงสร้างยังเป็น route / controller / service
- [ ] Query กรอง `deleted_at IS NULL`
- [ ] Mutate ส่ง `adminId` + มี `insertAdminLog` ถ้าเหมาะสม
- [ ] ฟิลด์ภาษา `*_th` / `*_en` ครบตามที่ออกแบบ
- [ ] Schema เปลี่ยนแล้วมี migration ใหม่ + อัปเดต schema รวม
- [ ] อัปเดต Postman
- [ ] `npm run build` ผ่าน

---

อัปเดตไฟล์นี้เมื่อเปลี่ยน architecture, schema สำคัญ, หรือ convention ใหม่
