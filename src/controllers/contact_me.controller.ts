import type { Request, Response, NextFunction } from "express";
import {
  ContactMeError,
  getContactMe,
  getPublicContactMe,
  updateContactMe,
} from "../services/contact_me.service";

function handleContactMeError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof ContactMeError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getContactMeController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getContactMe();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleContactMeError(error, res, next);
  }
}

export async function getPublicContactMeController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getPublicContactMe();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleContactMeError(error, res, next);
  }
}

export async function updateContactMeController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await updateContactMe({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleContactMeError(error, res, next);
  }
}
