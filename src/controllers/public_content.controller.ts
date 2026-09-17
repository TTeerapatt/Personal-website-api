import type { Request, Response, NextFunction } from "express";
import { getPublicWebsiteContent } from "../services/public_content.service";
import { SiteSettingsError } from "../services/site_settings.service";

function handlePublicContentError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof SiteSettingsError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getPublicWebsiteContentController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getPublicWebsiteContent();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handlePublicContentError(error, res, next);
  }
}
