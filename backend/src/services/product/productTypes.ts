/**
 * @interface ProductListParams
 * @description Parameters for listing products
 *
 * @property {number} idAccount - Account identifier
 * @property {number} idUser - User identifier
 * @property {number} [page] - Page number
 * @property {number} [pageSize] - Items per page
 * @property {string} [sortBy] - Sort criteria
 * @property {string} [categoryIds] - Comma-separated category IDs
 * @property {string} [flavorIds] - Comma-separated flavor IDs
 * @property {string} [sizeIds] - Comma-separated size IDs
 * @property {number} [minPrice] - Minimum price
 * @property {number} [maxPrice] - Maximum price
 * @property {string} [confectionerIds] - Comma-separated confectioner IDs
 * @property {string} [availability] - Availability filter
 * @property {string} [searchTerm] - Search term
 */
export interface ProductListParams {
  idAccount: number;
  idUser: number;
  page?: number;
  pageSize?: number;
  sortBy?: string;
  categoryIds?: string | null;
  flavorIds?: string | null;
  sizeIds?: string | null;
  minPrice?: number;
  maxPrice?: number;
  confectionerIds?: string | null;
  availability?: string;
  searchTerm?: string;
}

/**
 * @interface ProductGetParams
 * @description Parameters for getting product details
 *
 * @property {number} idAccount - Account identifier
 * @property {number} idUser - User identifier
 * @property {number} idProduct - Product identifier
 */
export interface ProductGetParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
}

/**
 * @interface ProductRelatedParams
 * @description Parameters for getting related products
 *
 * @property {number} idAccount - Account identifier
 * @property {number} idUser - User identifier
 * @property {number} idProduct - Product identifier
 * @property {number} [limit] - Number of related products
 * @property {string} [criteria] - Relation criteria
 */
export interface ProductRelatedParams {
  idAccount: number;
  idUser: number;
  idProduct: number;
  limit?: number;
  criteria?: string;
}
