import type { Request, Response, NextFunction } from "express";
import {
  ProjectError,
  createProject,
  getProjectById,
  getProjects,
  hardDeleteProject,
  parseProjectListFilter,
  setProjectActive,
  softDeleteProject,
  updateProject,
} from "../services/projects.service";
import { toPositiveInt } from "../utils/parse";

function parseIdParam(value: string): number | null {
  return toPositiveInt(value);
}

function handleProjectError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof ProjectError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function getProjectsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseProjectListFilter(req.query);
    const data = await getProjects(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}

export async function getProjectByIdController(
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

    const data = await getProjectById(id);
    if (!data) {
      res.status(404).json({ success: false, message: "Project not found" });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    next(error);
  }
}

export async function createProjectController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await createProject({
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(201).json({ success: true, data });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}

export async function updateProjectController(
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

    const data = await updateProject(id, {
      ...req.body,
      adminId: req.admin?.adminId ?? null,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}

export async function setProjectActiveController(
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

    const data = await setProjectActive(
      id,
      req.body?.is_active,
      req.admin?.adminId ?? null
    );
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}

export async function softDeleteProjectController(
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

    const data = await softDeleteProject(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Project soft deleted",
      data,
    });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}

export async function hardDeleteProjectController(
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

    const data = await hardDeleteProject(id, req.admin?.adminId ?? null);
    res.status(200).json({
      success: true,
      message: "Project hard deleted",
      data,
    });
  } catch (error) {
    handleProjectError(error, res, next);
  }
}
