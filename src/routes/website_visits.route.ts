import { Router } from "express";
import {
  getWebsiteVisitByDateController,
  getWebsiteVisitSummaryController,
  getWebsiteVisitsController,
  trackWebsiteVisitController,
} from "../controllers/website_visits.controller";

const websiteVisitsRouter = Router();

// Public endpoints for the landing website (no admin JWT)

websiteVisitsRouter.post("/track", trackWebsiteVisitController);
websiteVisitsRouter.get("/summary", getWebsiteVisitSummaryController);
websiteVisitsRouter.get("/", getWebsiteVisitsController);
websiteVisitsRouter.get("/by-date/:date", getWebsiteVisitByDateController);

export default websiteVisitsRouter;
