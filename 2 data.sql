use stationery 
go

delete OrderLine
delete Orders
delete Product
delete Customer
go
-- Sample data: Customer
INSERT Customer(FirstName, LastName, Email, City, CustomerType)
Select 'Sarah', 'Cohen', 'sarah.cohen@example.com', 'Jerusalem', 'School'
union Select 'David', 'Levi', 'david.levi@example.com', 'Tel Aviv', 'Home Office'
union Select 'Rachel', 'Ben Ami', 'rachel.ba@example.com', 'Haifa', 'School'
union Select 'Noam', 'Adler', 'noam.adler@example.com', 'Be''er Sheva', 'Freelancer'
union Select 'Maya', 'Katz', 'maya.katz@example.com', 'Jerusalem', 'Home Office'
GO

-- Sample data: Product
INSERT Product(ProductName, Category, UnitPrice, UnitsInStock, ReorderLevel)
select 'A5 Lined Notebook', 'Notebooks', 12.00, 150, 50
union select 'Blue Gel Pen (Pack 10)', 'Pens', 18.00, 80, 30
union select 'Highlighter Set (4)', 'Markers', 24.00, 40, 20
union select 'Desk Organizer Tray', 'Desk Accessory', 45.00, 25, 10
union select 'A4 Graph Paper Pad', 'Notebooks', 15.00, 60, 25
GO

-- Sample data: Order
;
with x as(
select FirstName = 'Sarah', OrderDate = '2025-01-10', OrderStatus = 'Shipped', ShippingCity = 'Jerusalem'
union select 'David', '2025-01-11', 'Delivered', 'Tel Aviv'
union select 'Sarah', '2025-01-15', 'Delivered', 'Jerusalem'
union select 'Rachel', '2025-01-16', 'Pending', 'Haifa'
union select 'Maya', '2025-01-17', 'Shipped', 'Jerusalem'
)
Insert Orders(CustomerID, OrderDate, OrderStatus, ShippingCity)
select c.CustomerID, x.OrderDate, x.OrderStatus, x.ShippingCity
from x
join customer c
on x.FirstName = c.FirstName
GO

-- Sample data: Order line items
;
with x as(
select CustomerName = 'Sarah' , OrderDate = '2025-01-10', ProductName = 'A5 Lined Notebook', LineNum = 1, Quantity = 30, UnitPriceAtTime = 12.00, DiscountPercent = 0
union select 'Sarah', '2025-01-10', 'Blue Gel Pen (Pack 10)', 2, 10, 18.00, 5
union select 'David', '2025-01-11', 'Desk Organizer Tray', 1, 2, 45.00, 0
union select 'David', '2025-01-11', 'Highlighter Set (4)', 2, 3, 24.00, 0
union select 'Rachel', '2025-01-16', 'A5 Lined Notebook', 1, 20, 12.00, 10
union select 'Rachel', '2025-01-16', 'A4 Graph Paper Pad', 2, 15, 15.00, 0
union select 'Sarah', '2025-01-15', 'Blue Gel Pen (Pack 10)', 1, 20, 18.00, 5
union select 'Maya', '2025-01-17', 'Highlighter Set (4)', 1, 5, 24.00, 0
union select 'Maya', '2025-01-17', 'Desk Organizer Tray', 2, 1, 45.00, 0
)
INSERT OrderLine (OrdersID, ProductID, LineNum, Quantity, UnitPriceAtTime, DiscountPercent)
select o.OrdersID, p.ProductID, x.LineNum, x.Quantity, x.UnitPriceAtTime, x.DiscountPercent
from x
join customer c
on x.CustomerName = c.FirstName
join orders o 
on o.customerID = c.customerID
and o.orderdate = x.OrderDate
join product p
on x.ProductName = p.productname

