import type { Request, Response, NextFunction } from "express";
import {
  ExperienceError,
  createExperience,
  getExperienceById,
  getExperiences,
  hardDeleteExperience,
  parseExperienceListFilter,
  setExperienceActive,
  softDeleteExperience,
  updateExperience,
} from "../services/experiences.service";
import { toPositiveInt } from "../utils/parse";

function parseIdParam(value: string): number | null {
  return toPositiveInt(value);
}

function handleExperienceError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof ExperienceError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getExperiencesController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseExperienceListFilter(req.query);
    const data = await getExperiences(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}

export async function getExperienceByIdController(
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

    const data = await getExperienceById(id);
    if (!data) {
      res.status(404).json({ success: false, message: "Experience not found" });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function createExperienceController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await createExperience({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(201).json({ success: true, data });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}

export async function updateExperienceController(
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

    const data = await updateExperience(id, {
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}

export async function setExperienceActiveController(
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

    const data = await setExperienceActive(
      id,
      req.body?.is_active,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}

export async function softDeleteExperienceController(
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

    const data = await softDeleteExperience(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Experience soft deleted",
      data,
    });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}

export async function hardDeleteExperienceController(
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

    const data = await hardDeleteExperience(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Experience hard deleted",
      data,
    });
  } catch (error) {
    handleExperienceError(error, res, next);
  }
}
