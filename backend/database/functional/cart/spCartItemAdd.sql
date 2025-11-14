/**
 * @summary
 * Adds a product to the shopping cart or updates quantity if already exists.
 * Creates a new cart if one doesn't exist for the session.
 *
 * @procedure spCartItemAdd
 * @schema functional
 * @type stored-procedure
 *
 * @endpoints
 * - POST /api/v1/external/cart/item
 *
 * @parameters
 * @param {INT} idAccount
 *   - Required: Yes
 *   - Description: Account identifier for multi-tenancy
 *
 * @param {NVARCHAR} sessionId
 *   - Required: Yes
 *   - Description: Session identifier for cart
 *
 * @param {INT} idProduct
 *   - Required: Yes
 *   - Description: Product identifier
 *
 * @param {INT} idFlavor
 *   - Required: Yes
 *   - Description: Selected flavor identifier
 *
 * @param {INT} idSize
 *   - Required: Yes
 *   - Description: Selected size identifier
 *
 * @param {INT} quantity
 *   - Required: Yes
 *   - Description: Quantity to add (1-10)
 *
 * @param {NVARCHAR} observations
 *   - Required: No
 *   - Description: Additional observations
 *
 * @testScenarios
 * - Add new item to cart
 * - Update quantity of existing item
 * - Validate product availability
 * - Validate flavor and size availability
 * - Enforce quantity limits
 */
CREATE OR ALTER PROCEDURE [functional].[spCartItemAdd]
  @idAccount INT,
  @sessionId NVARCHAR(255),
  @idProduct INT,
  @idFlavor INT,
  @idSize INT,
  @quantity INT,
  @observations NVARCHAR(200) = NULL
