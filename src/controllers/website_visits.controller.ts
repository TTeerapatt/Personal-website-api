import type { Request, Response, NextFunction } from "express";
import {
  WebsiteVisitError,
  getWebsiteVisitByDate,
  getWebsiteVisitSummary,
  getWebsiteVisits,
  parseWebsiteVisitListFilter,
  trackWebsiteVisit,
} from "../services/website_visits.service";
import { parseDateOnly } from "../utils/parse";

function handleWebsiteVisitError(
  error: unknown,
  res: Response,
  next: NextFunction
): void {
  if (error instanceof WebsiteVisitError) {
    res.status(error.statusCode).json({
      success: false,
      message: error.message,
    });
    return;
  }
  next(error);
}

export async function trackWebsiteVisitController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await trackWebsiteVisit({
      amount: req.body?.amount,
    });
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleWebsiteVisitError(error, res, next);
  }
}

export async function getWebsiteVisitSummaryController(
  _req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const data = await getWebsiteVisitSummary();
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleWebsiteVisitError(error, res, next);
  }
}

export async function getWebsiteVisitsController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const filter = parseWebsiteVisitListFilter(
      req.query as Record<string, unknown>
    );
    const data = await getWebsiteVisits(filter);
    res.status(200).json({ success: true, data });
  } catch (error) {
    handleWebsiteVisitError(error, res, next);
  }
}

export async function getWebsiteVisitByDateController(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  try {
    const dateResult = parseDateOnly(req.params.date, "date", {
      required: true,
    });
    if (!dateResult.ok) {
      res.status(400).json({ success: false, message: dateResult.message });
      return;
    }

    const data = await getWebsiteVisitByDate(dateResult.value as string);
    if (!data) {
      res.status(404).json({
        success: false,
        message: "Website visit record not found for this date",
      });
      return;
    }

    res.status(200).json({ success: true, data });
  } catch (error) {
    handleWebsiteVisitError(error, res, next);
  }
}
