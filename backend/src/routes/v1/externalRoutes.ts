import { Router } from 'express';
import * as productController from '@/api/v1/external/product/controller';
import * as cartController from '@/api/v1/external/cart/controller';

const router = Router();

/**
 * @summary Product routes
 * @description Public product catalog endpoints
 */
router.get('/product', productController.listHandler);
router.get('/product/:id', productController.getHandler);
router.get('/product/:id/related', productController.relatedHandler);

/**
 * @summary Cart routes
 * @description Shopping cart endpoints
 */
router.post('/cart/item', cartController.addItemHandler);

export default router;
