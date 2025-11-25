/*
    Sunrise Stationery T-SQL implementation (simplified schema naming)
    - Creates core tables with business rule constraints
    - Inserts sample data
    - Provides helper procedure for confirming orders with stock validation
    - Supplies example report queries
*/

-- Recreate database
DROP DATABASE IF EXISTS SunriseStationery;
GO
CREATE DATABASE SunriseStationery;
GO
USE SunriseStationery;
GO

-- Clean up for repeatable runs
DROP TABLE IF EXISTS dbo.OrderLine;
DROP TABLE IF EXISTS dbo.[Order];
DROP TABLE IF EXISTS dbo.Product;
DROP TABLE IF EXISTS dbo.Customer;
GO

-- Customer
CREATE TABLE dbo.Customer
(
    CustomerID      INT             NOT NULL IDENTITY PRIMARY KEY,
    FirstName       VARCHAR(50)     NOT NULL,
    LastName        VARCHAR(50)     NOT NULL,
    Email           VARCHAR(255)    NOT NULL CONSTRAINT u_Customer_Email UNIQUE,
    City            VARCHAR(100)    NOT NULL,
    CustomerType    VARCHAR(20)     NOT NULL,
    CONSTRAINT c_Customer_Email_Format CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT c_Customer_Type CHECK (CustomerType IN ('School', 'Home Office', 'Freelancer', 'Other'))
);
GO

-- Product
CREATE TABLE dbo.Product
(
    ProductID       INT             NOT NULL IDENTITY PRIMARY KEY,
    ProductName     VARCHAR(100)    NOT NULL,
    Category        VARCHAR(30)     NOT NULL,
    UnitPrice       DECIMAL(10,2)   NOT NULL,
    UnitsInStock    INT             NOT NULL,
    ReorderLevel    INT             NOT NULL,
    NeedsRestock AS (CASE WHEN UnitsInStock <= ReorderLevel THEN 1 ELSE 0 END) PERSISTED,
    CONSTRAINT c_Product_Category CHECK (Category IN ('Notebooks', 'Pens', 'Markers', 'Desk Accessory', 'Other')),
    CONSTRAINT c_Product_UnitPrice CHECK (UnitPrice > 0),
    CONSTRAINT c_Product_Stock CHECK (UnitsInStock >= 0 AND ReorderLevel >= 0)
);
GO

-- Order
CREATE TABLE dbo.[Order]
(
    OrderID         INT             NOT NULL IDENTITY PRIMARY KEY,
    CustomerID      INT             NOT NULL CONSTRAINT FK_Order_Customer FOREIGN KEY REFERENCES Customer (CustomerID),
    OrderDate       DATE            NOT NULL,
    Status          VARCHAR(20)     NOT NULL,
    ShippingCity    VARCHAR(100)    NOT NULL,
    CONSTRAINT c_Order_Status CHECK (Status IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);
GO

-- Order line items
CREATE TABLE dbo.OrderLine
(
    OrderLineID         INT             NOT NULL IDENTITY PRIMARY KEY,
    OrderID             INT             NOT NULL CONSTRAINT FK_OrderLine_Order FOREIGN KEY REFERENCES [Order] (OrderID),
    ProductID           INT             NOT NULL CONSTRAINT FK_OrderLine_Product FOREIGN KEY REFERENCES Product (ProductID),
    LineNo              INT             NOT NULL,
    Quantity            INT             NOT NULL,
    UnitPriceAtTime     DECIMAL(10,2)   NOT NULL,
    DiscountPercent     DECIMAL(5,2)    NOT NULL CONSTRAINT DF_OrderLine_Discount DEFAULT 0,
    CONSTRAINT u_OrderLine_Line UNIQUE (OrderID, LineNo),
    CONSTRAINT c_OrderLine_Quantity CHECK (Quantity >= 1),
    CONSTRAINT c_OrderLine_Price CHECK (UnitPriceAtTime > 0),
    CONSTRAINT c_OrderLine_Discount CHECK (DiscountPercent BETWEEN 0 AND 100)
);
GO

-- Sample data: Customer
SET IDENTITY_INSERT dbo.Customer ON;
INSERT INTO dbo.Customer (CustomerID, FirstName, LastName, Email, City, CustomerType)
VALUES
(1, 'Sarah', 'Cohen', 'sarah.cohen@example.com', 'Jerusalem', 'School'),
(2, 'David', 'Levi', 'david.levi@example.com', 'Tel Aviv', 'Home Office'),
(3, 'Rachel', 'Ben Ami', 'rachel.ba@example.com', 'Haifa', 'School'),
(4, 'Noam', 'Adler', 'noam.adler@example.com', 'Be''er Sheva', 'Freelancer'),
(5, 'Maya', 'Katz', 'maya.katz@example.com', 'Jerusalem', 'Home Office');
SET IDENTITY_INSERT dbo.Customer OFF;
GO

-- Sample data: Product
SET IDENTITY_INSERT dbo.Product ON;
INSERT INTO dbo.Product (ProductID, ProductName, Category, UnitPrice, UnitsInStock, ReorderLevel)
VALUES
(1, 'A5 Lined Notebook', 'Notebooks', 12.00, 150, 50),
(2, 'Blue Gel Pen (Pack 10)', 'Pens', 18.00, 80, 30),
(3, 'Highlighter Set (4)', 'Markers', 24.00, 40, 20),
(4, 'Desk Organizer Tray', 'Desk Accessory', 45.00, 25, 10),
(5, 'A4 Graph Paper Pad', 'Notebooks', 15.00, 60, 25);
SET IDENTITY_INSERT dbo.Product OFF;
GO

-- Sample data: Order
SET IDENTITY_INSERT dbo.[Order] ON;
INSERT INTO dbo.[Order] (OrderID, CustomerID, OrderDate, Status, ShippingCity)
VALUES
(1001, 1, '2025-01-10', 'Shipped', 'Jerusalem'),
(1002, 2, '2025-01-11', 'Delivered', 'Tel Aviv'),
(1003, 1, '2025-01-15', 'Delivered', 'Jerusalem'),
(1004, 3, '2025-01-16', 'Pending', 'Haifa'),
(1005, 5, '2025-01-17', 'Shipped', 'Jerusalem');
SET IDENTITY_INSERT dbo.[Order] OFF;
GO

-- Sample data: Order line items
SET IDENTITY_INSERT dbo.OrderLine ON;
INSERT INTO dbo.OrderLine (OrderLineID, OrderID, ProductID, LineNo, Quantity, UnitPriceAtTime, DiscountPercent)
VALUES
(1, 1001, 1, 1, 30, 12.00, 0),
(2, 1001, 2, 2, 10, 18.00, 5),
(3, 1002, 4, 1, 2, 45.00, 0),
(4, 1002, 3, 2, 3, 24.00, 0),
(5, 1003, 1, 1, 20, 12.00, 10),
(6, 1003, 5, 2, 15, 15.00, 0),
(7, 1004, 2, 1, 20, 18.00, 5),
(8, 1005, 3, 1, 5, 24.00, 0),
(9, 1005, 4, 2, 1, 45.00, 0);
SET IDENTITY_INSERT dbo.OrderLine OFF;
GO

-- Procedure: confirm order with stock validation and status update
CREATE OR ALTER PROCEDURE dbo.usp_ConfirmOrder
    @OrderID INT,
    @TargetStatus VARCHAR(20) = 'Shipped'
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    IF @TargetStatus NOT IN ('Shipped', 'Delivered')
        THROW 50000, 'Target status must be Shipped or Delivered.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.[Order] WHERE OrderID = @OrderID)
        THROW 50001, 'Order does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.OrderLine WHERE OrderID = @OrderID)
        THROW 50002, 'Order must have at least one line item.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.OrderLine ol
        JOIN dbo.Product p ON p.ProductID = ol.ProductID
        WHERE ol.OrderID = @OrderID
          AND p.UnitsInStock < ol.Quantity
    )
        THROW 50003, 'Insufficient stock to confirm order.', 1;

    BEGIN TRAN;
        UPDATE p
            SET UnitsInStock = UnitsInStock - ol.Quantity
        FROM dbo.Product p
        JOIN dbo.OrderLine ol ON p.ProductID = ol.ProductID
        WHERE ol.OrderID = @OrderID;

        UPDATE dbo.[Order]
            SET Status = @TargetStatus
        WHERE OrderID = @OrderID;
    COMMIT TRAN;
