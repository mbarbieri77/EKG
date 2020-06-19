/*
    Name: Basic Select
    Description: Basic Select with specified columns
    ---------------------------------------------------
    Author              Date            Description
    Marcelo Barbieri    26-May-2020     Initial Version
*/

-- Query 1: Basic select with specified columns
SELECT
    EmployeeID,
    LastName,
    FirstName,
    Title
FROM
    Employee
    

-- Query 2: Any employees in the USA? (returns true or false)
IF EXISTS
(
SELECT 
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'
)
PRINT 'True'
ELSE
PRINT 'False'


-- Query 3: Basic select with string match filter
SELECT 
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'


-- Query 4: The same filter can be applied as follows
SELECT 
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'


-- Query 5: Character string match (Regex)
SELECT 
    CompanyName,
    ContactName,
    [Address],
    City,
    Phone
FROM 
    Customer
WHERE 
    CompanyName LIKE '%REST%'


-- Query 6: Logical Operators, Join and simple type conversion. 
SELECT
    --p.ProductID,
    prd.ProductName,
    prd.UnitPrice,
    spl.SupplierID,
    spl.Region,
    spl.Country    
FROM 
    Product as prd 
    INNER JOIN Supplier as spl 
    ON prd.SupplierID = spl.SupplierID
WHERE
    (
      ProductName Like 'T%'
      OR ProductID = 46

    )
    AND UnitPrice > 16


-- Query 7: Data ranges
SELECT 
    prd.ProductID,
    prd.ProductName,
    spl.SupplierID,
    spl.CompanyName,
    prd.UnitPrice
FROM 
    Product as prd 
    INNER JOIN Supplier as spl 
    ON prd.SupplierID = spl.SupplierID
WHERE
    prd.UnitPrice BETWEEN 18 AND 20 

-- Query 8: Filtering on list of values
SELECT
    CompanyName,
    Country
FROM 
    Supplier
WHERE
    Country IN ('JAPAN', 'Italy') 

-- Query 9: Working with Nulls (next 3 examples)
SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NOT NULL  -- only suppliers with fax



SELECT
    CompanyName,
    Fax
FROM
    Supplier -- suppliers with fax and without fax



SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NULL  -- only suppliers without fax


-- Query 10: Sorting data
SELECT
    prd.ProductID,
    prd.ProductName,
    prd.UnitPrice,
    ctg.CategoryName
FROM 
    Product as prd
    INNER JOIN Category as ctg
    ON prd.CategoryID = ctg.CategoryID
ORDER BY 
    CategoryName,
    UnitPrice DESC


-- Query 11: Eliminating duplicates
SELECT DISTINCT 
    Country
FROM 
    Supplier
ORDER BY 
    Country


-- Query 12: Column alias and string manipulation
SELECT
    EmployeeID AS ID,
    CONCAT (SUBSTRING(FirstName,1,1), SUBSTRING(LastName,1,3)) AS Code,
    FirstName,
    LastName  
FROM
    Employee


-- Query 13: Limiting results - joining product and order.
-- Largest orders of a single product
SELECT TOP (5)
    odd.OrderID,
    prd.ProductID,
    odd.Quantity
FROM
    OrderDetail AS odd 
    INNER JOIN Product AS prd
    ON odd.ProductID = prd.ProductID
ORDER BY 
    Quantity DESC


-- Query 14: Counting
SELECT
    COUNT(Country) AS countryCount
FROM 
    Supplier


-- Query 15: Distinct Count
SELECT 
    COUNT(DISTINCT Country) AS countryCount
FROM 
    Supplier


-- Query 16: Grouping and Aggregations
-- Top 10 most sold products
SELECT TOP 10
    prd.ProductID,
    SUM(odd.Quantity) AS TotalQty
FROM
    OrderDetail AS odd 
    INNER JOIN Product AS prd
    ON odd.ProductID = prd.ProductID
GROUP BY 
    prd.ProductID
ORDER BY 
    TotalQty DESC


-- Query 17: Who bought product A also bought which products? 
-- Step by step evolution of the query
SELECT
    ord.OrderID,
    odd.ProductID,
    ord.CustomerID
FROM
  OrderDetail AS odd
  INNER JOIN [Order] AS ord
  ON odd.OrderID = ord.OrderID


SELECT
    odd.ProductID,
    ord.OrderID,
    ord.CustomerID
FROM
  OrderDetail AS odd
  INNER JOIN [Order] AS ord
  ON odd.OrderID = ord.OrderID


SELECT
    odd.ProductID,
    ord.OrderID,
    ord.CustomerID
