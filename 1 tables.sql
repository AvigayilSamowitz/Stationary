use Stationery
go

-- Clean up for repeatable runs
DROP TABLE IF EXISTS dbo.OrderLine;
DROP TABLE IF EXISTS dbo.Orders;
DROP TABLE IF EXISTS dbo.Product;
DROP TABLE IF EXISTS dbo.Customer;
GO

-- Customer
CREATE TABLE dbo.Customer
(
    CustomerID      INT             NOT NULL IDENTITY PRIMARY KEY,
    FirstName       VARCHAR(35)     NOT NULL,
    LastName        VARCHAR(45)     NOT NULL,
    Email           VARCHAR(100)    NOT NULL CONSTRAINT u_Customer_Email UNIQUE,
    City            VARCHAR(50)    NOT NULL,
    CustomerType    VARCHAR(20)     NOT NULL,
    CONSTRAINT c_Customer_Email_Format CHECK (Email LIKE '%_@_%._%'),
    CONSTRAINT c_Customer_Type_must_be_school_Home_office_freelancer_or_other CHECK (CustomerType IN ('School', 'Home Office', 'Freelancer', 'Other'))
);
GO

-- Product
CREATE TABLE dbo.Product
(
    ProductID       INT             NOT NULL IDENTITY PRIMARY KEY,
    ProductName     VARCHAR(100)    NOT NULL,
    Category        VARCHAR(14)     NOT NULL,
    UnitPrice       DECIMAL(10,2)   NOT NULL,
    UnitsInStock    INT             NOT NULL,
    ReorderLevel    INT             NOT NULL,
    NeedsRestock AS (CASE WHEN UnitsInStock <= ReorderLevel THEN 1 ELSE 0 END) PERSISTED,
    CONSTRAINT c_Product_Category_must_be_notebooks_pens_markers_deskAccessory_or_other CHECK (Category IN ('Notebooks', 'Pens', 'Markers', 'Desk Accessory', 'Other')),
    CONSTRAINT c_Product_UnitPrice_must_be_greater_than_0 CHECK (UnitPrice > 0),
    CONSTRAINT c_Product_UnitsInStock_and_ReorderLevel_cannot_be_less_than_0 CHECK (UnitsInStock >= 0 AND ReorderLevel >= 0)
);
GO

-- Order
CREATE TABLE dbo.Orders
(
    OrdersID         INT             NOT NULL IDENTITY PRIMARY KEY,
    CustomerID      INT             NOT NULL CONSTRAINT FK_Order_Customer FOREIGN KEY REFERENCES Customer (CustomerID),
    OrderDate       DATE            NOT NULL,
    OrderStatus          VARCHAR(9)     NOT NULL,
    ShippingCity    VARCHAR(50)    NOT NULL,
    CONSTRAINT c_Order_OrderStatus_must_be_pending_shipped_delivered_or_cancelled CHECK (OrderStatus IN ('Pending', 'Shipped', 'Delivered', 'Cancelled'))
);
GO

-- Order line items
CREATE TABLE dbo.OrderLine
(
    OrderLineID         INT             NOT NULL IDENTITY PRIMARY KEY,
    OrdersID             INT             NOT NULL CONSTRAINT FK_OrderLine_Order FOREIGN KEY REFERENCES Orders (OrdersID),
    ProductID           INT             NOT NULL CONSTRAINT FK_OrderLine_Product FOREIGN KEY REFERENCES Product (ProductID),
    LineNum              INT             NOT NULL,
    Quantity            INT             NOT NULL,
    UnitPriceAtTime     DECIMAL(10,2)   NOT NULL,
    DiscountPercent     int              NOT NULL DEFAULT(0),
    CONSTRAINT u_OrderLine_OrdersID_LineNum UNIQUE (OrdersID, LineNum),
    CONSTRAINT c_OrderLine_Quantity_cannot_be_less_than_1 CHECK (Quantity >= 1),
    CONSTRAINT c_OrderLine_UnitPriceAtTime_must_be_greater_than_0 CHECK (UnitPriceAtTime > 0),
    CONSTRAINT c_OrderLine_DiscountPercent_must_be_between_0_and_100 CHECK (DiscountPercent BETWEEN 0 AND 100)
);
GO