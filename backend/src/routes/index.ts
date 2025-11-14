import { Router } from 'express';
import v1Routes from '@/routes/v1';

const router = Router();

/**
 * @summary API Version 1 routes
 * @description Main router configuration with version management
 */
router.use('/v1', v1Routes);

export default router;
