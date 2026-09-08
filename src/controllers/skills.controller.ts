import type { Request, Response, NextFunction } from "express";
import {
  SkillError,
  createSkill,
  getSkillById,
  getSkills,
  hardDeleteSkill,
  parseSkillListFilter,
  reorderSkills,
  setSkillActive,
  softDeleteSkill,
  updateSkill,
} from "../services/skills.service";
import { toPositiveInt } from "../utils/parse";

function parseIdParam(value: string): number | null {
  return toPositiveInt(value);
}

function handleSkillError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof SkillError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getSkillsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseSkillListFilter(req.query);
    const data = await getSkills(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function getSkillByIdController(
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

    const data = await getSkillById(id);
    if (!data) {
      res.status(404).json({ success: false, message: "Skill not found" });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function createSkillController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await createSkill({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(201).json({ success: true, data });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function reorderSkillsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await reorderSkills(
      req.body?.ordered_ids,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function updateSkillController(
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

    const data = await updateSkill(id, {
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function setSkillActiveController(
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

    const data = await setSkillActive(
      id,
      req.body?.is_active,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function softDeleteSkillController(
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

    const data = await softDeleteSkill(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Skill soft deleted",
      data,
    });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}

export async function hardDeleteSkillController(
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

    const data = await hardDeleteSkill(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Skill hard deleted",
      data,
    });
  } catch (error) {
    handleSkillError(error, res, next);
  }
}
