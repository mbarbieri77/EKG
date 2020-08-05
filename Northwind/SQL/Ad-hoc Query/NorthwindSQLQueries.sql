

-- Northwind SQL Queries


-- Basic select with specified columns


-- Query: Employee titles 
SELECT
    EmployeeID,
    LastName,
    FirstName,
    Title
FROM
    Employee
    

-- Filtering Data


-- Query: List of Employees in the USA
SELECT 
    EmployeeID,
    LastName, 
    FirstName, 
    Title
FROM 
    Employee
WHERE 
    Country = 'USA'


-- Query: Do I have any employees in the UK?   
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


-- Using string comparison
-- Query: Companies that contain the word "Rest" in their names
-- Note that Northwind sample database has been set up with "Latin1_General_CI_AS" collation (Case Insensitive, Accent Sensitive).
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


-- Query: Selecting details of products supplied by companies located in the USA
-- Joining product, category and supplier.
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


-- Query: Customers who placed at least one order
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


-- Query: Customers who never placed an order
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


-- Using Logical Operators


-- Query: Search specific products
-- All products with product names that begin with the letter T or have a product 
-- identification number of 46 and that have a price greater than $16.00.
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
    (productname LIKE 'T%') OR 
	(productid = 46 AND unitprice > 16.00) 


-- Filtering on Data ranges


-- Query: Products in specified price range
-- Retrieves products with a unit price between $10.00 and $20.00. Notice that the result set includes the end values.
SELECT 
    prd.ProductName,
    spl.CompanyName,
    prd.UnitPrice
FROM 
    Product as prd 
    INNER JOIN Supplier as spl 
    ON prd.SupplierID = spl.SupplierID
WHERE
    prd.UnitPrice BETWEEN 18 AND 20 -- Inclusive


-- Filtering on list of values


-- Query: List of suppliers that are located in Japan or Italy
SELECT
    CompanyName,
    Country
FROM 
    Supplier
WHERE
    Country IN ('JAPAN', 'Italy') 


-- Working with Nulls


-- Query: Select only suppliers that have a fax number
-- Note: Fax was a machine from the 90s able to scan and transmit a document over the phone line.
SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NOT NULL 


-- Query: Select all suppliers
SELECT
    CompanyName,
    Fax
FROM
    Supplier 


-- Query: Select only suppliers that don't have a fax number
SELECT
    CompanyName,
    Fax
FROM
    Supplier
WHERE
    Fax IS NULL  


-- Sorting data


-- Query: Sort products in each product category by unit price descending
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


-- Query: Select all countries I buy from
-- Note that there are more than one supplier per country and DISTINCT has been used to eliminate the duplicates.
SELECT DISTINCT 
    Country
FROM 
    Supplier
ORDER BY 
    Country


-- Column alias and string concatenation


-- Query: Create employee code
SELECT
    CONCAT (FirstName, ' ', LastName) AS FullName,
    CONCAT (SUBSTRING(FirstName,1,1), SUBSTRING(LastName,1,3), '_', Extension, '_', ISNULL(Region, CONCAT('INT-',country))) AS Code
FROM
    Employee
ORDER BY
    LastName


-- Limiting results


-- Query: Top 5 largest quantity of a product sold in a single order
-- TOP is a SQL Server extention. For MySql and Oracle syntaxes please check https://www.w3schools.com/sql/sql_top.asp
-- Note that uncommenting WITH TIES would return more rows that tie for last place in the limited results set. 
SELECT TOP 5 -- WITH TIES
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


-- Pagination


-- Query: Retrieve records from 6 to 10 from list of largest quantity of a product sold in a single order
SELECT
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
OFFSET 5 ROWS  
FETCH NEXT 5 ROWS ONLY;  


-- Counting


-- Query: Number of supplier
SELECT
    COUNT(1) AS supplierCount
FROM 
    Supplier


-- Distinct Counting


-- Query: Number of countries I buy from
SELECT 
    COUNT(DISTINCT Country) AS countryCount
FROM 
    Supplier


-- Grouping and Aggregating data


-- Query: Top 5 most sold products
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


-- Query: Top 5 largest orders shipped to the USA
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


-- Query: Orders over 10K shipped to the USA
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


-- Query: Top 5 Supplier Representative by number of products sold
-- Note that this query returns two or more rows that tie for last place in the limited results set.
SELECT 
    TOP 5 
    WITH TIES -- returns rows that tie for last place 
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
  

