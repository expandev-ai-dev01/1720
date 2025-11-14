import { Router } from 'express';

const router = Router();

/**
 * @summary External routes configuration
 * @description Public API endpoints for LoveCakes
 */

/**
 * @summary Public routes placeholder
 * @description Add public routes here (e.g., product catalog, public information)
 */
router.use('/public', (req, res) => {
  res.json({ message: 'Public routes endpoint' });
});

export default router;
