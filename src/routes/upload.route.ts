import { Router } from "express";
import { uploadFileController } from "../controllers/upload.controller";
import { authMiddleware } from "../middleware/auth.middleware";

const uploadRouter = Router();

uploadRouter.post("/", authMiddleware, uploadFileController);

export default uploadRouter;
