import { Router } from "express";
import {
  getContactMeController,
  updateContactMeController,
} from "../controllers/contact_me.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const contactMeRouter = Router();

contactMeRouter.get(
  "/",
  authMiddleware,
  requirePermission("contact-me", "view"),
  getContactMeController
);
contactMeRouter.put(
  "/",
  authMiddleware,
  requirePermission("contact-me", "edit"),
  updateContactMeController
);

export default contactMeRouter;
