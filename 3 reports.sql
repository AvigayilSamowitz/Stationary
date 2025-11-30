use Stationery
go

-- Report: Top customers by total spending in January (Shipped or Delivered)
select top(2) c.FirstName, c.LastName, TotalSpendingJan = sum(ol.UnitPriceAtTime * ol.Quantity * (100 - ol.DiscountPercent) / 100)
from Customer c
join Orders o
on o.CustomerID = c.CustomerID
join OrderLine ol
on ol.OrdersID = o.OrdersID
where o.OrderStatus in ('shipped', 'delivered')
and o.OrderDate between '2025-1-1' and '2025-1-31'
group by c.FirstName, c.LastName
order by TotalSpendingJan desc

-- Report: Products that need restocking
SELECT *
FROM Product p
WHERE p.NeedsRestock = 1

-- Report: Daily sales summary
SELECT Date = o.OrderDate,
       NumOrders = COUNT(DISTINCT o.OrdersID),
       TotalItemsSold = SUM(ol.Quantity),
       TotalRevenue = SUM(ol.Quantity * ol.UnitPriceAtTime * (100 - ol.DiscountPercent) / 100.0)
FROM Orders o
JOIN OrderLine ol ON o.OrdersID = ol.OrdersID
WHERE o.OrderStatus IN ('Pending', 'Shipped', 'Delivered')
GROUP BY o.OrderDate
ORDER BY o.OrderDate;
GO