-- Recommendation


-- Query: Customers who bought product-61 also bought which products in the same order?
SELECT 
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


-- Query: Customers who bought product-61 also bought which products across all orders?
-- Using PARTITION to replace GROUP BY with same results
SELECT DISTINCT 
  t1.ProductID AS ProductA, 
  t2.ProductID AS ProductB,
  COUNT(t2.ProductID) OVER (PARTITION BY t2.ProductID) AS ProductBCount
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


-- Query: Number of times products 2 and 61 where bought by the same customer
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


-- Combining multiple result sets using Union


-- Query: Contact details of suppliers, customers and employees for Xmas cards
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


-- Subqueries


-- Query: Select all products that belong to the Seafood category
SELECT
    prd.ProductName, 
    prd.UnitPrice, 
    prd.UnitsInStock
FROM 
    Product prd
WHERE 
    prd.CategoryID IN (
        SELECT ctg.CategoryID FROM Category ctg WHERE ctg.CategoryName = 'Seafood')
ORDER BY
    prd.ProductName


-- Query: Select all products that belong to the Seafood category
-- This query replaces the previous one by using the more efficient EXISTS
SELECT
    prd.ProductName, 
    prd.UnitPrice, 
    prd.UnitsInStock
FROM 
    Product prd
WHERE 
    EXISTS (
        SELECT 1 FROM Category ctg WHERE prd.CategoryID = ctg.CategoryID AND ctg.CategoryName = 'Seafood')
ORDER BY
    prd.ProductName


-- Query: Select all products that belong to the Seafood category
-- Re-writting the previous query using JOIN
SELECT
    prd.ProductName, 
    prd.UnitPrice, 
    prd.UnitsInStock
FROM 
    Product prd
    INNER JOIN Category ctg 
    ON prd.CategoryID = ctg.CategoryID 
    WHERE ctg.CategoryName = 'Seafood'
ORDER BY
    prd.ProductName


-- Query: Select the 3 most recent orders from each customer
SELECT 
    cst.CustomerID, 
    cst.City,
    cpp.OrderID, 
    cpp.OrderDate   
FROM 
    Customer AS cst
-- For each customer record, go and get the two most recent orders.
CROSS APPLY -- An INNER JOIN could've been used, however, CROSS APPLY is more efficient when combined with SELECT TOP.
(
    SELECT TOP 3 
        ord.OrderID, ord.OrderDate, cst.CustomerID
    FROM 
        [Order] AS ord
    WHERE 
        ord.customerid = cst.customerid -- reference to the outer query (correlated subquery)
    ORDER BY 
        ord.OrderDate DESC
) AS cpp
ORDER BY 
    cst.CustomerID, 
    cst.City,
    cpp.OrderDate DESC


-- Window Functions
-- Compute aggregated values such as moving averages, cumulative aggregates, running totals, or a top N numbering and ranking per group results.
-- Reference: https://docs.microsoft.com/en-us/sql/t-sql/queries/select-over-clause-transact-sql?view=sql-server-2017


-- Query: Select the 3 most recent orders from each customer
-- This query replaces the previous one by using the more efficient Window Function. 
SELECT 
    ptt.*
FROM
(
    SELECT
    cst.CustomerID, 
    cst.City,
    ord.OrderID, 
    ord.OrderDate, 
    ROW_NUMBER() OVER(PARTITION BY cst.CustomerID ORDER BY ord.OrderDate DESC) AS [RowNumber]
    FROM Customer AS cst
    INNER JOIN [Order] AS ord 
    ON cst.CustomerID = ord.CustomerID
) ptt
WHERE 
    ptt.[RowNumber] <= 3


-- Query: Top 10 most expensive product in each product category
-- ROW_NUMBER is used to number the rows sequentially in the partition.
SELECT 
    ptt.*
FROM
(
    SELECT
        ctg.CategoryName,
        prd.ProductName, 
        prd.UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [RowNumber] 
    FROM 
        Product prd
        INNER JOIN Category ctg 
        ON prd.CategoryID = ctg.CategoryID  
) ptt
WHERE 
    ptt.[RowNumber] <= 10
ORDER BY
    ptt.CategoryName,
    ptt.RowNumber 
  

