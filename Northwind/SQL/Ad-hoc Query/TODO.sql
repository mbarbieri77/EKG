

-- Proposed Queries


--  This example displays a cross join between the shippers and
--  suppliers tables that is useful for listing all of the possible
--  ways that suppliers can ship their products. 
-----------------------------------------------------------------------

USE northwind
SELECT suppliers.companyname, shippers.companyname
 FROM suppliers
 CROSS JOIN shippers
GO



-----------------------------------------------------------------------
--  This example displays pairs of employees who have the same job
--  title. When the WHERE clause includes the less than (<) operator,
--  rows that match themselves and duplicate rows are eliminated. 
-----------------------------------------------------------------------

USE northwind
SELECT a.employeeid, LEFT(a.lastname,10) AS name
      ,LEFT(a.title,10) AS title
      ,b.employeeid, LEFT(b.lastname,10) AS name
      ,LEFT(b.title,10) AS title
 FROM employees AS a
 INNER JOIN employees AS b
  ON a.title = b.title
 WHERE a.employeeid < b.employeeid
GO


--For example, the following query finds customers located in a territory not covered by any sales persons.

SQL

Copy
USE AdventureWorks2016;
GO
SELECT CustomerID
FROM Sales.Customer
WHERE TerritoryID <> ANY
    (SELECT TerritoryID
     FROM Sales.SalesPerson);
GO


--*********************************************************************
-- 2071A Mod 6:  Evaluating a Correlated Subquery
--   Example 1
-----------------------------------------------------------------------
--  This example returns a list of customers who ordered more than
--  20 pieces of product number 23.
-----------------------------------------------------------------------

USE northwind
SELECT orderid, customerid
 FROM orders AS or1
 WHERE 20 < (SELECT quantity
             FROM [order details] AS od
             WHERE or1.orderid = od.orderid
              AND od.productid = 23)
GO



--*********************************************************************
-- 2071A Mod 6:  Evaluating a Correlated Subquery
--   Example 2
-----------------------------------------------------------------------
--  This example returns a list of products and the largest order
--  ever placed for each product in the order details table.
--  Notice that this correlated subquery references the same table
--  as the outer query; the optimizer will generally treat this
--  as a self-join.
-----------------------------------------------------------------------

USE northwind
SELECT DISTINCT productid, quantity
 FROM [order details] AS ord1
 WHERE quantity = ( SELECT MAX(quantity)
                     FROM [order details] AS ord2
                     WHERE ord1.productid = ord2.productid )
GO



--*********************************************************************
-- 2071A Mod 6:  Using the EXISTS and NOT EXISTS Clauses
--   Example 1
-----------------------------------------------------------------------
--  This example uses a correlated subquery with an EXISTS operator
--  in the WHERE clause to return a list of employees who took orders
--  on 4/10/2000.
-----------------------------------------------------------------------

USE northwind
SELECT lastname, employeeid
 FROM employees AS e
 WHERE EXISTS ( SELECT * FROM orders AS o
                 WHERE e.employeeid = o.employeeid
                  AND o.orderdate = '9/5/1997' )
GO



--*********************************************************************
-- 2071A Mod 6:  Using the EXISTS and NOT EXISTS Clauses
--   Example 2
-----------------------------------------------------------------------
--  This example returns the same result set as example 1 and shows
--  that you could use a join operation rather than a correlated
--  subquery. Note that the query needs the DISTINCT keyword to
--  return only a single row for each employee.
-----------------------------------------------------------------------

USE northwind
SELECT DISTINCT lastname, e.employeeid
 FROM orders AS o
 INNER JOIN employees AS e
  ON o.employeeid = e.employeeid
 WHERE o.orderdate = '9/5/1997'
GO

-- ORDER WHIT PRODUCTS 22 AND 57 ---------------------------------------

select * from [order details]
-- N�O FUNCIONA --------------------------------------------------------
select * from [order details] where productid = 22 OR/AND productid = 57

