import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import {
  CrudController,
  errorResponse,
  StatusGeneralError,
  successResponse,
} from '@/middleware/crud';
import { cartItemAdd } from '@/services/cart';
import { zFK, zNullableString } from '@/utils/zodValidation';

const securable = 'CART';

/**
 * @api {post} /api/v1/external/cart/item Add Item to Cart
 * @apiName AddCartItem
 * @apiGroup Cart
 * @apiVersion 1.0.0
 *
 * @apiDescription Adds a product to the shopping cart or updates quantity if already exists
 *
 * @apiParam {String} sessionId Session identifier
 * @apiParam {Number} idProduct Product identifier
 * @apiParam {Number} idFlavor Selected flavor identifier
 * @apiParam {Number} idSize Selected size identifier
 * @apiParam {Number} quantity Quantity to add (1-10)
 * @apiParam {String} [observations] Additional observations
 *
 * @apiSuccess {Number} idCartItem Cart item identifier
 * @apiSuccess {Number} idCart Cart identifier
 * @apiSuccess {Number} quantity Item quantity
 * @apiSuccess {Number} unitPrice Unit price
 * @apiSuccess {Number} totalPrice Total price
 *
 * @apiError {String} productDoesntExist Product not found
 * @apiError {String} productNotAvailable Product not available
 * @apiError {String} flavorNotAvailable Flavor not available
 * @apiError {String} sizeNotAvailable Size not available
 * @apiError {String} quantityExceedsMaximum Quantity exceeds maximum
 */
export async function addItemHandler(
  req: Request,
  res: Response,
  next: NextFunction
): Promise<void> {
  const operation = new CrudController([{ securable, permission: 'CREATE' }]);

  const bodySchema = z.object({
    sessionId: z.string().min(1).max(255),
    idProduct: zFK,
    idFlavor: zFK,
    idSize: zFK,
    quantity: z.coerce.number().int().min(1).max(10),
    observations: z.string().max(200).optional(),
  });

  const [validated, error] = await operation.create(req, bodySchema);

  if (!validated) {
    return next(error);
  }

  try {
    const data = await cartItemAdd({
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
