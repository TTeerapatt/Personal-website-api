import type { NextFunction, Request, Response } from "express";
import {
  MAX_UPLOAD_BYTES,
  buildPublicUploadUrl,
  isMulterError,
  sanitizeFolder,
  uploadSingle,
} from "../middleware/upload.middleware";

export function uploadFileController(
  req: Request,
  res: Response,
  next: NextFunction
): void {
  uploadSingle(req, res, (error: unknown) => {
    try {
      if (error) {
        if (isMulterError(error) && error.code === "LIMIT_FILE_SIZE") {
          res.status(400).json({
            success: false,
            message: "File size must not exceed 5MB",
          });
          return;
        }

        const message =
          error instanceof Error ? error.message : "Upload failed";
        res.status(400).json({
          success: false,
          message,
        });
        return;
      }

      if (!req.file) {
        res.status(400).json({
          success: false,
          message: "Please select a file to upload",
        });
        return;
      }

      const folder = sanitizeFolder(req.query.folder ?? req.body?.folder);
      const url = buildPublicUploadUrl(req, folder, req.file.filename);

      res.status(201).json({
        success: true,
        data: {
          url,
          path: `/upload/${folder}/${req.file.filename}`,
          filename: req.file.filename,
          original_name: req.file.originalname,
          mime_type: req.file.mimetype,
          size: req.file.size,
          max_size: MAX_UPLOAD_BYTES,
        },
      });
    } catch (err) {
      next(err);
    }
  });
}
