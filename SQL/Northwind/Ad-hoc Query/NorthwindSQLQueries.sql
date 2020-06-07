/*
    Name: Basic Select
    Description: Basic Select with specified columns
    ---------------------------------------------------
    Author              Date            Description
    Marcelo Barbieri    26-May-2020     Initial Version
*/
SELECT
    EmployeeID,
    LastName,
    FirstName,
    Title
FROM
    Employee
    
    
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
