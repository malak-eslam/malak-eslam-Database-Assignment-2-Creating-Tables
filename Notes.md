Note --> Problem
Both approaches have O(n) time complexity.

- Approach 1: Uses prefix and suffix arrays so its space complexity is O(n).
- Approach 2: Uses the output array and two variables so its extra space complexity is O(1).

The second approach uses less memory but both approaches take the same time.

--------------------------
# BidNile Database Notes

## 1. Schemas and Tables

I divided the database into four schemas based on the purpose of each group:

- Identity: Member, Wallet, Employee — stores member accounts, wallets, and employee information.
- Location: Country, City, Warehouse — stores geographical and warehouse information.
- Catalog: Category, Item, ItemPhoto — stores the products listed for auction and their details.
- Auction: Auction, Bid, AuctionFollower — stores auctions, bids, and followers.

In Task 3.12, I created the Marketing schema and moved AuctionFollower into it because it belongs to marketing and engagement activities.

## 2. Relationships

I used different relationship types to represent the business rules:

- One-to-One (1:1):Member and Wallet. 
           Each member has one wallet and each wallet belongs to one member.
           I used MemberId as the Wallet primary key and foreign key.

- One-to-Many (1:N):
  - Country → City: one country has many cities.
  - City → Member: one city can have many members.
  - City → Warehouse: one city can have many warehouses.
  - Member → Item: one member can sell many items.
  - Category → Item: one category can contain many items.
  - Employee → Item: one employee can inspect many items.
  - Warehouse → Item: one warehouse can store many items.
  - Item → ItemPhoto: one item can have many photos.
  - Item → Auction: one item can have multiple auctions over time.
  - Auction → Bid: one auction can receive many bids.
  - Member → Bid: one member can place many bids.
  - Warehouse → Employee: one warehouse can have many employees.


  - Many-to-Many (M:N):
  - Member and Auction through Bid: members can bid on many auctions
     and auctions can receive bids from many members.
  - Member and Auction through AuctionFollower: members can follow many auctions
     and auctions can have many followers. I used a composite primary key to prevent following the same auction twice.


- Recursive: 
  - Member invites another Member through InvitedByMemberId.
  - Category can have a parent category through ParentCategoryCode.

  - Circular: 
        Warehouse and Employee reference each other. 
        Employee has WarehouseId while Warehouse has ManagerId referencing an employee.

  - Weak Entity: 
         ItemPhoto depends on Item and cannot exist independently. Its composite primary key is ItemId and Position. Deleting an item also deletes its photos.

## 3. Data Types

I chose the data types according to the business requirements:

- UNIQUEIDENTIFIER (GUID): For Member IDs because the mobile app can generate a unique ID before sending data to the server.
- BIGINT: For Bid IDs because the system expects hundreds of millions of bids, which may exceed the INT limit.
- FLOAT: For Latitude and Longitude because GPS coordinates can contain decimal values.
- DECIMAL: For prices, balances, and other financial values because money needs accurate decimal precision.
- DATETIMEOFFSET: For auction start and end dates because members use different time zones, and the offset must be preserved.
- NVARCHAR: For names and text that may contain Arabic or English characters.
- NVARCHAR(MAX) with ISJSON: For item specifications because different categories can have different properties stored as JSON.

## 4. Circular Relationship

I could not create both foreign keys inside the two CREATE TABLE statements because each table references the other.

I created both tables first, then added the foreign keys using ALTER TABLE after both tables existed.

## 5. Data Insertion Order

I started with the tables that do not depend on other tables, then inserted the dependent data:

Country → City → Member → Wallet → Warehouse → Employee → Category → Item → ItemPhoto → Auction → Bid → AuctionFollower.

For example City needs Country, Member needs City, and Item needs its seller, inspector, category, and warehouse.

Warehouse and Employee have a circular relationship so their manager and warehouse references needed special handling.

## 6. Errors in Task 3

- Task 3.6: Changing MaxItems to SMALLINT failed because the existing CHECK constraint depended on the column. I handled the constraint, changed the data type, and recreated the CHECK constraint to ensure MaxItems stays greater than zero.
- Task 3.11: Dropping the old Verified column failed because a DEFAULT constraint was attached to it. I dropped the default constraint first, then dropped the column