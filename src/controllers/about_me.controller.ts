import type { Request, Response, NextFunction } from "express";
import {
  AboutMeError,
  getAboutMe,
  getPublicAboutMe,
  updateAboutMe,
} from "../services/about_me.service";

function handleAboutMeError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof AboutMeError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getAboutMeController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getAboutMe();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleAboutMeError(error, res, next);
  }
}

export async function getPublicAboutMeController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getPublicAboutMe();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleAboutMeError(error, res, next);
  }
}

export async function updateAboutMeController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await updateAboutMe({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleAboutMeError(error, res, next);
  }
}
