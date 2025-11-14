/**
 * @summary
 * Retrieves related products based on specified criteria (category, flavor, confectioner, or popularity).
 * Excludes the current product and returns only available products.
 *
 * @procedure spProductRelated
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/external/product/:id/related
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Reference product identifier
 *
 * @param {INT} limit
 *   - Required: No
 *   - Description: Number of related products to return (default: 4)
 *
 * @param {NVARCHAR} criteria
 *   - Required: No
 *   - Description: Relation criteria ('categoria', 'sabor', 'confeiteiro', 'popularidade', default: 'categoria')
 *
 * @testScenarios
 * - Retrieve related products by category
 * - Retrieve related products by confectioner
 * - Handle insufficient related products
 * - Exclude current product from results
 */
CREATE OR ALTER PROCEDURE [functional].[spProductRelated]
  @idAccount INT,
  @idProduct INT,
  @limit INT = 4,
  @criteria NVARCHAR(50) = 'categoria'
AS
BEGIN
  SET NOCOUNT ON;

  /**
   * @validation Parameter validation
   * @throw {parameterRequired}
   */
  IF (@idAccount IS NULL)
  BEGIN
    ;THROW 51000, 'idAccountRequired', 1;
  END;

  IF (@idProduct IS NULL)
  BEGIN
    ;THROW 51000, 'idProductRequired', 1;
  END;

  IF (@limit < 1)
  BEGIN
    SET @limit = 4;
  END;

  IF (@criteria NOT IN ('categoria', 'sabor', 'confeiteiro', 'popularidade'))
  BEGIN
    SET @criteria = 'categoria';
  END;

  /**
   * @validation Product existence validation
   * @throw {productDoesntExist}
   */
  IF NOT EXISTS (
    SELECT 1
    FROM [functional].[product] [prd]
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] = @idProduct
      AND [prd].[deleted] = 0
  )
  BEGIN
    ;THROW 51000, 'productDoesntExist', 1;
  END;

  /**
   * @rule {br-023,br-024,br-25,br-26} Apply relation criteria and filters
   */
  DECLARE @idCategory INT;
  DECLARE @idConfectioner INT;

  SELECT
    @idCategory = [prd].[idCategory],
    @idConfectioner = [prd].[idConfectioner]
  FROM [functional].[product] [prd]
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[idProduct] = @idProduct;

  /**
   * @output {RelatedProducts, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} imageUrl - Primary product image URL
   * @column {NUMERIC} price - Current product price
   * @column {NUMERIC} originalPrice - Original price (if on promotion)
   * @column {BIT} isPromotion - Promotion indicator
   * @column {NUMERIC} averageRating - Average customer rating
   * @column {INT} totalReviews - Total number of reviews
   * @column {NVARCHAR} confectionerName - Confectioner name
   */
  IF (@criteria = 'categoria')
  BEGIN
    SELECT TOP (@limit)
      [prd].[idProduct],
      [prd].[name],
      [prdImg].[imageUrl],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
        ELSE [prd].[basePrice]
      END AS [price],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[basePrice]
        ELSE NULL
      END AS [originalPrice],
      [prd].[isPromotion],
      [prd].[averageRating],
      [prd].[totalReviews],
      [cnf].[name] AS [confectionerName]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
      LEFT JOIN [functional].[productImage] [prdImg] ON ([prdImg].[idAccount] = [prd].[idAccount] AND [prdImg].[idProduct] = [prd].[idProduct] AND [prdImg].[isPrimary] = 1)
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[idCategory] = @idCategory
      AND [prd].[available] = 1
      AND [prd].[stock] > 0
      AND [prd].[deleted] = 0
      AND [cnf].[deleted] = 0
    ORDER BY [prd].[averageRating] DESC, [prd].[totalSales] DESC;
  END
  ELSE IF (@criteria = 'confeiteiro')
  BEGIN
    SELECT TOP (@limit)
      [prd].[idProduct],
      [prd].[name],
      [prdImg].[imageUrl],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
        ELSE [prd].[basePrice]
      END AS [price],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[basePrice]
        ELSE NULL
      END AS [originalPrice],
      [prd].[isPromotion],
      [prd].[averageRating],
      [prd].[totalReviews],
      [cnf].[name] AS [confectionerName]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
      LEFT JOIN [functional].[productImage] [prdImg] ON ([prdImg].[idAccount] = [prd].[idAccount] AND [prdImg].[idProduct] = [prd].[idProduct] AND [prdImg].[isPrimary] = 1)
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[idConfectioner] = @idConfectioner
      AND [prd].[available] = 1
      AND [prd].[stock] > 0
      AND [prd].[deleted] = 0
      AND [cnf].[deleted] = 0
    ORDER BY [prd].[averageRating] DESC, [prd].[totalSales] DESC;
  END
  ELSE IF (@criteria = 'popularidade')
  BEGIN
    SELECT TOP (@limit)
      [prd].[idProduct],
      [prd].[name],
      [prdImg].[imageUrl],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
        ELSE [prd].[basePrice]
      END AS [price],
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[basePrice]
        ELSE NULL
      END AS [originalPrice],
      [prd].[isPromotion],
      [prd].[averageRating],
      [prd].[totalReviews],
      [cnf].[name] AS [confectionerName]
    FROM [functional].[product] [prd]
      JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
      LEFT JOIN [functional].[productImage] [prdImg] ON ([prdImg].[idAccount] = [prd].[idAccount] AND [prdImg].[idProduct] = [prd].[idProduct] AND [prdImg].[isPrimary] = 1)
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] <> @idProduct
      AND [prd].[available] = 1
      AND [prd].[stock] > 0
      AND [prd].[deleted] = 0
      AND [cnf].[deleted] = 0
    ORDER BY [prd].[totalSales] DESC, [prd].[averageRating] DESC;
  END;
END;
GO