import type { Request, Response, NextFunction } from "express";
import {
  HomeBannerError,
  createHomeBanner,
  getActiveHomeBannerById,
  getActiveHomeBanners,
  hardDeleteHomeBanner,
  parseHomeBannerListFilter,
  reorderHomeBanners,
  setHomeBannerActive,
  softDeleteHomeBanner,
  updateHomeBanner,
} from "../services/home_banners.service";
import { toPositiveInt } from "../utils/parse";

function parseIdParam(value: string): number | null {
  return toPositiveInt(value);
}

function handleHomeBannerError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof HomeBannerError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getHomeBannersController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseHomeBannerListFilter(req.query);
    const data = await getActiveHomeBanners(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function getHomeBannerByIdController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseIdParam(req.params.id);
    if (id === null) {
      res.status(400).json({ success: false, message: "Invalid id" });
      return;
    }

    const data = await getActiveHomeBannerById(id);
    if (!data) {
      res.status(404).json({ success: false, message: "Home banner not found" });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function createHomeBannerController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await createHomeBanner({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(201).json({ success: true, data });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function reorderHomeBannersController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await reorderHomeBanners(
      req.body?.ordered_ids,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function updateHomeBannerController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseIdParam(req.params.id);
    if (id === null) {
      res.status(400).json({ success: false, message: "Invalid id" });
      return;
    }

    const data = await updateHomeBanner(id, {
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function setHomeBannerActiveController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseIdParam(req.params.id);
    if (id === null) {
      res.status(400).json({ success: false, message: "Invalid id" });
      return;
    }

    const data = await setHomeBannerActive(
      id,
      req.body?.is_active,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function softDeleteHomeBannerController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseIdParam(req.params.id);
    if (id === null) {
      res.status(400).json({ success: false, message: "Invalid id" });
      return;
    }

    const data = await softDeleteHomeBanner(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Home banner soft deleted",
      data,
    });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}

export async function hardDeleteHomeBannerController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const id = parseIdParam(req.params.id);
    if (id === null) {
      res.status(400).json({ success: false, message: "Invalid id" });
      return;
    }

    const data = await hardDeleteHomeBanner(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Home banner hard deleted",
      data,
    });
  } catch (error) {
    handleHomeBannerError(error, res, next);
  }
}
