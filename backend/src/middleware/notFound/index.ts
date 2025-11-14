import { Request, Response } from 'express';

/**
 * @summary 404 Not Found middleware
 * @description Handles requests to non-existent routes
 */
export function notFoundMiddleware(req: Request, res: Response): void {
  res.status(404).json({
    success: false,
    error: {
      code: 'NOT_FOUND',
      message: 'routeNotFound',
      path: req.path,
    },
    timestamp: new Date().toISOString(),
  });
}
