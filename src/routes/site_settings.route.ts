import { Router } from "express";
import {
  getSiteSettingsController,
  updateSiteSettingsController,
} from "../controllers/site_settings.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const siteSettingsRouter = Router();

siteSettingsRouter.get(
  "/",
  authMiddleware,
  requirePermission("site-settings", "view"),
  getSiteSettingsController
);
siteSettingsRouter.put(
  "/",
  authMiddleware,
  requirePermission("site-settings", "edit"),
  updateSiteSettingsController
);

export default siteSettingsRouter;
