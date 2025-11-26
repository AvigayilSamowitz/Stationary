
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
SET IDENTITY_INSERT dbo.Orders ON;
INSERT INTO dbo.Orders (OrdersID, CustomerID, OrderDate, Status, ShippingCity)
VALUES
(1001, 1, '2025-01-10', 'Shipped', 'Jerusalem'),
(1002, 2, '2025-01-11', 'Delivered', 'Tel Aviv'),
(1003, 1, '2025-01-15', 'Delivered', 'Jerusalem'),
(1004, 3, '2025-01-16', 'Pending', 'Haifa'),
(1005, 5, '2025-01-17', 'Shipped', 'Jerusalem');
SET IDENTITY_INSERT dbo.Orders OFF;
GO

-- Sample data: Order line items
SET IDENTITY_INSERT dbo.OrderLine ON;
INSERT INTO dbo.OrderLine (OrderLineID, OrdersID, ProductID, LineNum, Quantity, UnitPriceAtTime, DiscountPercent)
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
