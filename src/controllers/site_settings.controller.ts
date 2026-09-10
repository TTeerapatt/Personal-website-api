import type { Request, Response, NextFunction } from "express";
import {
  SiteSettingsError,
  getPublicSiteSettings,
  getSiteSettings,
  updateSiteSettings,
} from "../services/site_settings.service";

function handleSiteSettingsError(
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

export async function getSiteSettingsController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getSiteSettings();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSiteSettingsError(error, res, next);
  }
}

export async function getPublicSiteSettingsController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getPublicSiteSettings();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSiteSettingsError(error, res, next);
  }
}

export async function updateSiteSettingsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await updateSiteSettings({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSiteSettingsError(error, res, next);
  }
}
