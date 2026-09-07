import { Router } from "express";
import {
  createExperienceController,
  getExperienceByIdController,
  getExperiencesController,
  hardDeleteExperienceController,
  setExperienceActiveController,
  softDeleteExperienceController,
  updateExperienceController,
} from "../controllers/experiences.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const experiencesRouter = Router();

experiencesRouter.get(
  "/",
  authMiddleware,
  requirePermission("experiences", "view"),
  getExperiencesController
);
experiencesRouter.get(
  "/:id",
  authMiddleware,
  requirePermission("experiences", "view"),
  getExperienceByIdController
);
experiencesRouter.post(
  "/",
  authMiddleware,
  requirePermission("experiences", "add"),
  createExperienceController
);
experiencesRouter.put(
  "/:id",
  authMiddleware,
  requirePermission("experiences", "edit"),
  updateExperienceController
);
experiencesRouter.patch(
  "/:id/is-active",
  authMiddleware,
  requirePermission("experiences", "edit"),
  setExperienceActiveController
);
experiencesRouter.delete(
  "/:id/hard",
  authMiddleware,
  requirePermission("experiences", "delete"),
  hardDeleteExperienceController
);
experiencesRouter.delete(
  "/:id",
  authMiddleware,
  requirePermission("experiences", "delete"),
  softDeleteExperienceController
);

export default experiencesRouter;