END;
GO

-- Report: Top customers by total spending this month (Shipped or Delivered)
DECLARE @ReportMonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @ReportMonthEnd   DATE = EOMONTH(GETDATE());

;WITH MonthlyOrders AS (
    SELECT o.OrderID, o.CustomerID
    FROM dbo.[Order] o
    WHERE o.OrderDate BETWEEN @ReportMonthStart AND @ReportMonthEnd
      AND o.Status IN ('Shipped', 'Delivered')
), LineTotals AS (
    SELECT ol.OrderID,
           SUM(ol.Quantity) AS TotalQty,
           SUM(ol.Quantity * ol.UnitPriceAtTime * (100 - ol.DiscountPercent) / 100.0) AS LineAmount
    FROM dbo.OrderLine ol
    WHERE EXISTS (SELECT 1 FROM MonthlyOrders mo WHERE mo.OrderID = ol.OrderID)
    GROUP BY ol.OrderID
), CustomerAggregates AS (
    SELECT mo.CustomerID,
           COUNT(DISTINCT mo.OrderID) AS OrderCount,
           SUM(lt.TotalQty) AS TotalQuantity,
           SUM(lt.LineAmount) AS TotalAmount
    FROM MonthlyOrders mo
    JOIN LineTotals lt ON lt.OrderID = mo.OrderID
    GROUP BY mo.CustomerID
)
SELECT ROW_NUMBER() OVER (ORDER BY ca.TotalAmount DESC) AS Rank,
       CONCAT(c.FirstName, ' ', c.LastName) AS CustomerName,
       c.CustomerType,
       ca.OrderCount AS NumberOfOrders,
       ca.TotalQuantity AS TotalQuantityOrdered,
       ca.TotalAmount AS TotalAmountSpent
FROM CustomerAggregates ca
JOIN dbo.Customer c ON c.CustomerID = ca.CustomerID
ORDER BY Rank;
GO

-- Report: Products that need restocking
SELECT ProductID,
       ProductName,
       Category,
       UnitsInStock,
       ReorderLevel,
       CASE WHEN NeedsRestock = 1 THEN 'Yes' ELSE 'No' END AS NeedsRestock
FROM dbo.Product
WHERE NeedsRestock = 1
ORDER BY ProductID;
GO

-- Report: Daily sales summary
SELECT o.OrderDate AS [Date],
       COUNT(DISTINCT o.OrderID) AS NumberOfOrders,
       SUM(ol.Quantity) AS TotalItemsSold,
       SUM(ol.Quantity * ol.UnitPriceAtTime * (100 - ol.DiscountPercent) / 100.0) AS TotalRevenue
FROM dbo.[Order] o
JOIN dbo.OrderLine ol ON o.OrderID = ol.OrderID
WHERE o.Status IN ('Pending', 'Shipped', 'Delivered')
GROUP BY o.OrderDate
ORDER BY o.OrderDate;
GO
