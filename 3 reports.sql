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

    IF NOT EXISTS (SELECT 1 FROM dbo.Orders WHERE OrdersID = @OrderID)
        THROW 50001, 'Order does not exist.', 1;

    IF NOT EXISTS (SELECT 1 FROM dbo.OrderLine WHERE OrdersID = @OrderID)
        THROW 50002, 'Order must have at least one line item.', 1;

    IF EXISTS (
        SELECT 1
        FROM dbo.OrderLine ol
        JOIN dbo.Product p ON p.ProductID = ol.ProductID
        WHERE ol.OrdersID = @OrderID
          AND p.UnitsInStock < ol.Quantity
    )
        THROW 50003, 'Insufficient stock to confirm order.', 1;

    BEGIN TRAN;
        UPDATE p
            SET UnitsInStock = UnitsInStock - ol.Quantity
        FROM dbo.Product p
        JOIN dbo.OrderLine ol ON p.ProductID = ol.ProductID
        WHERE ol.OrdersID = @OrderID;

        UPDATE dbo.Orders
            SET Status = @TargetStatus
        WHERE OrdersID = @OrderID;
    COMMIT TRAN;
END;
GO

-- Report: Top customers by total spending this month (Shipped or Delivered)
DECLARE @ReportMonthStart DATE = DATEFROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), 1);
DECLARE @ReportMonthEnd   DATE = EOMONTH(GETDATE());

;WITH MonthlyOrders AS (
    SELECT o.OrdersID, o.CustomerID
    FROM dbo.Orders o
    WHERE o.OrderDate BETWEEN @ReportMonthStart AND @ReportMonthEnd
      AND o.Status IN ('Shipped', 'Delivered')
), LineTotals AS (
    SELECT ol.OrdersID,
           SUM(ol.Quantity) AS TotalQty,
           SUM(ol.Quantity * ol.UnitPriceAtTime * (100 - ol.DiscountPercent) / 100.0) AS LineAmount
    FROM dbo.OrderLine ol
    WHERE EXISTS (SELECT 1 FROM MonthlyOrders mo WHERE mo.OrdersID = ol.OrdersID)
    GROUP BY ol.OrdersID
), CustomerAggregates AS (
    SELECT mo.CustomerID,
           COUNT(DISTINCT mo.OrdersID) AS OrderCount,
           SUM(lt.TotalQty) AS TotalQuantity,
           SUM(lt.LineAmount) AS TotalAmount
    FROM MonthlyOrders mo
    JOIN LineTotals lt ON lt.OrdersID = mo.OrdersID
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
       COUNT(DISTINCT o.OrdersID) AS NumberOfOrders,
       SUM(ol.Quantity) AS TotalItemsSold,
       SUM(ol.Quantity * ol.UnitPriceAtTime * (100 - ol.DiscountPercent) / 100.0) AS TotalRevenue
FROM dbo.Orders o
JOIN dbo.OrderLine ol ON o.OrdersID = ol.OrdersID
WHERE o.Status IN ('Pending', 'Shipped', 'Delivered')
GROUP BY o.OrderDate
ORDER BY o.OrderDate;
GO
