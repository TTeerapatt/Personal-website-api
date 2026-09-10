import { Router } from "express";
import { getPublicSiteSettingsController } from "../controllers/site_settings.controller";

const publicRouter = Router();

publicRouter.get("/site-settings", getPublicSiteSettingsController);

export default publicRouter;
