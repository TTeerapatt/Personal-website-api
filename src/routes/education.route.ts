import { Router } from "express";
import {
  createEducationController,
  getEducationByIdController,
  getEducationListController,
  hardDeleteEducationController,
  reorderEducationController,
  setEducationActiveController,
  softDeleteEducationController,
  updateEducationController,
} from "../controllers/education.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const educationRouter = Router();

educationRouter.get(
  "/",
  authMiddleware,
  requirePermission("education", "view"),
  getEducationListController
);
educationRouter.get(
  "/:id",
  authMiddleware,
  requirePermission("education", "view"),
  getEducationByIdController
);
educationRouter.post(
  "/",
  authMiddleware,
  requirePermission("education", "add"),
  createEducationController
);
educationRouter.put(
  "/reorder",
  authMiddleware,
  requirePermission("education", "edit"),
  reorderEducationController
);
educationRouter.put(
  "/:id",
  authMiddleware,
  requirePermission("education", "edit"),
  updateEducationController
);
educationRouter.patch(
  "/:id/is-active",
  authMiddleware,
  requirePermission("education", "edit"),
  setEducationActiveController
);
educationRouter.delete(
  "/:id/hard",
  authMiddleware,
  requirePermission("education", "delete"),
  hardDeleteEducationController
);
educationRouter.delete(
  "/:id",
  authMiddleware,
  requirePermission("education", "delete"),
  softDeleteEducationController
);

export default educationRouter;
