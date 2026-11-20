CREATE DATABASE BidNile;

Go

USE BidNile

Go

CREATE SCHEMA [Identity];

Go

CREATE SCHEMA Location;

Go

CREATE SCHEMA Catalog;

Go

CREATE SCHEMA Auction;

Go

CREATE TABLE Location.Country
   (
       Code CHAR(2) NOT NULL,
       NameEn NVARCHAR(50) NOT NULL,       
	   NameAr NVARCHAR(50) NOT NULL,
	   PhoneCode VARCHAR(5) NOT NULL,


	   CONSTRAINT PK_Country 
	              PRIMARY KEY (Code)
   );

Go

CREATE TABLE Location.City
    (
	   Id INT IDENTITY(1,1) NOT NULL,
	   Name NVARCHAR(60) NOT NULL,
	   CountryCode CHAR(2) NOT NULL,
	
	   
	   CONSTRAINT PK_City
	              PRIMARY KEY (Id),

	   CONSTRAINT UQ_City_CountyCode_Name
	               UNIQUE(CountryCode , Name )

	);



Go

 CREATE TABLE [Identity].Member
    (
	   Id UNIQUEIDENTIFIER NOT NULL
	               CONSTRAINT DF_Member_ID DEFAULT NEWID(),

       FULLNAME NVARCHAR(100) NOT NULL,
	   Email VARCHAR(254) NOT NULL,
	   Mobile VARCHAR(16) NOT NULL,
	   NationalId VARCHAR(20) NOT NULL,
	   BirthDate DATE NOT NULL,

	   Vertified BIT NOT NULL
	             CONSTRAINT DF_Member_Vertified DEFAULT 0,

	   RegisteredAt DATETIME2(3) NOT NULL,

	   CityId INT NOT NULL,   

	   InvitedByMemberId UNIQUEIDENTIFIER NULL,

	   CONSTRAINT PK_Member
                  PRIMARY KEY (Id),

       CONSTRAINT UQ_Member_Email
                  UNIQUE (Email),

       CONSTRAINT UQ_Member_NationalId
                  UNIQUE (NationalId),

       CONSTRAINT CK_Member_MinimumAge
                  CHECK (DATEADD(YEAR, 18, BirthDate) <= GETDATE())
	); 

Go

 CREATE TABLE [Identity].Wallet
   (
	   MemberId UNIQUEIDENTIFIER NOT NULL,
	   Balance DECIMAL(12,2) NOT NULL
	             CONSTRAINT DF_Wallet_Balance DEFAULT 0,

	   AmountOnHold DECIMAL(12,2) NOT NULL
	             CONSTRAINT DF_Wallet_AmountOnHold DEFAULT 0,

	   Currency CHAR(3) NOT NULL
	             CONSTRAINT DF_Wallet_Currency DEFAULT 'EGP',

	   LastUpdatedAt DATETIME2(3) NOT NULL,

	   CONSTRAINT PK_Wallet
	              PRIMARY KEY (MemberId),

	   CONSTRAINT CK_Wallet_Balance
	              CHECK (Balance >= 0),

	   CONSTRAINT CK_Wallet_AmountOnHold
	              CHECK (AmountOnHold >= 0),

	   CONSTRAINT CK_Wallet_AmountOnHold_Balance
	              CHECK (AmountOnHold <= Balance)

   );

GO
 
 CREATE TABLE [Identity].Employee
   (
	   MemberId UNIQUEIDENTIFIER NOT NULL,
	   WarehouseId INT NOT NULL,

	   CONSTRAINT PK_Employee
	              PRIMARY KEY (MemberId)
   );

GO

 CREATE TABLE Location.Warehouse
   (
	   Id INT IDENTITY(1,1) NOT NULL,
	   Name NVARCHAR(80) NOT NULL,
	   Capacity INT NOT NULL,                 
	   Latitude FLOAT NOT NULL,
	   Longitude FLOAT NOT NULL,
       CityId INT NOT NULL,
	   ManagerId UNIQUEIDENTIFIER NOT NULL,
	   ManagerStartDate DATE NOT NULL,

	   CONSTRAINT PK_Warehouse
	              PRIMARY KEY (Id),

	   CONSTRAINT UQ_Warehouse_Name
	              UNIQUE (Name),

	   CONSTRAINT CK_Warehouse_Capacity
	              CHECK (Capacity > 0),

	   CONSTRAINT CK_Warehouse_Latitude
	              CHECK (Latitude BETWEEN -90 AND 90),

	   CONSTRAINT CK_Warehouse_Longitude
	              CHECK (Longitude BETWEEN -180 AND 180)

   ); 

