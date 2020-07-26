
-- Basic select with specified columns
-- Query 1: Employee List 
SELECT
    EmployeeID,
    Title
    LastName,
    FirstName

FROM
    Employee
    

-- Filtering Data
-- Query 2: List of Employees in the USA
SELECT 
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'


-- Query 3: Do I have any employees in the USA?   
IF EXISTS
(
    SELECT 1
    FROM 
        Employee
    WHERE 
        Country = 'USA'
)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'


-- Character search pattern (Regex)
-- Query 4: Companies that contain the word "rest" in their names.
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


-- Joins
-- Query 5: Selecting details of products supplied in the USA
SELECT 
    prd.productID,
    prd.productName, 
    prd.unitsInStock, 
    prd.unitPrice, 
    ctg.categoryName, 
    spl.contactName
FROM
    Product prd 
    INNER JOIN Category ctg
    ON prd.CategoryID = ctg.CategoryID
    INNER JOIN Supplier spl
    ON prd.SupplierID = spl.SupplierID
WHERE
    spl.Country = 'USA'


-- Logical Operators
-- Query 6: Spedific list of products and their suppliers details. 
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


-- Filtering on Data ranges
-- Query 7: Products in specified price range
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


-- Filtering on list of values
-- Query 8: Suppliers in Japan and Italy
SELECT
    CompanyName,
    Country
FROM 
    Supplier
WHERE
    Country IN ('JAPAN', 'Italy') 


-- Working with Nulls (next 3 examples)
-- Fax was a machine from the 90s able to scan and transmit a document over the phone line.

-- Query 9a: Select only suppliers that have a fax number
SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NOT NULL 


-- Query 9b: Select all suppliers
SELECT
    CompanyName,
    Fax
FROM
    Supplier 


-- Query 9c: Select only suppliers that don't have a fax number
SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NULL  


-- Sorting data
-- Query 10: Select product details sorted by category name and unit price
SELECT
    prd.ProductID,
    prd.ProductName,
    ctg.CategoryName,
    prd.UnitPrice
FROM 
    Product as prd
    INNER JOIN Category as ctg
    ON prd.CategoryID = ctg.CategoryID
ORDER BY 
    CategoryName,
    UnitPrice DESC


-- Eliminating duplicates
-- Query 11: Select all countries I buy from
-- There are more than one supplier per country
SELECT DISTINCT 
    Country
FROM 
    Supplier
ORDER BY 
    Country


-- Column alias and string concatenation
-- Query 12: Create employee code
SELECT
    EmployeeID AS ID,
    FirstName,
    LastName,
    CONCAT (SUBSTRING(FirstName,1,1), SUBSTRING(LastName,1,3)) AS Code
FROM
    Employee


-- Limiting results
-- TOP is a SQL Server extention. For MySql and Oracle syntaxes please check https://www.w3schools.com/sql/sql_top.asp
-- Query 13: Top 10 largest orders of a single product
SELECT TOP (10)
    ord.OrderID,
    ord.OrderDate,
    odd.Quantity,
    odd.UnitPrice,
    prd.ProductName, 
    prd.UnitsInStock,
    prd.UnitsOnOrder
FROM
    [Order] ord
    INNER JOIN OrderDetail AS odd 
    ON ord.orderID = odd.OrderID
    INNER JOIN Product AS prd
    ON odd.ProductID = prd.ProductID
ORDER BY 
    odd.Quantity DESC,
    ord.OrderDate DESC


-- Counting
-- Query 14: Number of supplier. 
SELECT
    COUNT(1) AS supplierCount
FROM 
    Supplier


-- Distinct Counting
-- Query 15: Number of countries I buy from.
SELECT 
    COUNT(DISTINCT Country) AS countryCount
FROM 
    Supplier


-- Grouping and Aggregating data
-- Query 16a: Top 10 most sold products
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


-- Query 16b: Top 5 largest orders shipped to the USA
SELECT TOP (5)
    ord.OrderID,
    SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)) AS Total
FROM 
  [Order] AS ord
  INNER JOIN OrderDetail AS odd
  ON ord.orderid = odd.orderid
WHERE
  ord.ShipCountry = 'USA'
GROUP BY
  ord.orderid
ORDER BY 
  Total DESC


-- Query 16c: Orders shipped to the USA with amount over 8K
SELECT 
    ord.OrderID,
    SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)) AS Total
FROM 
  [Order] AS ord
  INNER JOIN OrderDetail AS odd
  ON ord.orderid = odd.orderid
WHERE
  ord.ShipCountry = 'USA'
GROUP BY
  ord.orderid
HAVING 
    SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)) > 8000
ORDER BY 
  Total DESC



-- Query 16d: Quantity of products sold by each Supplier Representative 


