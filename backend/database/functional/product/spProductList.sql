/**
 * @summary
 * Lists products in the catalog with pagination, filtering, and sorting capabilities.
 * Supports filtering by category, flavor, size, price range, confectioner, availability,
 * and search term. Returns products with their primary image and confectioner information.
 *
 * @procedure spProductList
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - GET /api/v1/external/product
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {INT} page
 *   - Required: No
 *   - Description: Page number for pagination (default: 1)
 *
 * @param {INT} pageSize
 *   - Required: No
 *   - Description: Number of items per page (default: 12, allowed: 12, 24, 36)
 *
 * @param {NVARCHAR} sortBy
 *   - Required: No
 *   - Description: Sort criteria (default: 'relevancia')
 *   - Values: 'relevancia', 'preco_menor', 'preco_maior', 'mais_vendidos', 'melhor_avaliados', 'mais_recentes'
 *
 * @param {NVARCHAR} categoryIds
 *   - Required: No
 *   - Description: Comma-separated category IDs for filtering
 *
 * @param {NVARCHAR} flavorIds
 *   - Required: No
 *   - Description: Comma-separated flavor IDs for filtering
 *
 * @param {NVARCHAR} sizeIds
 *   - Required: No
 *   - Description: Comma-separated size IDs for filtering
 *
 * @param {NUMERIC} minPrice
 *   - Required: No
 *   - Description: Minimum price filter
 *
 * @param {NUMERIC} maxPrice
 *   - Required: No
 *   - Description: Maximum price filter
 *
 * @param {NVARCHAR} confectionerIds
 *   - Required: No
 *   - Description: Comma-separated confectioner IDs for filtering
 *
 * @param {NVARCHAR} availability
 *   - Required: No
 *   - Description: Availability filter ('disponivel', 'indisponivel', 'todos', default: 'disponivel')
 *
 * @param {NVARCHAR} searchTerm
 *   - Required: No
 *   - Description: Search term for product name, description, or ingredients
 *
 * @testScenarios
 * - List products with default pagination and sorting
 * - Filter products by multiple categories
 * - Filter products by price range
 * - Search products by term
 * - Sort products by different criteria
 * - Filter by availability status
 */