GO

 CREATE TABLE Catalog.Category
    (
	   Code INT NOT NULL,
	   NameEn NVARCHAR(50) NOT NULL,
	   NameAr NVARCHAR(50) NOT NULL,
	   Commission DECIMAL(4,2) NOT NULL,
	   ParentCategoryCode INT NULL,

	   CONSTRAINT PK_Category
	              PRIMARY KEY (Code),

	   CONSTRAINT UQ_Category_NameEn
	              UNIQUE (NameEn),

	   CONSTRAINT CK_Category_Commission
	              CHECK (Commission BETWEEN 0 AND 30)
    );

GO

 CREATE TABLE Catalog.Item
     (
	   Id INT IDENTITY(1,1) NOT NULL,
	   Title NVARCHAR(150) NOT NULL,
       Description NVARCHAR(MAX) NULL,

       ConditionScore TINYINT NOT NULL
	              CONSTRAINT CK_Item_ConditionScore
	              CHECK (ConditionScore BETWEEN 1 AND 10),
	   
	   Specifications NVARCHAR(MAX) NOT NULL,
       ListedAt DATETIME2(3) NOT NULL,

       CategoryCode INT NOT NULL,
       SellerId UNIQUEIDENTIFIER NOT NULL,
       InspectorId UNIQUEIDENTIFIER NOT NULL,
       WarehouseId INT NULL,

       CONSTRAINT PK_Item
	              PRIMARY KEY (Id),

	   CONSTRAINT CK_Item_Specifications
	              CHECK (ISJSON(Specifications) = 1),

	   CONSTRAINT CK_Item_Seller_Inspector
	              CHECK (SellerId <> InspectorId)
    );

GO

 CREATE TABLE Catalog.ItemPhoto
    (
	   ItemId INT NOT NULL,
	   Position TINYINT NOT NULL,
	   PhotoUrl VARCHAR(500) NOT NULL,

	   IsMain BIT NOT NULL
	              CONSTRAINT DF_ItemPhoto_IsMain DEFAULT 0,

	   CONSTRAINT PK_ItemPhoto
	              PRIMARY KEY (ItemId, Position),

	   CONSTRAINT CK_ItemPhoto_Position
	              CHECK (Position BETWEEN 1 AND 20)
    );

GO

 CREATE TABLE Auction.Auction
    (
	   Id INT IDENTITY(1,1) NOT NULL,
	   ItemId INT NOT NULL,

	   StartingPrice DECIMAL(12,2) NOT NULL,
       ReservePrice DECIMAL(12,2) NULL,

	   BidIncrement DECIMAL(12,2) NOT NULL
	              CONSTRAINT DF_Auction_BidIncrement DEFAULT 50.00,

	   StartDate DATETIMEOFFSET NOT NULL,
	   EndDate DATETIMEOFFSET NOT NULL,

	   Status VARCHAR(20) NOT NULL
	              CONSTRAINT DF_Auction_Status DEFAULT 'Draft',

	   CONSTRAINT PK_Auction
	              PRIMARY KEY (Id),

	   CONSTRAINT CK_Auction_StartingPrice
	              CHECK (StartingPrice > 0),

	   CONSTRAINT CK_Auction_ReservePrice
	              CHECK (ReservePrice IS NULL OR ReservePrice >= StartingPrice),

	   CONSTRAINT CK_Auction_BidIncrement
	              CHECK (BidIncrement > 0),

	   CONSTRAINT CK_Auction_Status
	              CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled')),

	   CONSTRAINT CK_Auction_EndDate
	              CHECK (EndDate > StartDate)
    );


GO

 CREATE TABLE Auction.Bid
    (
	   Id BIGINT IDENTITY(1,1) NOT NULL,
	   AuctionId INT NOT NULL,
	   MemberId UNIQUEIDENTIFIER NOT NULL,

	   Amount DECIMAL(12,2) NOT NULL,
	   PlacedAt DATETIME2(3) NOT NULL,
	   IP VARCHAR(45) NOT NULL,

	   CONSTRAINT PK_Bid
	              PRIMARY KEY (Id),

	   CONSTRAINT CK_Bid_Amount
	              CHECK (Amount > 0),

	   CONSTRAINT UQ_Bid_AuctionId_Amount
	              UNIQUE (AuctionId, Amount)
    );


