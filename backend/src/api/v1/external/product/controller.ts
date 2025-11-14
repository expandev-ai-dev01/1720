import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import {
  CrudController,
  errorResponse,
  StatusGeneralError,
  successResponse,
} from '@/middleware/crud';
import { productList, productGet, productRelated } from '@/services/product';
import { zFK, zNullableString } from '@/utils/zodValidation';

const securable = 'PRODUCT';

/**
 * @api {get} /api/v1/external/product List Products
 * @apiName ListProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Lists products in the catalog with pagination, filtering, and sorting
 *
 * @apiParam {Number} [page=1] Page number
 * @apiParam {Number} [pageSize=12] Items per page (12, 24, or 36)
 * @apiParam {String} [sortBy=relevancia] Sort criteria
 * @apiParam {String} [categoryIds] Comma-separated category IDs
 * @apiParam {String} [flavorIds] Comma-separated flavor IDs
 * @apiParam {String} [sizeIds] Comma-separated size IDs
 * @apiParam {Number} [minPrice] Minimum price
 * @apiParam {Number} [maxPrice] Maximum price
 * @apiParam {String} [confectionerIds] Comma-separated confectioner IDs
 * @apiParam {String} [availability=disponivel] Availability filter
 * @apiParam {String} [searchTerm] Search term
 *
 * @apiSuccess {Array} products List of products
 * @apiSuccess {Object} pagination Pagination information
 *
 * @apiError {String} ValidationError Invalid parameters
 */
export async function listHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const querySchema = z.object({
    page: z.coerce.number().int().positive().optional().default(1),
    pageSize: z.coerce
      .number()
      .int()
      .refine((val) => [12, 24, 36].includes(val))
      .optional()
      .default(12),
    sortBy: z
      .enum([
        'relevancia',
        'preco_menor',
        'preco_maior',
        'mais_vendidos',
        'melhor_avaliados',
        'mais_recentes',
      ])
      .optional()
      .default('relevancia'),
    categoryIds: zNullableString(500),
    flavorIds: zNullableString(500),
    sizeIds: zNullableString(500),
    minPrice: z.coerce.number().nonnegative().optional(),
    maxPrice: z.coerce.number().nonnegative().optional(),
    confectionerIds: zNullableString(500),
    availability: z.enum(['disponivel', 'indisponivel', 'todos']).optional().default('disponivel'),
    searchTerm: z.string().max(100).optional(),
  });

  const [validated, error] = await operation.read(req, querySchema);

  if (!validated) {
    return next(error);
  }

  try {
    const data = await productList({
      ...validated.credential,
      ...validated.params,
    });

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}

/**
 * @api {get} /api/v1/external/product/:id Get Product Details
 * @apiName GetProduct
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Retrieves detailed information about a specific product
 *
 * @apiParam {Number} id Product identifier
 *
 * @apiSuccess {Object} product Product details
 * @apiSuccess {Array} images Product images
 * @apiSuccess {Array} flavors Available flavors
 * @apiSuccess {Array} sizes Available sizes
 * @apiSuccess {Array} reviews Product reviews
 * @apiSuccess {Object} confectioner Confectioner data
 *
 * @apiError {String} productDoesntExist Product not found
 */
export async function getHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const paramsSchema = z.object({
    id: zFK,
  });

  const [validated, error] = await operation.read(req, paramsSchema);

  if (!validated) {
    return next(error);
  }

  try {
    const data = await productGet({
      ...validated.credential,
      idProduct: validated.params.id,
    });

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}

/**
 * @api {get} /api/v1/external/product/:id/related Get Related Products
 * @apiName GetRelatedProducts
 * @apiGroup Product
 * @apiVersion 1.0.0
 *
 * @apiDescription Retrieves related products based on specified criteria
 *
 * @apiParam {Number} id Product identifier
 * @apiParam {Number} [limit=4] Number of related products
 * @apiParam {String} [criteria=categoria] Relation criteria
 *
 * @apiSuccess {Array} products List of related products
 *
 * @apiError {String} productDoesntExist Product not found
 */
export async function relatedHandler(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'READ' }]);

  const paramsSchema = z.object({
    id: zFK,
    limit: z.coerce.number().int().positive().optional().default(4),
    criteria: z
      .enum(['categoria', 'sabor', 'confeiteiro', 'popularidade'])
      .optional()
      .default('categoria'),
  });

  const [validated, error] = await operation.read(req, paramsSchema);

  if (!validated) {
    return next(error);
  }

  try {
    const data = await productRelated({
      ...validated.credential,
      idProduct: validated.params.id,
      limit: validated.params.limit,
      criteria: validated.params.criteria,
    });

    res.json(successResponse(data));
  } catch (error: any) {
    if (error.number === 51000) {
      res.status(400).json(errorResponse(error.message));
    } else {
      next(StatusGeneralError);
    }
  }
}
