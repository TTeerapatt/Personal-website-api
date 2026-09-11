import { Router } from "express";
import {
  createProjectController,
  getProjectByIdController,
  getProjectsController,
  hardDeleteProjectController,
  reorderProjectsController,
  setProjectActiveController,
  softDeleteProjectController,
  updateProjectController,
} from "../controllers/projects.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const projectsRouter = Router();

projectsRouter.get(
  "/",
  authMiddleware,
  requirePermission("projects", "view"),
  getProjectsController
);
projectsRouter.get(
  "/:id",
  authMiddleware,
  requirePermission("projects", "view"),
  getProjectByIdController
);
projectsRouter.post(
  "/",
  authMiddleware,
  requirePermission("projects", "add"),
  createProjectController
);
projectsRouter.put(
  "/reorder",
  authMiddleware,
  requirePermission("projects", "edit"),
  reorderProjectsController
);
projectsRouter.put(
  "/:id",
  authMiddleware,
  requirePermission("projects", "edit"),
  updateProjectController
);
projectsRouter.patch(
  "/:id/is-active",
  authMiddleware,
  requirePermission("projects", "edit"),
  setProjectActiveController
);
projectsRouter.delete(
  "/:id/hard",
  authMiddleware,
  requirePermission("projects", "delete"),
  hardDeleteProjectController
);
projectsRouter.delete(
  "/:id",
  authMiddleware,
  requirePermission("projects", "delete"),
  softDeleteProjectController
);

export default projectsRouter;