GO

 CREATE TABLE Auction.AuctionFollower
    (
	   MemberId UNIQUEIDENTIFIER NOT NULL,
	   AuctionId INT NOT NULL,
	   FollowedAt DATETIME2(3) NOT NULL,

	   CONSTRAINT PK_AuctionFollower
	              PRIMARY KEY (MemberId, AuctionId)
    );

GO

-- 3.1 Add Foreign Keys

-- Country -> City
ALTER TABLE Location.City
ADD CONSTRAINT FK_City_Country
FOREIGN KEY (CountryCode)
REFERENCES Location.Country(Code);
GO

-- City -> Member
ALTER TABLE [Identity].Member
ADD CONSTRAINT FK_Member_City
FOREIGN KEY (CityId)
REFERENCES Location.City(Id);
GO

-- Member -> Member 
ALTER TABLE [Identity].Member
ADD CONSTRAINT FK_Member_InvitedByMember
FOREIGN KEY (InvitedByMemberId)
REFERENCES [Identity].Member(Id);
GO

-- Member -> Wallet 
ALTER TABLE [Identity].Wallet
ADD CONSTRAINT FK_Wallet_Member
FOREIGN KEY (MemberId)
REFERENCES [Identity].Member(Id);
GO

-- Member -> Employee
ALTER TABLE [Identity].Employee
ADD CONSTRAINT FK_Employee_Member
FOREIGN KEY (MemberId)
REFERENCES [Identity].Member(Id);
GO

-- City -> Warehouse
ALTER TABLE Location.Warehouse
ADD CONSTRAINT FK_Warehouse_City
FOREIGN KEY (CityId)
REFERENCES Location.City(Id);
GO

-- Employee -> Warehouse
ALTER TABLE [Identity].Employee
ADD CONSTRAINT FK_Employee_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Location.Warehouse(Id);
GO

-- Warehouse Manager -> Employee
ALTER TABLE Location.Warehouse
ADD CONSTRAINT FK_Warehouse_Manager
FOREIGN KEY (ManagerId)
REFERENCES [Identity].Employee(MemberId);
GO

-- Category -> Parent Category
ALTER TABLE Catalog.Category
ADD CONSTRAINT FK_Category_ParentCategory
FOREIGN KEY (ParentCategoryCode)
REFERENCES Catalog.Category(Code);
GO

-- Category -> Item
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Category
FOREIGN KEY (CategoryCode)
REFERENCES Catalog.Category(Code);
GO

-- Member -> Item Seller
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Seller
FOREIGN KEY (SellerId)
REFERENCES [Identity].Member(Id);
GO

-- Employee -> Item Inspector
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Inspector
FOREIGN KEY (InspectorId)
REFERENCES [Identity].Employee(MemberId);
GO

-- Warehouse -> Item
ALTER TABLE Catalog.Item
ADD CONSTRAINT FK_Item_Warehouse
FOREIGN KEY (WarehouseId)
REFERENCES Location.Warehouse(Id);
GO

-- Item -> ItemPhoto 
ALTER TABLE Catalog.ItemPhoto
ADD CONSTRAINT FK_ItemPhoto_Item
FOREIGN KEY (ItemId)
REFERENCES Catalog.Item(Id)
ON DELETE CASCADE;
GO

-- Item -> Auction
ALTER TABLE Auction.Auction
ADD CONSTRAINT FK_Auction_Item
FOREIGN KEY (ItemId)
REFERENCES Catalog.Item(Id);
GO

-- Auction -> Bid
ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(Id);
GO

-- Member -> Bid
ALTER TABLE Auction.Bid
ADD CONSTRAINT FK_Bid_Member
FOREIGN KEY (MemberId)
REFERENCES [Identity].Member(Id);
GO

-- Member -> AuctionFollower
ALTER TABLE Auction.AuctionFollower
ADD CONSTRAINT FK_AuctionFollower_Member
FOREIGN KEY (MemberId)
REFERENCES [Identity].Member(Id);
GO

-- Auction -> AuctionFollower
ALTER TABLE Auction.AuctionFollower
ADD CONSTRAINT FK_AuctionFollower_Auction
FOREIGN KEY (AuctionId)
REFERENCES Auction.Auction(Id);
GO
-------------------------------------------------------------------------
ALTER TABLE [Identity].Member
ADD Language CHAR(2) NOT NULL
             CONSTRAINT DF_Member_Language DEFAULT 'ar' WITH VALUES;
