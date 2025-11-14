/**
 * @summary
 * Retrieves detailed information about a specific product including images,
 * available flavors, sizes, reviews, and confectioner data.
 *
 * @procedure spProductGet
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/external/product/:id
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @testScenarios
 * - Retrieve product details with valid ID
 * - Handle non-existent product ID
 * - Verify all related data is returned
 */
CREATE OR ALTER PROCEDURE [functional].[spProductGet]
  @idAccount INT,
  @idProduct INT
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
   * @output {ProductDetails, 1, 1}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} description - Product description
   * @column {NVARCHAR} ingredients - Product ingredients (JSON array)
   * @column {NVARCHAR} nutritionalInfo - Nutritional information (JSON object)
   * @column {NUMERIC} basePrice - Base product price
   * @column {NUMERIC} promotionalPrice - Promotional price (if applicable)
   * @column {BIT} isPromotion - Promotion indicator
   * @column {BIT} available - Availability status
   * @column {NVARCHAR} preparationTime - Preparation time estimate
   * @column {NUMERIC} averageRating - Average customer rating
   * @column {INT} totalReviews - Total number of reviews
   */
  SELECT
    [prd].[idProduct],
    [prd].[name],
    [prd].[description],
    [prd].[ingredients],
    [prd].[nutritionalInfo],
    [prd].[basePrice],
    [prd].[promotionalPrice],
    [prd].[isPromotion],
    [prd].[available],
    [prd].[preparationTime],
    [prd].[averageRating],
    [prd].[totalReviews]
  FROM [functional].[product] [prd]
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[idProduct] = @idProduct
    AND [prd].[deleted] = 0;

  /**
   * @output {ProductImages, n, n}
   * @column {INT} idProductImage - Image identifier
   * @column {NVARCHAR} imageUrl - Image URL
   * @column {BIT} isPrimary - Primary image indicator
   * @column {INT} displayOrder - Display order
   */
  SELECT
    [prdImg].[idProductImage],
    [prdImg].[imageUrl],
    [prdImg].[isPrimary],
    [prdImg].[displayOrder]
  FROM [functional].[productImage] [prdImg]
  WHERE [prdImg].[idAccount] = @idAccount
    AND [prdImg].[idProduct] = @idProduct
  ORDER BY [prdImg].[isPrimary] DESC, [prdImg].[displayOrder] ASC;

  /**
   * @output {AvailableFlavors, n, n}
   * @column {INT} idFlavor - Flavor identifier
   * @column {NVARCHAR} name - Flavor name
   * @column {NVARCHAR} description - Flavor description
   */
  SELECT
    [flv].[idFlavor],
    [flv].[name],
    [flv].[description]
  FROM [functional].[flavor] [flv]
    JOIN [functional].[productFlavor] [prdFlv] ON ([prdFlv].[idAccount] = [flv].[idAccount] AND [prdFlv].[idFlavor] = [flv].[idFlavor])
  WHERE [flv].[idAccount] = @idAccount
    AND [prdFlv].[idProduct] = @idProduct
    AND [prdFlv].[available] = 1
    AND [flv].[deleted] = 0
  ORDER BY [flv].[name] ASC;

  /**
   * @output {AvailableSizes, n, n}
   * @column {INT} idSize - Size identifier
   * @column {NVARCHAR} name - Size name
   * @column {NVARCHAR} description - Size description
   * @column {INT} servings - Number of servings
   * @column {NUMERIC} priceModifier - Price modifier for this size
   */
  SELECT
    [siz].[idSize],
    [siz].[name],
    [siz].[description],
    [siz].[servings],
    [siz].[priceModifier]
  FROM [functional].[size] [siz]
    JOIN [functional].[productSize] [prdSiz] ON ([prdSiz].[idAccount] = [siz].[idAccount] AND [prdSiz].[idSize] = [siz].[idSize])
  WHERE [siz].[idAccount] = @idAccount
    AND [prdSiz].[idProduct] = @idProduct
    AND [prdSiz].[available] = 1
    AND [siz].[deleted] = 0
  ORDER BY [siz].[servings] ASC;

  /**
   * @output {ProductReviews, n, n}
   * @column {INT} idReview - Review identifier
   * @column {NVARCHAR} customerName - Customer name
   * @column {INT} rating - Rating (1-5)
   * @column {NVARCHAR} comment - Review comment
   * @column {DATETIME2} dateCreated - Review date
   */
  SELECT
    [rev].[idReview],
    [rev].[customerName],
    [rev].[rating],
    [rev].[comment],
    [rev].[dateCreated]
  FROM [functional].[review] [rev]
  WHERE [rev].[idAccount] = @idAccount
    AND [rev].[idProduct] = @idProduct
    AND [rev].[deleted] = 0
  ORDER BY [rev].[dateCreated] DESC;

  /**
   * @output {ConfectionerData, 1, 1}
   * @column {INT} idConfectioner - Confectioner identifier
   * @column {NVARCHAR} name - Confectioner name
   * @column {NVARCHAR} photo - Confectioner photo URL
   * @column {NUMERIC} averageRating - Confectioner average rating
   * @column {INT} totalProductsSold - Total products sold
   */
  SELECT
    [cnf].[idConfectioner],
    [cnf].[name],
    [cnf].[photo],
    [cnf].[averageRating],
    [cnf].[totalProductsSold]
  FROM [functional].[confectioner] [cnf]
    JOIN [functional].[product] [prd] ON ([prd].[idAccount] = [cnf].[idAccount] AND [prd].[idConfectioner] = [cnf].[idConfectioner])
  WHERE [cnf].[idAccount] = @idAccount
    AND [prd].[idProduct] = @idProduct
    AND [cnf].[deleted] = 0;
END;
GO