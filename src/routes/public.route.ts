import { Router } from "express";
import { getPublicSiteSettingsController } from "../controllers/site_settings.controller";
import { getPublicAboutMeController } from "../controllers/about_me.controller";
import { getPublicContactMeController } from "../controllers/contact_me.controller";
import { getPublicWebsiteContentController } from "../controllers/public_content.controller";

const publicRouter = Router();

publicRouter.get("/content", getPublicWebsiteContentController);
publicRouter.get("/site-settings", getPublicSiteSettingsController);
publicRouter.get("/about-me", getPublicAboutMeController);
publicRouter.get("/contact-me", getPublicContactMeController);

export default publicRouter;
