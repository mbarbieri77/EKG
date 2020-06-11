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
    p.ProductName,
    p.UnitPrice,
    s.SupplierID,
    s.Region,
    s.Country    
FROM 
    Product as p 
    INNER JOIN Supplier as s 
    ON p.SupplierID = s.SupplierID
WHERE
    (
      ProductName Like 'T%'
      OR ProductID = 46

    )
    AND UnitPrice > 16

-- Top 5 largest orders in number of products shipped in the USA
USE Northwind;
SELECT TOP (5)
  rd.OrderID as OrderID, 
  Count(od.ProductID) as ProductCount
FROM 
  [Order] AS rd
  INNER JOIN OrderDetail AS od
  ON rd.orderid = od.orderid
WHERE
  rd.ShipCountry = 'USA'
GROUP BY
  rd.orderid
ORDER BY 
  ProductCount DESC, 
  OrderID 


-- Customers who bought product-1 also bought which products? Not necessarily in the same order. 
SELECT DISTINCT 
  t1.ProductID AS ProductA, 
  t2.ProductID AS ProductB,
  COUNT(t2.ProductID) OVER (PARTITION BY  t2.ProductID) AS ProductBCount
FROM 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t1 
INNER JOIN 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t2 
ON 
  /*t1.OrderID = t2.OrderID AND*/ t1.CustomerID = t2.CustomerID AND t1.ProductID <> t2.ProductID
WHERE
    t1.ProductID = 61 
ORDER BY 
    ProductBCount DESC, ProductA, ProductB



-- Products frequently bought together in the same order. 
SELECT 
  t1.ProductID AS ProductA, 
  t2.ProductID AS ProductB,
  COUNT(t1.OrderID) AS OrderCount
FROM 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t1 
INNER JOIN 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t2 
ON  
  t1.OrderID = t2.OrderID AND t1.CustomerID = t2.CustomerID AND t1.ProductID <> t2.ProductID 
WHERE
  t1.ProductID = 61 
GROUP BY 
  t1.ProductID,
  t2.ProductID
ORDER BY 
  OrderCount DESC, ProductA, ProductB



-- List of Products Bought together in the same order
SELECT 
  t1.ProductID AS ProductA, 
  t1.OrderID,
  t1.CustomerID,
  t2.ProductID AS ProductB
FROM 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t1 
INNER JOIN 
  (
    SELECT p.ProductID, cst.CustomerID, ord.OrderID
    FROM Customer AS cst
    INNER JOIN [Order] AS ord ON cst.CustomerID = ord.CustomerID
    INNER JOIN OrderDetail AS odd ON ord.OrderID = odd.OrderID
    INNER JOIN Product AS p ON p.ProductID = odd.ProductID
  ) AS t2 
ON  
  /*t1.OrderID = t2.OrderID AND*/ t1.CustomerID = t2.CustomerID AND t1.ProductID <> t2.ProductID -- <> because we want to keep the mirroring records. 
WHERE
  (t1.ProductID = 61 AND t2.ProductID = 21) OR (t1.ProductID = 21 AND t2.ProductID = 61)
ORDER BY
  t1.ProductID

