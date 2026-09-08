import fs from "fs";
import path from "path";
import multer from "multer";
import { v4 as uuidv4 } from "uuid";
import type { Request } from "express";

export const UPLOAD_ROOT = path.resolve(process.cwd(), "upload");
export const MAX_UPLOAD_BYTES = 5 * 1024 * 1024; // 5MB

const ALLOWED_FOLDERS = new Set([
  "home-banners",
  "skills",
  "projects",
  "experiences",
  "education",
  "misc",
]);

const IMAGE_MIME = new Set([
  "image/jpeg",
  "image/png",
  "image/webp",
  "image/gif",
]);

const VIDEO_MIME = new Set([
  "video/mp4",
  "video/webm",
  "video/quicktime",
]);

export function ensureUploadDir(folder: string): string {
  const safe = sanitizeFolder(folder);
  const dir = path.join(UPLOAD_ROOT, safe);
  fs.mkdirSync(dir, { recursive: true });
  return dir;
}

export function sanitizeFolder(folder: unknown): string {
  const raw = String(folder || "misc")
    .trim()
    .toLowerCase()
    .replace(/[^a-z0-9-_]/g, "");
  if (!raw || !ALLOWED_FOLDERS.has(raw)) {
    return "misc";
  }
  return raw;
}

function extensionFromName(originalName: string, mime: string): string {
  const fromName = path.extname(originalName || "").toLowerCase();
  if (fromName && fromName.length <= 8) {
    return fromName;
  }
  if (mime === "image/jpeg") return ".jpg";
  if (mime === "image/png") return ".png";
  if (mime === "image/webp") return ".webp";
  if (mime === "image/gif") return ".gif";
  if (mime === "video/mp4") return ".mp4";
  if (mime === "video/webm") return ".webm";
  if (mime === "video/quicktime") return ".mov";
  return "";
}

const storage = multer.diskStorage({
  destination(req, _file, cb) {
    try {
      const folder = sanitizeFolder(req.query.folder ?? req.body?.folder);
      const dir = ensureUploadDir(folder);
      cb(null, dir);
    } catch (error) {
      cb(error as Error, UPLOAD_ROOT);
    }
  },
  filename(_req, file, cb) {
    const ext = extensionFromName(file.originalname, file.mimetype);
    cb(null, `${uuidv4()}${ext}`);
  },
});

function fileFilter(
  _req: Request,
  file: Express.Multer.File,
  cb: multer.FileFilterCallback
) {
  const mime = String(file.mimetype || "").toLowerCase();
  if (IMAGE_MIME.has(mime) || VIDEO_MIME.has(mime)) {
    cb(null, true);
    return;
  }
  cb(new Error("Only image and video files are allowed"));
}

export const uploadSingle = multer({
  storage,
  limits: { fileSize: MAX_UPLOAD_BYTES },
  fileFilter,
}).single("file");

export function buildPublicUploadUrl(
  req: Request,
  folder: string,
  filename: string
): string {
  const host = req.get("host");
  const protoHeader = req.get("x-forwarded-proto");
  const protocol = protoHeader || req.protocol || "http";
  const safeFolder = sanitizeFolder(folder);
  const relative = `/upload/${safeFolder}/${filename}`;
  if (!host) return relative;
  return `${protocol}://${host}${relative}`;
}

export function isMulterError(error: unknown): error is multer.MulterError {
  return Boolean(error && typeof error === "object" && "code" in error);
}
