import { Router } from "express";
import {
  getAboutMeController,
  updateAboutMeController,
} from "../controllers/about_me.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const aboutMeRouter = Router();

aboutMeRouter.get(
  "/",
  authMiddleware,
  requirePermission("about-me", "view"),
  getAboutMeController
);
aboutMeRouter.put(
  "/",
  authMiddleware,
  requirePermission("about-me", "edit"),
  updateAboutMeController
);

export default aboutMeRouter;
