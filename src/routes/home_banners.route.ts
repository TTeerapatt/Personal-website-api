import { Router } from "express";
import {
  createHomeBannerController,
  getHomeBannerByIdController,
  getHomeBannersController,
  hardDeleteHomeBannerController,
  setHomeBannerActiveController,
  softDeleteHomeBannerController,
  updateHomeBannerController,
} from "../controllers/home_banners.controller";
import { authMiddleware } from "../middleware/auth.middleware";
import { requirePermission } from "../middleware/permission.middleware";

const homeBannersRouter = Router();

homeBannersRouter.get(
  "/",
  authMiddleware,
  requirePermission("home-banners", "view"),
  getHomeBannersController
);
homeBannersRouter.get(
  "/:id",
  authMiddleware,
  requirePermission("home-banners", "view"),
  getHomeBannerByIdController
);
homeBannersRouter.post(
  "/",
  authMiddleware,
  requirePermission("home-banners", "add"),
  createHomeBannerController
);
homeBannersRouter.put(
  "/:id",
  authMiddleware,
  requirePermission("home-banners", "edit"),
  updateHomeBannerController
);
homeBannersRouter.patch(
  "/:id/is-active",
  authMiddleware,
  requirePermission("home-banners", "edit"),
  setHomeBannerActiveController
);
homeBannersRouter.delete(
  "/:id/hard",
  authMiddleware,
  requirePermission("home-banners", "delete"),
  hardDeleteHomeBannerController
);
homeBannersRouter.delete(
  "/:id",
  authMiddleware,
  requirePermission("home-banners", "delete"),
  softDeleteHomeBannerController
);

export default homeBannersRouter;