AS
BEGIN
  SET NOCOUNT ON;

  BEGIN TRY
    BEGIN TRAN;

    /**
     * @validation Parameter validation
     * @throw {parameterRequired}
     */
    IF (@idAccount IS NULL)
    BEGIN
      ;THROW 51000, 'idAccountRequired', 1;
    END;

    IF (@sessionId IS NULL OR LEN(@sessionId) = 0)
    BEGIN
      ;THROW 51000, 'sessionIdRequired', 1;
    END;

    IF (@idProduct IS NULL)
    BEGIN
      ;THROW 51000, 'idProductRequired', 1;
    END;

    IF (@idFlavor IS NULL)
    BEGIN
      ;THROW 51000, 'idFlavorRequired', 1;
    END;

    IF (@idSize IS NULL)
    BEGIN
      ;THROW 51000, 'idSizeRequired', 1;
    END;

    IF (@quantity IS NULL OR @quantity < 1)
    BEGIN
      ;THROW 51000, 'quantityMustBeGreaterThanZero', 1;
    END;

    IF (@quantity > 10)
    BEGIN
      ;THROW 51000, 'quantityExceedsMaximum', 1;
    END;

    /**
     * @validation Product existence and availability
     * @throw {productDoesntExist, productNotAvailable}
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

    IF NOT EXISTS (
      SELECT 1
      FROM [functional].[product] [prd]
      WHERE [prd].[idAccount] = @idAccount
        AND [prd].[idProduct] = @idProduct
        AND [prd].[available] = 1
        AND [prd].[stock] > 0
        AND [prd].[deleted] = 0
    )
    BEGIN
      ;THROW 51000, 'productNotAvailable', 1;
    END;

    /**
     * @validation Flavor availability for product
     * @throw {flavorNotAvailable}
     */
    IF NOT EXISTS (
      SELECT 1
      FROM [functional].[productFlavor] [prdFlv]
      WHERE [prdFlv].[idAccount] = @idAccount
        AND [prdFlv].[idProduct] = @idProduct
        AND [prdFlv].[idFlavor] = @idFlavor
        AND [prdFlv].[available] = 1
    )
    BEGIN
      ;THROW 51000, 'flavorNotAvailable', 1;
    END;

    /**
     * @validation Size availability for product
     * @throw {sizeNotAvailable}
     */
    IF NOT EXISTS (
      SELECT 1
      FROM [functional].[productSize] [prdSiz]
      WHERE [prdSiz].[idAccount] = @idAccount
        AND [prdSiz].[idProduct] = @idProduct
        AND [prdSiz].[idSize] = @idSize
        AND [prdSiz].[available] = 1
    )
    BEGIN
      ;THROW 51000, 'sizeNotAvailable', 1;
    END;

    /**
     * @rule {db-transaction-control-pattern} Ensure cart exists or create new one
     */
    DECLARE @idCart INT;

    SELECT @idCart = [crt].[idCart]
    FROM [functional].[cart] [crt]
    WHERE [crt].[idAccount] = @idAccount
      AND [crt].[sessionId] = @sessionId;

    IF (@idCart IS NULL)
    BEGIN
      INSERT INTO [functional].[cart] ([idAccount], [sessionId])
      VALUES (@idAccount, @sessionId);

      SET @idCart = SCOPE_IDENTITY();
    END;

    /**
     * @rule {br-013} Calculate price with size modifier
     */
    DECLARE @unitPrice NUMERIC(18, 6);
    DECLARE @totalPrice NUMERIC(18, 6);

    SELECT
      @unitPrice = CASE
        WHEN [prd].[isPromotion] = 1 THEN [prd].[promotionalPrice] + [siz].[priceModifier]
        ELSE [prd].[basePrice] + [siz].[priceModifier]
      END
    FROM [functional].[product] [prd]
      JOIN [functional].[size] [siz] ON ([siz].[idAccount] = [prd].[idAccount])
    WHERE [prd].[idAccount] = @idAccount
      AND [prd].[idProduct] = @idProduct
      AND [siz].[idSize] = @idSize;

    SET @totalPrice = @unitPrice * @quantity;

    /**
     * @rule {br-020} Check if item already exists in cart
     */
    DECLARE @idCartItem INT;
    DECLARE @existingQuantity INT;

    SELECT
      @idCartItem = [crtItm].[idCartItem],
      @existingQuantity = [crtItm].[quantity]
    FROM [functional].[cartItem] [crtItm]
    WHERE [crtItm].[idAccount] = @idAccount
      AND [crtItm].[idCart] = @idCart
      AND [crtItm].[idProduct] = @idProduct
      AND [crtItm].[idFlavor] = @idFlavor
      AND [crtItm].[idSize] = @idSize;

    IF (@idCartItem IS NOT NULL)
    BEGIN
      /**
       * @rule {br-021} Validate total quantity doesn't exceed maximum
       */
      DECLARE @newQuantity INT = @existingQuantity + @quantity;

      IF (@newQuantity > 10)
      BEGIN
        ;THROW 51000, 'quantityExceedsMaximum', 1;
      END;

      SET @totalPrice = @unitPrice * @newQuantity;

      UPDATE [functional].[cartItem]
      SET
        [quantity] = @newQuantity,
        [totalPrice] = @totalPrice,
        [observations] = COALESCE(@observations, [observations]),
        [dateModified] = GETUTCDATE()
      WHERE [idCartItem] = @idCartItem;
    END
    ELSE
    BEGIN
      INSERT INTO [functional].[cartItem] (
        [idAccount],
        [idCart],
        [idProduct],
        [idFlavor],
        [idSize],
        [quantity],
        [unitPrice],
        [totalPrice],
        [observations]
      )
      VALUES (
        @idAccount,
        @idCart,
        @idProduct,
        @idFlavor,
        @idSize,
        @quantity,
        @unitPrice,
        @totalPrice,
        @observations
      );

      SET @idCartItem = SCOPE_IDENTITY();
    END;

    COMMIT TRAN;

    /**
     * @output {CartItemResult, 1, 1}
     * @column {INT} idCartItem - Cart item identifier
     * @column {INT} idCart - Cart identifier
     * @column {INT} quantity - Item quantity
     * @column {NUMERIC} unitPrice - Unit price
     * @column {NUMERIC} totalPrice - Total price
     */
    SELECT
      [crtItm].[idCartItem],
      [crtItm].[idCart],
      [crtItm].[quantity],
      [crtItm].[unitPrice],
      [crtItm].[totalPrice]
    FROM [functional].[cartItem] [crtItm]
    WHERE [crtItm].[idCartItem] = @idCartItem;
  END TRY
  BEGIN CATCH
    ROLLBACK TRAN;
    THROW;
  END CATCH;
END;
GO