-- Query: Order total quantity and percentage by product
SELECT 
    ord.OrderID, 
    ord.ProductID, 
    ord.Quantity,  
    SUM(ord.Quantity) OVER(PARTITION BY ord.OrderID) AS Total,  
    CAST(1. * ord.Quantity / SUM(ord.Quantity) OVER(PARTITION BY ord.OrderID) * 100 AS DECIMAL(5,2)) AS "PercByProduct"  
FROM 
    OrderDetail ord 
WHERE 
    ord.OrderID IN(10248,10249, 10250);  
GO  


-- Query: Top 10 most expensive product in each product category (RANK, DENSE_RANK, NTILE)
-- RANK: same as ROW_NUMBER, however it provides the same numeric value for ties.
-- DENSE_RANK: the same as RANK, however it has no gaps in the ranking values.
-- NTILE: distributes the rows in an ordered partition into a specified number of groups.
-- Reference: https://docs.microsoft.com/en-us/sql/t-sql/functions/ranking-functions-transact-sql?view=sql-server-ver15
SELECT 
    ptt.*
FROM
(
    SELECT
        ctg.CategoryName,
        prd.ProductName, 
        prd.UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [RowNumber], 
        RANK() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [RANK],
        DENSE_RANK() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [DENSE_RANK],
        NTILE(6) OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [NTILE]
    FROM 
        Product prd
        INNER JOIN Category ctg 
        ON prd.CategoryID = ctg.CategoryID  
) ptt
WHERE 
    ptt.[RowNumber] <= 10
ORDER BY
    ptt.CategoryName,
    ptt.RowNumber 


-- Inserting and updating data


-- Query: Insert a new customer
INSERT Customer ([CustomerID],[CompanyName],[ContactName],[ContactTitle],[Address],[City]) 
--,[Region],[PostalCode],[Country],[Phone],[Fax]) 
VALUES('AAAAA', 'agnos', 'Jacobus Geluk', 'CTO', 'Abbey Road', 'London')

-- Checking if new customer has been added successfully
SELECT * FROM Customer WHERE CustomerID = 'AAAAA' -- note on the sample database: ideally, CustomerID should be an integer incremental value.


-- Query: Update existing customer 
UPDATE Customer
SET Country = 'United Kingdom', PostalCode = 'SW1A 2AA', Address = '10 Downing Road'
WHERE CustomerID = 'AAAAA'


-- Query: Apply a 10% discount on the top 5 most expensive product in each product category
-- Could have used a temp table to save the list of products affected in order to be able to check if the discount had been applied successfully.
UPDATE 
    Product
SET 
    UnitPrice = UnitPrice * 0.9
WHERE 
    ProductID IN
    (
        SELECT 
            ptt.ProductID
        FROM
        (
            SELECT
                prd.ProductID,
                ROW_NUMBER() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [RowNumber] 
            FROM 
                Product prd
                INNER JOIN Category ctg 
                ON prd.CategoryID = ctg.CategoryID  
        ) ptt
        WHERE 
            ptt.[RowNumber] <= 5
    )


-- Query: Apply a 10% discount on the top 5 most expensive product in each product category
-- This time using a temp table to save the list of products affected in order to be able to check if the 
-- discount has been applied successfully.
-- This is a simple example, but a temp table could be used to store a dataset that goes under many calculations 
-- before being commited to the actual table on the database.
SELECT 
    ptt.ProductID,
    ptt.UnitPrice
INTO    
    #ProdDiscount
FROM
(
    SELECT
        prd.ProductID,
        prd.UnitPrice,
        ROW_NUMBER() OVER(PARTITION BY ctg.CategoryID ORDER BY prd.UnitPrice DESC) AS [RowNumber] 
    FROM 
        Product prd
        INNER JOIN Category ctg 
        ON prd.CategoryID = ctg.CategoryID  
) ptt
WHERE 
    ptt.[RowNumber] <= 5


UPDATE 
    Product
SET 
    UnitPrice = UnitPrice * 0.9
WHERE 
    ProductID IN (SELECT ProductID FROM #ProdDiscount)


-- Displaying final price after discount has been applied (which is not possible in the previous example, unless you use Temporal Tables, Change Tracking, etc)
SELECT
    prd.ProductID,
    prd.UnitPrice
FROM 
    Product prd
    INNER JOIN #ProdDiscount tpr
    ON prd.ProductID = tpr.ProductID
ORDER BY
    prd.ProductID


DROP TABLE IF EXISTS #ProdDiscount