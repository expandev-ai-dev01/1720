import { dbRequest, ExpectedReturn, IRecordSet } from '@/utils/database';
import {
  ProductListParams,
  ProductGetParams,
  ProductRelatedParams,
} from '@/services/product/productTypes';

/**
 * @summary
 * Lists products in the catalog with pagination, filtering, and sorting
 *
 * @function productList
 * @module product
 *
 * @param {ProductListParams} params - Product list parameters
 *
 * @returns {Promise<any>} Product list with pagination information
 *
 * @throws {ValidationError} When parameters fail validation
 * @throws {DatabaseError} When database operation fails
 */
export async function productList(params: ProductListParams): Promise<any> {
  const result = await dbRequest(
    '[functional].[spProductList]',
    {
      idAccount: params.idAccount,
      page: params.page,
      pageSize: params.pageSize,
      sortBy: params.sortBy,
      categoryIds: params.categoryIds,
      flavorIds: params.flavorIds,
      sizeIds: params.sizeIds,
      minPrice: params.minPrice,
      maxPrice: params.maxPrice,
      confectionerIds: params.confectionerIds,
      availability: params.availability,
      searchTerm: params.searchTerm,
    },
    ExpectedReturn.Multi,
    undefined,
    ['products', 'pagination']
  );

  return {
    products: result.products,
    pagination: result.pagination[0],
  };
}

/**
 * @summary
 * Retrieves detailed information about a specific product
 *
 * @function productGet
 * @module product
 *
 * @param {ProductGetParams} params - Product get parameters
 *
 * @returns {Promise<any>} Product details with images, flavors, sizes, reviews, and confectioner data
 *
 * @throws {ValidationError} When parameters fail validation
 * @throws {DatabaseError} When database operation fails
 */
export async function productGet(params: ProductGetParams): Promise<any> {
  const result = await dbRequest(
    '[functional].[spProductGet]',
    {
      idAccount: params.idAccount,
      idProduct: params.idProduct,
    },
    ExpectedReturn.Multi,
    undefined,
    ['product', 'images', 'flavors', 'sizes', 'reviews', 'confectioner']
  );

  return {
    product: result.product[0],
    images: result.images,
    flavors: result.flavors,
    sizes: result.sizes,
    reviews: result.reviews,
    confectioner: result.confectioner[0],
  };
}

/**
 * @summary
 * Retrieves related products based on specified criteria
 *
 * @function productRelated
 * @module product
 *
 * @param {ProductRelatedParams} params - Product related parameters
 *
 * @returns {Promise<any>} List of related products
 *
 * @throws {ValidationError} When parameters fail validation
 * @throws {DatabaseError} When database operation fails
 */
export async function productRelated(params: ProductRelatedParams): Promise<any> {
  const result = (await dbRequest(
    '[functional].[spProductRelated]',
    {
      idAccount: params.idAccount,
      idProduct: params.idProduct,
      limit: params.limit,
      criteria: params.criteria,
    },
    ExpectedReturn.Multi
  )) as IRecordSet<any>[];

  return result[0];
}