GO

ALTER TABLE Catalog.Item
ADD Featured BIT NOT NULL
    CONSTRAINT DF_Item_Featured DEFAULT 0 WITH VALUES;
GO

EXEC sp_rename 'Auction.Bid.IP', 'DeviceIp', 'COLUMN';
GO

ALTER TABLE Location.Warehouse
DROP CONSTRAINT CK_Warehouse_Capacity;

GO

EXEC sp_rename 'Location.Warehouse.Capacity' , 'MaxItems', 'COLUMN';
GO

ALTER TABLE Location.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);

GO

ALTER TABLE [Identity].Member
ALTER COLUMN FULLNAME NVARCHAR(150) NOT NULL;

GO

--3.6
ALTER TABLE Location.Warehouse
DROP CONSTRAINT CK_Warehouse_MaxItems;
GO

--3.6
ALTER TABLE Location.Warehouse
ALTER COLUMN MaxItems SMALLINT NOT NULL;

GO

-- 3.6
ALTER TABLE Location.Warehouse
ADD CONSTRAINT CK_Warehouse_MaxItems
CHECK (MaxItems > 0);

GO

-- 3.7
ALTER TABLE Catalog.Category
DROP CONSTRAINT CK_Category_Commission;

GO

-- 3.7
ALTER TABLE Catalog.Category
ADD CONSTRAINT CK_Category_Commission
CHECK (Commission BETWEEN 0 AND 25);

GO

-- 3.8
ALTER TABLE Auction.Auction
DROP CONSTRAINT DF_Auction_Status;

GO

-- 3.8
ALTER TABLE Auction.Auction
DROP CONSTRAINT CK_Auction_Status;

GO

-- 3.8
ALTER TABLE Auction.Auction
ADD CONSTRAINT CK_Auction_Status
CHECK (Status IN ('Draft', 'Live', 'Ended', 'Cancelled', 'PendingReview'));

GO

-- 3.8
ALTER TABLE Auction.Auction
ADD CONSTRAINT DF_Auction_Status
DEFAULT 'PendingReview' FOR Status;

GO

-- 3.9
ALTER TABLE Auction.Auction
ADD BuyNowPrice DECIMAL(12,2) NULL;

GO

-- 3.9
ALTER TABLE Auction.Auction WITH CHECK
ADD CONSTRAINT CK_Auction_BuyNowPrice
CHECK (BuyNowPrice IS NULL OR BuyNowPrice > StartingPrice);

GO
--3.10
ALTER TABLE [Identity].Member
ADD CONSTRAINT UQ_Member_Mobile UNIQUE (Mobile);

GO
--3.11
ALTER TABLE [Identity].Member
ADD VerifiedAt DATETIME2(3) NULL;

GO
-- 3.11
ALTER TABLE [Identity].Member
DROP CONSTRAINT DF_Member_Vertified;

GO
-- 3.11
ALTER TABLE [Identity].Member
DROP COLUMN Vertified;
GO

-- 3.12
CREATE SCHEMA Marketing;
GO

-- 3.12
ALTER SCHEMA Marketing
TRANSFER Auction.AuctionFollower;
GO
----------------------------------------------------------------
ALTER TABLE [Identity].[Member]
ADD CONSTRAINT DF_Member_RegisteredAt
DEFAULT SYSDATETIME() FOR RegisteredAt;

ALTER TABLE [Identity].[Wallet]
ADD CONSTRAINT DF_Wallet_LastUpdatedAt
DEFAULT SYSDATETIME() FOR LastUpdatedAt;
GO

ALTER TABLE [Catalog].[Item]
ADD CONSTRAINT DF_Item_ListedAt
DEFAULT SYSDATETIME() FOR ListedAt;
GO

ALTER TABLE [Auction].[Bid]
ADD CONSTRAINT DF_Bid_PlacedAt
DEFAULT SYSDATETIME() FOR PlacedAt;
GO

ALTER TABLE [Marketing].[AuctionFollower]
ADD CONSTRAINT DF_AuctionFollower_FollowedAt
DEFAULT SYSDATETIME() FOR FollowedAt;
GO
------------
ALTER TABLE Location.Warehouse
NOCHECK CONSTRAINT FK_Warehouse_Manager;
GO
-----------
ALTER TABLE Location.Warehouse
WITH CHECK CHECK CONSTRAINT FK_Warehouse_Manager;
GO