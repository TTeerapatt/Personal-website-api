import { Router } from "express";
import {
  createSkillController,
  getSkillByIdController,
  getSkillsController,
  hardDeleteSkillController,
  setSkillActiveController,
  softDeleteSkillController,
  updateSkillController,
} from "../controllers/skills.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const skillsRouter = Router();

skillsRouter.get(
  "/",
  authMiddleware,
  requirePermission("skills", "view"),
  getSkillsController
);
skillsRouter.get(
  "/:id",
  authMiddleware,
  requirePermission("skills", "view"),
  getSkillByIdController
);
skillsRouter.post(
  "/",
  authMiddleware,
  requirePermission("skills", "add"),
  createSkillController
);
skillsRouter.put(
  "/:id",
  authMiddleware,
  requirePermission("skills", "edit"),
  updateSkillController
);
skillsRouter.patch(
  "/:id/is-active",
  authMiddleware,
  requirePermission("skills", "edit"),
  setSkillActiveController
);
skillsRouter.delete(
  "/:id/hard",
  authMiddleware,
  requirePermission("skills", "delete"),
  hardDeleteSkillController
);
skillsRouter.delete(
  "/:id",
  authMiddleware,
  requirePermission("skills", "delete"),
  softDeleteSkillController
);

export default skillsRouter;
