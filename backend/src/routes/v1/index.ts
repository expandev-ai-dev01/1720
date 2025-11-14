import { Router } from 'express';
import externalRoutes from '@/routes/v1/externalRoutes';
import internalRoutes from '@/routes/v1/internalRoutes';

const router = Router();

/**
 * @summary External (public) routes
 * @description Routes accessible without authentication
 */
router.use('/external', externalRoutes);

/**
 * @summary Internal (authenticated) routes
 * @description Routes requiring authentication
 */
router.use('/internal', internalRoutes);

export default router;