CREATE OR ALTER PROCEDURE [functional].[spProductList]
  @idAccount INT,
  @page INT = 1,
  @pageSize INT = 12,
  @sortBy NVARCHAR(50) = 'relevancia',
  @categoryIds NVARCHAR(MAX) = NULL,
  @flavorIds NVARCHAR(MAX) = NULL,
  @sizeIds NVARCHAR(MAX) = NULL,
  @minPrice NUMERIC(18, 6) = NULL,
  @maxPrice NUMERIC(18, 6) = NULL,
  @confectionerIds NVARCHAR(MAX) = NULL,
  @availability NVARCHAR(20) = 'disponivel',
  @searchTerm NVARCHAR(100) = NULL
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

  IF (@page < 1)
  BEGIN
    SET @page = 1;
  END;

  IF (@pageSize NOT IN (12, 24, 36))
  BEGIN
    SET @pageSize = 12;
  END;

  IF (@availability NOT IN ('disponivel', 'indisponivel', 'todos'))
  BEGIN
    SET @availability = 'disponivel';
  END;

  /**
   * @rule {db-multi-tenancy-pattern} Apply account-based filtering
   */
  DECLARE @offset INT = (@page - 1) * @pageSize;

  /**
   * @output {ProductList, n, n}
   * @column {INT} idProduct - Product identifier
   * @column {NVARCHAR} name - Product name
   * @column {NVARCHAR} imageUrl - Primary product image URL
   * @column {NUMERIC} price - Current product price
   * @column {NUMERIC} originalPrice - Original price (if on promotion)
   * @column {BIT} isPromotion - Promotion indicator
   * @column {NUMERIC} averageRating - Average customer rating
   * @column {INT} totalReviews - Total number of reviews
   * @column {NVARCHAR} confectionerName - Confectioner name
   * @column {BIT} available - Availability status
   * @column {NVARCHAR} preparationTime - Preparation time estimate
   */
  SELECT
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
    [cnf].[name] AS [confectionerName],
    [prd].[available],
    [prd].[preparationTime]
  FROM [functional].[product] [prd]
    JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
    LEFT JOIN [functional].[productImage] [prdImg] ON ([prdImg].[idAccount] = [prd].[idAccount] AND [prdImg].[idProduct] = [prd].[idProduct] AND [prdImg].[isPrimary] = 1)
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[deleted] = 0
    AND [cnf].[deleted] = 0
    /**
     * @rule {br-001} Filter only active products
     */
    AND (
      (@availability = 'disponivel' AND [prd].[available] = 1 AND [prd].[stock] > 0)
      OR (@availability = 'indisponivel' AND ([prd].[available] = 0 OR [prd].[stock] = 0))
      OR (@availability = 'todos')
    )
    /**
     * @rule {br-005,br-006} Apply combined filters with AND logic
     */
    AND (
      @categoryIds IS NULL
      OR [prd].[idCategory] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@categoryIds, ','))
    )
    AND (
      @flavorIds IS NULL
      OR EXISTS (
        SELECT 1
        FROM [functional].[productFlavor] [prdFlv]
        WHERE [prdFlv].[idAccount] = [prd].[idAccount]
          AND [prdFlv].[idProduct] = [prd].[idProduct]
          AND [prdFlv].[idFlavor] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@flavorIds, ','))
          AND [prdFlv].[available] = 1
      )
    )
    AND (
      @sizeIds IS NULL
      OR EXISTS (
        SELECT 1
        FROM [functional].[productSize] [prdSiz]
        WHERE [prdSiz].[idAccount] = [prd].[idAccount]
          AND [prdSiz].[idProduct] = [prd].[idProduct]
          AND [prdSiz].[idSize] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@sizeIds, ','))
          AND [prdSiz].[available] = 1
      )
    )
    AND (
      @minPrice IS NULL
      OR (
        CASE
          WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
          ELSE [prd].[basePrice]
        END >= @minPrice
      )
    )
    AND (
      @maxPrice IS NULL
      OR (
        CASE
          WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
          ELSE [prd].[basePrice]
        END <= @maxPrice
      )
    )
    AND (
      @confectionerIds IS NULL
      OR [prd].[idConfectioner] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@confectionerIds, ','))
    )
    AND (
      @searchTerm IS NULL
      OR [prd].[name] LIKE '%' + @searchTerm + '%'
      OR [prd].[description] LIKE '%' + @searchTerm + '%'
      OR [prd].[ingredients] LIKE '%' + @searchTerm + '%'
    )
  ORDER BY
    CASE WHEN @sortBy = 'preco_menor' THEN
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
        ELSE [prd].[basePrice]
      END
    END ASC,
    CASE WHEN @sortBy = 'preco_maior' THEN
      CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
        ELSE [prd].[basePrice]
      END
    END DESC,
    CASE WHEN @sortBy = 'mais_vendidos' THEN [prd].[totalSales] END DESC,
    CASE WHEN @sortBy = 'melhor_avaliados' THEN [prd].[averageRating] END DESC,
    CASE WHEN @sortBy = 'mais_recentes' THEN [prd].[dateCreated] END DESC,
    [prd].[idProduct] ASC
  OFFSET @offset ROWS
  FETCH NEXT @pageSize ROWS ONLY;

  /**
   * @output {Pagination, 1, 1}
   * @column {INT} totalItems - Total number of items matching filters
   * @column {INT} totalPages - Total number of pages
   * @column {INT} currentPage - Current page number
   * @column {INT} pageSize - Items per page
   */
  SELECT
    COUNT(*) AS [totalItems],
    CEILING(CAST(COUNT(*) AS FLOAT) / @pageSize) AS [totalPages],
    @page AS [currentPage],
    @pageSize AS [pageSize]
  FROM [functional].[product] [prd]
    JOIN [functional].[confectioner] [cnf] ON ([cnf].[idAccount] = [prd].[idAccount] AND [cnf].[idConfectioner] = [prd].[idConfectioner])
  WHERE [prd].[idAccount] = @idAccount
    AND [prd].[deleted] = 0
    AND [cnf].[deleted] = 0
    AND (
      (@availability = 'disponivel' AND [prd].[available] = 1 AND [prd].[stock] > 0)
      OR (@availability = 'indisponivel' AND ([prd].[available] = 0 OR [prd].[stock] = 0))
      OR (@availability = 'todos')
    )
    AND (
      @categoryIds IS NULL
      OR [prd].[idCategory] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@categoryIds, ','))
    )
    AND (
      @flavorIds IS NULL
      OR EXISTS (
        SELECT 1
        FROM [functional].[productFlavor] [prdFlv]
        WHERE [prdFlv].[idAccount] = [prd].[idAccount]
          AND [prdFlv].[idProduct] = [prd].[idProduct]
          AND [prdFlv].[idFlavor] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@flavorIds, ','))
          AND [prdFlv].[available] = 1
      )
    )
    AND (
      @sizeIds IS NULL
      OR EXISTS (
        SELECT 1
        FROM [functional].[productSize] [prdSiz]
        WHERE [prdSiz].[idAccount] = [prd].[idAccount]
          AND [prdSiz].[idProduct] = [prd].[idProduct]
          AND [prdSiz].[idSize] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@sizeIds, ','))
          AND [prdSiz].[available] = 1
      )
    )
    AND (
      @minPrice IS NULL
      OR (
        CASE
          WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
          ELSE [prd].[basePrice]
        END >= @minPrice
      )
    )
    AND (
      @maxPrice IS NULL
      OR (
        CASE
          WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice]
          ELSE [prd].[basePrice]
        END <= @maxPrice
      )
    )
    AND (
      @confectionerIds IS NULL
      OR [prd].[idConfectioner] IN (SELECT CAST([value] AS INT) FROM STRING_SPLIT(@confectionerIds, ','))
    )
    AND (
      @searchTerm IS NULL
      OR [prd].[name] LIKE '%' + @searchTerm + '%'
      OR [prd].[description] LIKE '%' + @searchTerm + '%'
      OR [prd].[ingredients] LIKE '%' + @searchTerm + '%'
    );
END;
GO