import { Router } from "express";
import { getPublicSiteSettingsController } from "../controllers/site_settings.controller";
import { getPublicAboutMeController } from "../controllers/about_me.controller";

const publicRouter = Router();

publicRouter.get("/site-settings", getPublicSiteSettingsController);
publicRouter.get("/about-me", getPublicAboutMeController);

export default publicRouter;
