/**
 * @schema functional
 * Business entity schema for LoveCakes application
 */
CREATE SCHEMA [functional];
GO

/**
 * @table category
 * Product categories for organizing cakes
 * @multitenancy true
 * @softDelete true
 * @alias cat
 */
CREATE TABLE [functional].[category] (
  [idCategory] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table flavor
 * Available cake flavors
 * @multitenancy true
 * @softDelete true
 * @alias flv
 */
CREATE TABLE [functional].[flavor] (
  [idFlavor] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table size
 * Available cake sizes with pricing
 * @multitenancy true
 * @softDelete true
 * @alias siz
 */
CREATE TABLE [functional].[size] (
  [idSize] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(500) NOT NULL DEFAULT (''),
  [servings] INTEGER NOT NULL,
  [priceModifier] NUMERIC(18, 6) NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table confectioner
 * Confectioners/sellers in the platform
 * @multitenancy true
 * @softDelete true
 * @alias cnf
 */
CREATE TABLE [functional].[confectioner] (
  [idConfectioner] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [photo] NVARCHAR(500) NULL,
  [averageRating] NUMERIC(3, 1) NOT NULL DEFAULT (0),
  [totalProductsSold] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table product
 * Cake products available in the catalog
 * @multitenancy true
 * @softDelete true
 * @alias prd
 */
CREATE TABLE [functional].[product] (
  [idProduct] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCategory] INTEGER NOT NULL,
  [idConfectioner] INTEGER NOT NULL,
  [name] NVARCHAR(100) NOT NULL,
  [description] NVARCHAR(1000) NOT NULL,
  [ingredients] NVARCHAR(MAX) NOT NULL,
  [nutritionalInfo] NVARCHAR(MAX) NULL,
  [basePrice] NUMERIC(18, 6) NOT NULL,
  [promotionalPrice] NUMERIC(18, 6) NULL,
  [isPromotion] BIT NOT NULL DEFAULT (0),
  [available] BIT NOT NULL DEFAULT (1),
  [stock] INTEGER NOT NULL DEFAULT (0),
  [preparationTime] NVARCHAR(50) NOT NULL,
  [averageRating] NUMERIC(3, 1) NOT NULL DEFAULT (0),
  [totalReviews] INTEGER NOT NULL DEFAULT (0),
  [totalSales] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table productImage
 * Product image gallery
 * @multitenancy true
 * @softDelete false
 * @alias prdImg
 */
CREATE TABLE [functional].[productImage] (
  [idProductImage] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [imageUrl] NVARCHAR(500) NOT NULL,
  [isPrimary] BIT NOT NULL DEFAULT (0),
  [displayOrder] INTEGER NOT NULL DEFAULT (0),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table productFlavor
 * Available flavors for each product
 * @multitenancy true
 * @softDelete false
 * @alias prdFlv
 */
CREATE TABLE [functional].[productFlavor] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table productSize
 * Available sizes for each product
 * @multitenancy true
 * @softDelete false
 * @alias prdSiz
 */
CREATE TABLE [functional].[productSize] (
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL,
  [available] BIT NOT NULL DEFAULT (1),
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table review
 * Product reviews from customers
 * @multitenancy true
 * @softDelete true
 * @alias rev
 */
CREATE TABLE [functional].[review] (
  [idReview] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [customerName] NVARCHAR(100) NOT NULL,
  [rating] INTEGER NOT NULL,
  [comment] NVARCHAR(1000) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [deleted] BIT NOT NULL DEFAULT (0)
);
GO

/**
 * @table cart
 * Shopping cart for customers
 * @multitenancy true
 * @softDelete false
 * @alias crt
 */
CREATE TABLE [functional].[cart] (
  [idCart] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [sessionId] NVARCHAR(255) NOT NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @table cartItem
 * Items in shopping cart
 * @multitenancy true
 * @softDelete false
 * @alias crtItm
 */
CREATE TABLE [functional].[cartItem] (
  [idCartItem] INTEGER IDENTITY(1, 1) NOT NULL,
  [idAccount] INTEGER NOT NULL,
  [idCart] INTEGER NOT NULL,
  [idProduct] INTEGER NOT NULL,
  [idFlavor] INTEGER NOT NULL,
  [idSize] INTEGER NOT NULL,
  [quantity] INTEGER NOT NULL,
  [unitPrice] NUMERIC(18, 6) NOT NULL,
  [totalPrice] NUMERIC(18, 6) NOT NULL,
  [observations] NVARCHAR(200) NULL,
  [dateCreated] DATETIME2 NOT NULL DEFAULT (GETUTCDATE()),
  [dateModified] DATETIME2 NOT NULL DEFAULT (GETUTCDATE())
);
GO

/**
 * @primaryKey pkCategory
 * @keyType Object
 */
ALTER TABLE [functional].[category]
ADD CONSTRAINT [pkCategory] PRIMARY KEY CLUSTERED ([idCategory]);
GO

/**
 * @primaryKey pkFlavor
 * @keyType Object
 */
ALTER TABLE [functional].[flavor]
ADD CONSTRAINT [pkFlavor] PRIMARY KEY CLUSTERED ([idFlavor]);
GO

/**
 * @primaryKey pkSize
 * @keyType Object
 */
ALTER TABLE [functional].[size]
ADD CONSTRAINT [pkSize] PRIMARY KEY CLUSTERED ([idSize]);
GO

/**
 * @primaryKey pkConfectioner
 * @keyType Object
 */
ALTER TABLE [functional].[confectioner]
ADD CONSTRAINT [pkConfectioner] PRIMARY KEY CLUSTERED ([idConfectioner]);
GO

/**
 * @primaryKey pkProduct
 * @keyType Object
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [pkProduct] PRIMARY KEY CLUSTERED ([idProduct]);
GO

/**
 * @primaryKey pkProductImage
 * @keyType Object
 */
ALTER TABLE [functional].[productImage]
ADD CONSTRAINT [pkProductImage] PRIMARY KEY CLUSTERED ([idProductImage]);
GO

/**
 * @primaryKey pkProductFlavor
 * @keyType Relationship
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [pkProductFlavor] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idFlavor]);
GO

/**
 * @primaryKey pkProductSize
 * @keyType Relationship
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [pkProductSize] PRIMARY KEY CLUSTERED ([idAccount], [idProduct], [idSize]);
GO

/**
 * @primaryKey pkReview
 * @keyType Object
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [pkReview] PRIMARY KEY CLUSTERED ([idReview]);
GO

/**
 * @primaryKey pkCart
 * @keyType Object
 */
ALTER TABLE [functional].[cart]
ADD CONSTRAINT [pkCart] PRIMARY KEY CLUSTERED ([idCart]);
GO

/**
 * @primaryKey pkCartItem
 * @keyType Object
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [pkCartItem] PRIMARY KEY CLUSTERED ([idCartItem]);
GO

/**
 * @foreignKey fkProduct_Category
 * @target functional.category
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Category] FOREIGN KEY ([idCategory])
REFERENCES [functional].[category]([idCategory]);
GO

/**
 * @foreignKey fkProduct_Confectioner
 * @target functional.confectioner
 */
ALTER TABLE [functional].[product]
ADD CONSTRAINT [fkProduct_Confectioner] FOREIGN KEY ([idConfectioner])
REFERENCES [functional].[confectioner]([idConfectioner]);
GO

/**
 * @foreignKey fkProductImage_Product
 * @target functional.product
 */
ALTER TABLE [functional].[productImage]
ADD CONSTRAINT [fkProductImage_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductFlavor_Product
 * @target functional.product
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [fkProductFlavor_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductFlavor_Flavor
 * @target functional.flavor
 */
ALTER TABLE [functional].[productFlavor]
ADD CONSTRAINT [fkProductFlavor_Flavor] FOREIGN KEY ([idFlavor])
REFERENCES [functional].[flavor]([idFlavor]);
GO

/**
 * @foreignKey fkProductSize_Product
 * @target functional.product
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [fkProductSize_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkProductSize_Size
 * @target functional.size
 */
ALTER TABLE [functional].[productSize]
ADD CONSTRAINT [fkProductSize_Size] FOREIGN KEY ([idSize])
REFERENCES [functional].[size]([idSize]);
GO

/**
 * @foreignKey fkReview_Product
 * @target functional.product
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [fkReview_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCartItem_Cart
 * @target functional.cart
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Cart] FOREIGN KEY ([idCart])
REFERENCES [functional].[cart]([idCart]);
GO

/**
 * @foreignKey fkCartItem_Product
 * @target functional.product
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Product] FOREIGN KEY ([idProduct])
REFERENCES [functional].[product]([idProduct]);
GO

/**
 * @foreignKey fkCartItem_Flavor
 * @target functional.flavor
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Flavor] FOREIGN KEY ([idFlavor])
REFERENCES [functional].[flavor]([idFlavor]);
GO

/**
 * @foreignKey fkCartItem_Size
 * @target functional.size
 */
ALTER TABLE [functional].[cartItem]
ADD CONSTRAINT [fkCartItem_Size] FOREIGN KEY ([idSize])
REFERENCES [functional].[size]([idSize]);
GO

/**
 * @check chkReview_Rating
 * @enum {1} 1 star
 * @enum {2} 2 stars
 * @enum {3} 3 stars
 * @enum {4} 4 stars
 * @enum {5} 5 stars
 */
ALTER TABLE [functional].[review]
ADD CONSTRAINT [chkReview_Rating] CHECK ([rating] BETWEEN 1 AND 5);
GO

/**
 * @index ixCategory_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCategory_Account]
ON [functional].[category]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixFlavor_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixFlavor_Account]
ON [functional].[flavor]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixSize_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixSize_Account]
ON [functional].[size]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixConfectioner_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixConfectioner_Account]
ON [functional].[confectioner]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Account
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProduct_Account]
ON [functional].[product]([idAccount])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Category
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProduct_Category]
ON [functional].[product]([idAccount], [idCategory])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Confectioner
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProduct_Confectioner]
ON [functional].[product]([idAccount], [idConfectioner])
WHERE [deleted] = 0;
GO

/**
 * @index ixProduct_Available
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixProduct_Available]
ON [functional].[product]([idAccount], [available])
INCLUDE ([name], [basePrice], [averageRating])
WHERE [deleted] = 0;
GO

/**
 * @index ixProductImage_Product
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixProductImage_Product]
ON [functional].[productImage]([idAccount], [idProduct]);
GO

/**
 * @index ixReview_Product
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixReview_Product]
ON [functional].[review]([idAccount], [idProduct])
WHERE [deleted] = 0;
GO

/**
 * @index ixCart_Account_Session
 * @type Search
 */
CREATE NONCLUSTERED INDEX [ixCart_Account_Session]
ON [functional].[cart]([idAccount], [sessionId]);
GO

/**
 * @index ixCartItem_Cart
 * @type ForeignKey
 */
CREATE NONCLUSTERED INDEX [ixCartItem_Cart]
ON [functional].[cartItem]([idAccount], [idCart]);
GO

/**
 * @unique uqCategory_Account_Name
 * @type Unique
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqCategory_Account_Name]
ON [functional].[category]([idAccount], [name])
WHERE [deleted] = 0;
GO

/**
 * @unique uqFlavor_Account_Name
 * @type Unique
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqFlavor_Account_Name]
ON [functional].[flavor]([idAccount], [name])
WHERE [deleted] = 0;
GO

/**
 * @unique uqSize_Account_Name
 * @type Unique
 */
CREATE UNIQUE NONCLUSTERED INDEX [uqSize_Account_Name]
ON [functional].[size]([idAccount], [name])
WHERE [deleted] = 0;
GO