----------------- TODO -----------------



-- Recommendation - Products frequently bought together (Queries 17, 18 and 19)

-- Query 17: Number of times products 2 and 61 where bought by the same customer
SELECT DISTINCT
  COUNT(1) AS OrderCount
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
WHERE
    t1.ProductID = 61 AND t2.ProductID = 2 -- Products
GROUP BY 
  t1.ProductID,
  t2.ProductID
ORDER BY 
    OrderCount DESC


-- Query 18: Customers who bought product-61 also bought which products across all orders?
-- Using PARTITION to replace GROUP BY with same results
SELECT DISTINCT TOP (5) 
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
  AND t1.ProductID <> t2.ProductID  -- if not filtering on product, needs to change to > to remove mirroring records
WHERE
    t1.ProductID = 61 -- Testing
ORDER BY 
    ProductBCount DESC, 
    ProductA, 
    ProductB


-- Query 19: Most frequent products bought together. 
-- Customers who bought product-61 also bought which products in the same order?
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
  AND t1.ProductID <> t2.ProductID -- if not filtering on product, needs to change to > to remove mirroring records
WHERE
  t1.ProductID = 61 -- Testing
GROUP BY 
  t1.ProductID,
  t2.ProductID
ORDER BY 
  OrderCount DESC, -- Most frequent at the top
  ProductA, 
  ProductB 


-- Query 20: Insert a new customer
INSERT Customer ([CustomerID],[CompanyName],[ContactName],[ContactTitle],[Address],[City]) --,[Region],[PostalCode],[Country],[Phone],[Fax])
VALUES('AAAAA', 'agnos', 'Jacobus Geluk', 'CTO', 'Abbey Road', 'London')
SELECT * FROM Customer WHERE CustomerID = 'AAAAA' -- yes, sample database chose a string for the ID :-(


-- Query 21: Select new added customer
SELECT * FROM Customer WHERE CustomerID = 'AAAAA'


-- Query 22: Update existing customer (Queries 22a and 22b in SPARQL)
UPDATE Customer
SET Country = 'United Kingdom', PostalCode = 'SW1A 2AA', Address = '10 Downing Road'
WHERE CustomerID = 'AAAAA'


-- Query 23: Checking number of Customers and Orders
SELECT COUNT(*) FROM Customer -- 92
SELECT COUNT(*) FROM [Order]  -- 830


-- Query 24: Customers who placed at least one order: 89 Customers
SELECT DISTINCT
    cst.CustomerID,
    cst.CompanyName,
    cst.ContactName,
    cst.PostalCode,
    cst.Address,
    cst.City
FROM
    Customer cst 
    INNER JOIN [Order] AS ord
    ON cst.CustomerID = ord.CustomerID
ORDER BY    
    cst.City


-- Query 25: Customers who never placed an order
SELECT
    cst.CustomerID,
    cst.CompanyName,
    cst.ContactName,
    cst.PostalCode,
    cst.Address,
    cst.City,
    ord.OrderID -- Included here for demonstration purposes only (values are all NULLs)
FROM
    Customer cst 
    LEFT JOIN [Order] AS ord
    ON cst.CustomerID = ord.CustomerID
WHERE
    ord.ShipCountry IS NULL


-- Subqueries
-- Query 26: Select the two most recent orders of each customer
SELECT 
    cst.CustomerID, 
    cst.City,
    cpp.OrderID, 
    cpp.OrderDate   
FROM 
    Customer AS cst
-- For each customer record, go and get the two most recent orders.
-- An INNER JOIN would return the same result. However, CROSS APPLY is more efficient with SELECT TOP.
CROSS APPLY -- INNER JOIN
(
    SELECT TOP(2) 
        ord.OrderID, 
        ord.OrderDate, 
        cst.CustomerID
    FROM 
        [Order] AS ord
    WHERE 
        ord.customerid = cst.customerid -- reference to the outer query (correlated subquery)
    ORDER BY 
        OrderDate DESC
) AS cpp
ORDER BY 
    CustomerID 


-- Union
-- Query 27: Contact details of suppliers, customers and employees to send Xmas cards.
SELECT 
    -- Column names are defined by the first select
    ContactName,
    Address,
    City,
    PostalCode,
    Country,
    Type = 'Supplier'
FROM
    Supplier
UNION
SELECT 
    ContactName,
    Address,
    City,
    PostalCode,
    Country,
    Type = 'Customer'
FROM
    Customer
UNION
SELECT 
    CONCAT(FirstName, ' ', LastName) AS FullName,
    Address,
    City,
    PostalCode,
    Country,
    Type = 'Employee'
FROM
    Employee
ORDER BY  
    ContactName


-- Running Totals
-- Query 25: 


