FROM
  OrderDetail AS odd
  INNER JOIN [Order] AS ord
  ON odd.OrderID = ord.OrderID


SELECT DISTINCT 
    odd.ProductID,
    ord.CustomerID
FROM
  OrderDetail AS odd
  INNER JOIN [Order] AS ord
  ON odd.OrderID = ord.OrderID


-- Query 18: Products frequently bought together in the same order. 
SELECT TOP 5
  t1.ProductID AS ProductA, 
  t2.ProductID AS ProductB,
  COUNT(t1.OrderID) AS OrderCount
FROM 
  (
    SELECT prd.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS prd ON prd.ProductID = odd.ProductID
  ) AS t1 
INNER JOIN 
  (
    SELECT prd.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS prd ON prd.ProductID = odd.ProductID
  ) AS t2 
ON  
  t1.OrderID = t2.OrderID -- Same Order
  AND t1.ProductID <> t2.ProductID 
WHERE
  t1.ProductID = 61 -- Testing
GROUP BY 
  t1.ProductID,
  t2.ProductID
ORDER BY 
  OrderCount DESC, ProductA, ProductB


-- Query 19: Customers who bought product-61 also bought which products across all orders?
SELECT DISTINCT TOP 5
  t1.ProductID AS ProductA, 
  t2.ProductID AS ProductB,
  COUNT(t2.ProductID) OVER (PARTITION BY  t2.ProductID) AS ProductBCount
FROM 
  (
    SELECT prd.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS prd ON prd.ProductID = odd.ProductID
  ) AS t1 
INNER JOIN 
  (
    SELECT prd.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS prd ON prd.ProductID = odd.ProductID
  ) AS t2 
ON 
  t1.CustomerID = t2.CustomerID -- Same Customer
  AND t1.ProductID <> t2.ProductID
WHERE
    t1.ProductID = 61 
ORDER BY 
    ProductBCount DESC, ProductA, ProductB











  
-- Top 5 largest orders in number of products shipped in the USA
USE Northwind;
SELECT TOP (5)
  ord.OrderID as OrderID, 
  Count(odd.ProductID) as ProductCount
FROM 
  [Order] AS ord
  INNER JOIN OrderDetail AS odd
  ON ord.orderid = odd.orderid
WHERE
  ord.ShipCountry = 'USA'
GROUP BY
  ord.orderid
ORDER BY 
  ProductCount DESC, 
  OrderID 




 -- For example, the following query returns the two most recent orders (assuming for the sake of this example that orderid represents chronological order) for each customer, generating the output shown in Table 1-13:
SELECT 
    cst.CustomerID, 
    cst.City,
    OrderID, 
    OrderDate   
FROM Customer AS cst
CROSS APPLY
(SELECT TOP(2) ord.OrderID, ord.OrderDate, cst.CustomerID
FROM [Order] AS ord
WHERE ord.customerid = cst.customerid ORDER BY OrderDate DESC) AS cpp;





--This query returns customer categories based on count of orders (no orders, up to two orders, more than two orders)
SELECT 
    cst.CustomerID, 
    cst.City,
CASE
WHEN COUNT(ord.OrderID) = 0 THEN 'No_Orders'
WHEN COUNT(ord.OrderID) <= 2 THEN 'Upto_Two_Orders'
WHEN COUNT(ord.OrderID) > 2 THEN 'More_Than_Two_Orders'
END AS 
    Category
FROM 
    Customer AS cst
    LEFT OUTER JOIN [Order] AS ord 
    ON cst.CustomerID = ord.CustomerID
GROUP BY 
    cst.CustomerID,cst.City;



-- Suppose you wanted to know the number of customers that fall into each category per city. The following PIVOT query allows you to achieve this, generating the output shown in Table 1-16:
SELECT 
    City, 
    No_Orders,
    Upto_Two_Orders, 
    More_Than_Two_Orders 
FROM 
    (SELECT 
        cst.CustomerID, 
        cst.City,
        CASE
        WHEN COUNT(ord.OrderID) = 0 THEN 'No_Orders'
        WHEN COUNT(ord.OrderID) <= 2 THEN 'Upto_Two_Orders'
        WHEN COUNT(ord.OrderID) > 2 THEN 'More_Than_Two_Orders'
        END AS Category
    FROM 
        Customer AS cst
        LEFT OUTER JOIN [Order] AS ord 
        ON cst.CustomerID = ord.CustomerID
    GROUP BY 
        cst.CustomerID, 
        cst.City) AS D PIVOT(COUNT(CustomerID) FOR Category 
        IN([No_Orders],
          [Upto_Two_Orders],
          [More_Than_Two_Orders])) AS pvt;









