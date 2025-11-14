/**
 * @interface CartItemAddParams
 * @description Parameters for adding item to cart
 *
 * @property {number} idAccount - Account identifier
 * @property {number} idUser - User identifier
 * @property {string} sessionId - Session identifier
 * @property {number} idProduct - Product identifier
 * @property {number} idFlavor - Selected flavor identifier
 * @property {number} idSize - Selected size identifier
 * @property {number} quantity - Quantity to add
 * @property {string} [observations] - Additional observations
 */
export interface CartItemAddParams {
  idAccount: number;
  idUser: number;
  sessionId: string;
  idProduct: number;
  idFlavor: number;
  idSize: number;
  quantity: number;
  observations?: string;
}