-- SUBQUERY (SHOWS ORDERS WITH OTHER PRODUCTS ID OTHER THAN 22 AND 57)--
select * from [order details] od1
where exists (select *
                    from [order details] od2
                    where od2.OrderID = od1.OrderID
                    and od2.ProductID = 22)
and exists (select *
                    from [order details] od2
                    where od2.OrderID = od1.OrderID
                    and od2.ProductID = 57)

-- SUBQUERY (ONLY COMBINATION OF ORDER AND PRODUCTID THAT SATISFY THE QUERY. 
select * from [order details] od1
where exists(select 1 from [order details] od2
where od2.orderid=od1.orderid
and od2.productid=57)
and od1.productid=22

-- SELF JOIN -----------------------------------------------------------
SELECT * FROM 
[order details] od1 INNER JOIN [order details] od2
ON od1.OrderID = od2.OrderID
WHERE
od1.ProductID = 22 AND od2.ProductID = 57



--*********************************************************************
-- 2071A Mod 7:  Inserting a Row of Data by Values
--   Example 1
-----------------------------------------------------------------------
--  The following example adds Pecos Coffee Company as a new customer.
-----------------------------------------------------------------------

USE northwind
INSERT customers
      (customerid, companyname, contactname, contacttitle
      ,address, city, region, postalcode, country, phone
      ,fax)
VALUES ('PECOF', 'Pecos Coffee Company','Michael Dunn'
       ,'Owner', '1900 Oak Street', 'Vancouver', 'BC'
       ,'V3F 2K1', 'Canada', '(604) 555-3392'
       ,'(604) 555-7293')
GO

USE northwind
SELECT companyname, contactname
 FROM customers
 WHERE customerid = 'PECOF'
GO


--*********************************************************************
-- 2071A Mod 7:  Using the INSERT�SELECT Statement
--   Example 1
-----------------------------------------------------------------------
--  This example adds new customers to the customers table.
-----------------------------------------------------------------------

USE northwind
INSERT customers
 SELECT substring (firstname, 1, 3)
         + substring (lastname, 1, 2)
       ,lastname, firstname, title, address, city
       ,region, postalcode, country, homephone, NULL
 FROM employees
GO



--*********************************************************************
-- 2071A Mod 7:  Creating a Table Using the SELECT INTO Statement
--   Example 1
-----------------------------------------------------------------------
--  This example creates a local temporary table based on a query
--  made on the products table.
-----------------------------------------------------------------------

USE northwind
SELECT productname AS products
      ,unitprice AS price
      ,(unitprice * 1.1) AS tax
 INTO #pricetable
 FROM products
GO

USE northwind
SELECT * FROM #pricetable
GO

-- CREATING A ID COLUMN IN A TEMPORARY TABLE.
select lastname, orderdate, ID = IDENTITY(int, 1,1)
into #temp
from employees inner join orders
on employees.employeeid = orders.employeeid

SELECT ID, lastname, orderdate FROM #temp


--*********************************************************************
-- 2071A Mod 7:  Inserting Partial Data
--   Example 1
-----------------------------------------------------------------------
--  This example adds the company Fitch & Mather as a new shipper
--  in the shippers table. Data is not entered for columns that
--  have an IDENTITY property or that allow default or null values.
-----------------------------------------------------------------------

USE northwind
INSERT shippers (companyname)
VALUES ('Fitch & Mather')
GO

USE northwind
SELECT *
FROM shippers
WHERE companyname = 'Fitch & Mather'
GO



--*********************************************************************
-- 2071A Mod 7:  Inserting Partial Data
--   Example 2
-----------------------------------------------------------------------
--  This example also adds Fitch & Mather as a new shipper in
--  the shippers table. Notice that the DEFAULT keyword is used
--  for columns that allow default or null values. Compare this
--  example to Example 1.
-----------------------------------------------------------------------

USE northwind
INSERT shippers (companyname, Phone)
VALUES ('Fitch & Mather', DEFAULT)
GO



--*********************************************************************
-- 2071A Mod 7:  Inserting Data by Using Column Defaults
--   Example 1
-----------------------------------------------------------------------
--  This example inserts a new row for the Kenya Coffee Company
--  without using a column_list.
-----------------------------------------------------------------------

USE northwind
INSERT shippers (companyname, phone)
 VALUES ('Kenya Coffee Co.', DEFAULT)
GO

USE northwind
SELECT *
 FROM shippers
 WHERE companyname = 'Kenya Coffee Co.'
GO



--*********************************************************************
-- 2071A Mod 7:  Using the DELETE Statement
--   Example 1
-----------------------------------------------------------------------
--  This example deletes all order records that are equal to or
--  greater than six months old.
-----------------------------------------------------------------------

USE northwind
DELETE orders
 WHERE DATEDIFF(MONTH, shippeddate, GETDATE()) >= 6
GO



--*********************************************************************
-- 2071A Mod 7:  Using the TRUNCATE TABLE Statement
--   Example 1
-----------------------------------------------------------------------
--  This example removes all data from the orders table.
-----------------------------------------------------------------------

USE northwind
TRUNCATE TABLE orders
GO



--*********************************************************************
-- 2071A Mod 7:  Deleting Rows Based on Other Tables
--   Example 1
-----------------------------------------------------------------------
--  This example uses a join operation with the DELETE statement
--  to remove rows from the order details table for orders taken
--  on 4/10/2000. 
-----------------------------------------------------------------------

USE northwind
DELETE FROM [order details]
 FROM orders AS o
 INNER JOIN [order details] AS od
  ON o.orderid = od.orderid
 WHERE orderdate = '4/14/1998'
GO



--*********************************************************************
-- 2071A Mod 7:  Deleting Rows Based on Other Tables
--   Example 2
-----------------------------------------------------------------------
--  This example removes the same rows in the order details table
--  as Example 1 and shows that you can convert a join operation
--  to a nested subquery.
-----------------------------------------------------------------------

USE northwind
DELETE FROM [order details]
 WHERE orderid IN (
                   SELECT orderid
                    FROM orders
                    WHERE orderdate = '4/14/1998'
                  )
GO



--*********************************************************************
-- 2071A Mod 7:  Updating Rows Based on Data in the Table
--   Example 1
-----------------------------------------------------------------------
--  The following example adds 10 percent to the current prices
--  of all Northwind Traders products.
-----------------------------------------------------------------------

USE northwind
UPDATE products
 SET unitprice = (unitprice * 1.1)
GO



--*********************************************************************
-- 2071A Mod 7:  Updating Rows Based on Other Tables
--   Example 1
-----------------------------------------------------------------------
--  This example uses a join to update the products table by adding
--  $2.00 to the unitprice column for all products supplied by
--  suppliers in the United States (USA). 
-----------------------------------------------------------------------

UPDATE products
 SET unitprice = unitprice + 2
 FROM products
 INNER JOIN suppliers
  ON products.supplierid = suppliers.supplierid
 WHERE suppliers.country = 'USA'
GO



--*********************************************************************
-- 2071A Mod 7:  Updating Rows Based on Other Tables
--   Example 2
-----------------------------------------------------------------------
--  This example uses a subquery to update the products table by
--  adding $2.00 to the unitprice column for all products supplied
--  by suppliers in the in the United States (USA). Notice that
--  each product has only one supplier.
-----------------------------------------------------------------------

UPDATE products
 SET unitprice = unitprice + 2
 WHERE supplierid IN (
                      SELECT supplierid
                       FROM suppliers
                       WHERE country = 'USA'
                     )
GO



--*********************************************************************
-- 2071A Mod 7:  Updating Rows Based on Other Tables
--   Example 2
-----------------------------------------------------------------------
--  This example updates the total sales for all orders of each
--  product in the products table. Many orders for each product may
--  exist. 
--  If you want to execute the following example, you must add a
--  todatesales column with a default value of 0 to the products table.
-----------------------------------------------------------------------

USE northwind
UPDATE products
 SET todatesales = (
                    SELECT SUM(quantity)
                     FROM [order details] AS od
                     WHERE products.productid = od.productid
                    )
GO



