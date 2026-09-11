import type { Request, Response, NextFunction } from "express";
import {
  EducationError,
  createEducation,
  getEducationById,
  getEducationList,
  hardDeleteEducation,
  parseEducationListFilter,
  reorderEducation,
  setEducationActive,
  softDeleteEducation,
  updateEducation,
} from "../services/education.service";
import { toPositiveInt } from "../utils/parse";

function parseIdParam(value: string): number | null {
  return toPositiveInt(value);
}

function handleEducationError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof EducationError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getEducationListController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseEducationListFilter(req.query);
    const data = await getEducationList(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function getEducationByIdController(
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

    const data = await getEducationById(id);
    if (!data) {
      res.status(404).json({ success: false, message: "Education not found" });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function createEducationController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await createEducation({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(201).json({ success: true, data });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function reorderEducationController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await reorderEducation(
      req.body?.ordered_ids,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function updateEducationController(
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

    const data = await updateEducation(id, {
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function setEducationActiveController(
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

    const data = await setEducationActive(
      id,
      req.body?.is_active,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function softDeleteEducationController(
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

    const data = await softDeleteEducation(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Education soft deleted",
      data,
    });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}

export async function hardDeleteEducationController(
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

    const data = await hardDeleteEducation(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Education hard deleted",
      data,
    });
  } catch (error) {
    handleEducationError(error, res, next);
  }
}
