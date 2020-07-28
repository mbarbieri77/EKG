
-- Basic select with specified columns
-- Query 1: Employee titles 
SELECT
    EmployeeID,
    LastName,
    FirstName,
    Title
FROM
    Employee
    

-- Filtering Data
-- Query 2: List of Employees in the USA
SELECT 
    EmployeeID,
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'


-- Query 3: Do I have any employees in France?   
IF EXISTS
(
    SELECT 1
    FROM 
        Employee
    WHERE 
        Country = 'UK'
)
PRINT 'TRUE'
ELSE
PRINT 'FALSE'


-- Character search pattern (Regex)
-- Query 4: Companies that contain the word "rest" in their names
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
-- Joining product, category and supplier.
-- Query 5: Selecting details of products supplied by companies located in the USA
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
-- Query 6: Search specific products
SELECT
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
    prd.ProductName,
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
-- Query 10: Sort products in each product category by unit price descending
SELECT
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
-- Note that there are more than one supplier per country
SELECT DISTINCT 
    Country
FROM 
    Supplier
ORDER BY 
    Country


-- Column alias and string concatenation
-- Query 12: Create employee code
SELECT
    CONCAT (FirstName, ' ', LastName) AS FullName,
    CONCAT (SUBSTRING(FirstName,1,1), SUBSTRING(LastName,1,3), '_', Extension, '_', ISNULL(Region, CONCAT('INT-',country))) AS Code
FROM
    Employee
ORDER BY
    LastName


-- Limiting results
-- TOP is a SQL Server extention. For MySql and Oracle syntaxes please check https://www.w3schools.com/sql/sql_top.asp
-- Query 13: Top 10 largest amount of a product sold in a single order
SELECT TOP 10
    prd.ProductName, 
    ord.OrderID,
    ord.OrderDate,
    odd.Quantity,
    prd.UnitsInStock
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
-- Query 16: Top 5 most sold products
SELECT TOP 5
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


-- Query 17: Top 5 largest orders shipped to the USA
SELECT TOP 5
    ord.OrderID,
    ROUND(SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)), 0) AS Total
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


-- Query 18: Orders shipped to the USA with amount over 10K
SELECT 
    ord.OrderID,
    ROUND(SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)), 0) AS Total
FROM 
  [Order] AS ord
  INNER JOIN OrderDetail AS odd
  ON ord.orderid = odd.orderid
WHERE
  ord.ShipCountry = 'USA'
GROUP BY
  ord.orderid
HAVING 
    SUM(odd.UnitPrice * odd.Quantity * (1 - odd.Discount)) > 10000
ORDER BY 
  Total DESC


-- Query 19: Top 5 Supplier Representative by number of products sold
SELECT 
    TOP 5 
    WITH TIES -- Returns two or more rows that tie for last place in the limited results set.
    spl.ContactName,
    COUNT(prd.ProductID) as ProductCount
FROM
    Product prd 
    INNER JOIN Category ctg
    ON prd.CategoryID = ctg.CategoryID
    INNER JOIN Supplier spl
    ON prd.SupplierID = spl.SupplierID
GROUP BY
    spl.SupplierID,
    spl.ContactName
ORDER BY    
    ProductCount DESC
  

-- Recommendation - Products frequently bought together (next 3 queries)

-- Query 20: Customers who bought product-61 also bought which products in the same order?
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
  t1.ProductID = 61 -- removing filter will do for all products
GROUP BY 
  t1.ProductID,
  t2.ProductID
ORDER BY 
  OrderCount DESC, -- most frequent at the top
  ProductA, 
  ProductB 

  
-- Query 21: Customers who bought product-61 also bought which products across all orders?
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
    t1.ProductID = 61 -- removing filter will do for all products
ORDER BY 
    ProductBCount DESC, -- most frequent at the top
    ProductA, 
    ProductB


-- Query 22: Number of times products 2 and 61 where bought by the same customer
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


-- Query 23: Customers who placed at least one order: 89 Customers
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


-- Query 24: Customers who never placed an order
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
-- Query 25: Select the two most recent orders of each customer
SELECT 
    cst.CustomerID, 
    cst.City,
    cpp.OrderID, 
    cpp.OrderDate   
FROM 
    Customer AS cst
-- For each customer record, go and get the two most recent orders.
-- An INNER JOIN could've been used, however, CROSS APPLY is more efficient when combined with SELECT TOP.
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


-- Query 26: Change the below to return the top 3 most expensive product in each product category


-- Union
-- Query 27: Contact details of suppliers, customers and employees for Xmas cards
SELECT 
    ContactName, 
    Address, City, PostalCode, Country, Type = 'Supplier'
FROM
    Supplier
UNION
SELECT 
    ContactName, 
    Address, City, PostalCode, Country, Type = 'Customer'
FROM
    Customer
UNION
SELECT 
   CONCAT(FirstName, ' ', LastName) AS ContactName, 
   Address, City, PostalCode, Country, Type = 'Employee'
FROM
    Employee
ORDER BY  
    ContactName


-- Running Totals
-- Query 31: 






-- Inserting and updating data

-- Query XX: Insert a new customer
INSERT Customer ([CustomerID],[CompanyName],[ContactName],[ContactTitle],[Address],[City]) 
--,[Region],[PostalCode],[Country],[Phone],[Fax]) 
VALUES('AAAAA', 'agnos', 'Jacobus Geluk', 'CTO', 'Abbey Road', 'London')

-- Checking added record
SELECT * FROM Customer WHERE CustomerID = 'AAAAA' -- note on the sample database: ideally, CustomerID should be an integer incremental value.


-- Query XX: Update existing customer 
UPDATE Customer
SET Country = 'United Kingdom', PostalCode = 'SW1A 2AA', Address = '10 Downing Road'
WHERE CustomerID = 'AAAAA'
























