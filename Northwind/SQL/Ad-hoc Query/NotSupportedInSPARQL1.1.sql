

-- Not Supported in SPARQL 1.1


-- Query: Select the 3 most recent orders from each customer.
SELECT 
    cst.CustomerID, 
    cst.City,
    cpp.OrderID, 
    cpp.OrderDate   
FROM 
    Customer AS cst
-- For each customer record, go and get the two most recent orders.
-- An INNER JOIN could've been used, however, CROSS APPLY is more efficient when combined with SELECT TOP.
CROSS APPLY 
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


-- Query: Apply a 10% discount on the top 5 most expensive product in each product category.
-- This time using a temp table to save the list of products affected.
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


-- Displaying price after discount for the products affected (which is not possible in the previous example, 
-- unless Temporal Tables, Change Tracking, etc are used).
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

