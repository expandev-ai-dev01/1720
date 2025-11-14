import { dbRequest, ExpectedReturn } from '@/utils/database';
import { CartItemAddParams } from '@/services/cart/cartTypes';

/**
 * @summary
 * Adds a product to the shopping cart or updates quantity if already exists
 *
 * @function cartItemAdd
 * @module cart
 *
 * @param {CartItemAddParams} params - Cart item add parameters
 *
 * @returns {Promise<any>} Cart item result
 *
 * @throws {ValidationError} When parameters fail validation
 * @throws {BusinessRuleError} When business rules are violated
 * @throws {DatabaseError} When database operation fails
 */
export async function cartItemAdd(params: CartItemAddParams): Promise<any> {
  const result = await dbRequest(
    '[functional].[spCartItemAdd]',
    {
      idAccount: params.idAccount,
      sessionId: params.sessionId,
      idProduct: params.idProduct,
      idFlavor: params.idFlavor,
      idSize: params.idSize,
      quantity: params.quantity,
      observations: params.observations,
    },
    ExpectedReturn.Single
  );

  return result;
}
