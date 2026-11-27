CREATE DATABASE RetailDB;
USE RetailDB;
CREATE TABLE Customers (
    Customer_ID INT PRIMARY KEY,
    Customer_Name VARCHAR(50),
    Email VARCHAR(100),
    City VARCHAR(50)
);

CREATE TABLE Products (
    Product_ID INT PRIMARY KEY,
    Product_Name VARCHAR(100),
    Category VARCHAR(50),
    Units_Sold INT
);

CREATE TABLE Stores (
    Store_ID INT PRIMARY KEY,
    Store_Name VARCHAR(100),
    Region VARCHAR(50)
);

CREATE TABLE Employees (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Manager_ID INT,
    Store_ID INT,
    FOREIGN KEY (Manager_ID) REFERENCES Employees(Employee_ID),
    FOREIGN KEY (Store_ID) REFERENCES Stores(Store_ID)
);

CREATE TABLE Returns (
    Return_ID INT PRIMARY KEY,
    Customer_ID INT,
    Product_ID INT,
    Store_ID INT,
    Return_Quantity INT,
    Return_Date DATE,
    FOREIGN KEY (Customer_ID) REFERENCES Customers(Customer_ID),
    FOREIGN KEY (Product_ID) REFERENCES Products(Product_ID),
    FOREIGN KEY (Store_ID) REFERENCES Stores(Store_ID)
);

CREATE TABLE Refunds (
    Refund_ID INT PRIMARY KEY,
    Return_ID INT,
    Refund_Amount DECIMAL(10,2),
    Refund_Date DATE,
    FOREIGN KEY (Return_ID) REFERENCES Returns(Return_ID)
);
show tables;


INSERT INTO Customers VALUES
(1, 'Arun Kumar', 'arun@gmail.com', 'Chennai'),
(2, 'Priya Sharma', 'priya@gmail.com', 'Bangalore'),
(3, 'Rahul Verma', 'rahul@gmail.com', 'Hyderabad'),
(4, 'Sneha Raj', 'sneha@gmail.com', 'Chennai'),
(5, 'Karthik S', 'karthik@gmail.com', 'Mumbai'),
(6, 'Divya Nair', 'divya@gmail.com', 'Bangalore');

INSERT INTO Products VALUES
(101, 'Laptop', 'Electronics', 100),
(102, 'Smartphone', 'Electronics', 200),
(103, 'Headphones', 'Accessories', 150),
(104, 'Office Chair', 'Furniture', 50),
(105, 'Keyboard', 'Accessories', 100),
(106, 'Monitor', 'Electronics', 80);

INSERT INTO Stores VALUES
(1, 'Chennai Central', 'South'),
(2, 'Bangalore Plaza', 'South'),
(3, 'Mumbai Mall', 'West'),
(4, 'Hyderabad Hub', 'South');

INSERT INTO Employees VALUES
(1, 'Ramesh', NULL, 1),
(2, 'Suresh', NULL, 2),
(3, 'Meena', NULL, 3),
(4, 'Arun', 1, 1),
(5, 'Priya', 1, 1),
(6, 'Vijay', 2, 2),
(7, 'Kavya', 3, 3),
(8, 'Nithya', 2, 2);
select * from returns;
INSERT INTO Returns VALUES
(1, 1, 101, 1, 15, '2026-11-01'),
(2, 2, 102, 2, 10, '2026-11-02'),
(3, 3, 103, 3, 25, '2026-11-03'),
(4, 4, 104, 1, 5, '2026-11-04'),
(5, 5, 105, 2, 20, '2026-11-05'),
(6, 6, 106, 3, 8, '2026-11-06'),
(7, 1, 103, 4, 10, '2026-11-07'),
(8, 3, 101, 2, 5, '2026-11-08'),
(9, 4, 102, 1, 15, '2026-11-09'),
(10, 6, 105, 4, 10, '2026-11-10');

INSERT INTO Refunds VALUES
(1, 1, 15000.00, '2026-11-02'),
(2, 2, 8000.00, '2026-11-03'),
(3, 3, 5000.00, '2026-11-04'),
(4, 5, 4000.00, '2026-11-06'),
(5, 6, 12000.00, '2026-11-07'),
(6, 8, 6000.00, '2026-11-09'),
(7, 9, 9000.00, '2026-11-10');

-- customer with returns but no refunds
select c.customer_name, p.product_name, s.store_name from returns r INNER JOIN Customers c
    ON r.Customer_ID = c.Customer_ID
INNER JOIN Products p
    ON r.Product_ID = p.Product_ID
INNER JOIN Stores s
    ON r.Store_ID = s.Store_ID;

select c.customer_name from customers c left join returns r on c.customer_id = r.customer_id
left join refunds rf on rf.return_id = r.return_id where rf.return_id is null;

-- stores with the highest refund value 
select s.store_name, SUM(rf.refund_amount) AS total_refund from stores s inner join returns r on s.store_id = r.store_id
inner join refunds rf on rf.return_id = r.return_id 
group by s.store_id, s.store_name
ORDER BY total_refund DESC
LIMIT 1;

SELECT
    p.Product_Name,
    SUM(r.Return_Quantity) AS Total_Returned,
    p.Units_Sold,
    (SUM(r.Return_Quantity) * 100.0 / p.Units_Sold) AS Return_Rate
FROM Products p
INNER JOIN Returns r
    ON p.Product_ID = r.Product_ID
GROUP BY
    p.Product_ID,
    p.Product_Name,
    p.Units_Sold
HAVING
    (SUM(r.Return_Quantity) * 100.0 / p.Units_Sold) > 10;
    
INSERT INTO Refunds
VALUES (8, NULL, 2000.00, '2026-11-11');    

-- null pitfall

SELECT Customer_Name
FROM Customers
WHERE Customer_ID NOT IN (
    SELECT r.Customer_ID
    FROM Returns r
    INNER JOIN Refunds rf
        ON r.Return_ID = rf.Return_ID
);

-- not exists

SELECT c.Customer_ID, c.Customer_Name
FROM Customers c
WHERE NOT EXISTS (
    SELECT 1
    FROM Returns r
    INNER JOIN Refunds rf
        ON r.Return_ID = rf.Return_ID
    WHERE r.Customer_ID = c.Customer_ID
);
SELECT * FROM Refunds;

-- any
WITH Store_Refunds AS (
    SELECT
        s.Store_ID,
        s.Store_Name,
        s.Region,
        COALESCE(SUM(rf.Refund_Amount), 0) AS Total_Refund
    FROM Stores s
    LEFT JOIN Returns r
        ON s.Store_ID = r.Store_ID
    LEFT JOIN Refunds rf
        ON r.Return_ID = rf.Return_ID
    GROUP BY s.Store_ID, s.Store_Name, s.Region
)
SELECT *
FROM Store_Refunds sr
WHERE sr.Total_Refund > ANY (
    SELECT other.Total_Refund
    FROM Store_Refunds other
    WHERE other.Region = sr.Region
      AND other.Store_ID <> sr.Store_ID
)
AND EXISTS (
    SELECT 1
    FROM Store_Refunds other
    WHERE other.Region = sr.Region
      AND other.Store_ID <> sr.Store_ID
);

-- all

WITH Store_Refunds AS (
    SELECT
        s.Store_ID,
        s.Store_Name,
        s.Region,
        COALESCE(SUM(rf.Refund_Amount), 0) AS Total_Refund
    FROM Stores s
    LEFT JOIN Returns r
        ON s.Store_ID = r.Store_ID
    LEFT JOIN Refunds rf
        ON r.Return_ID = rf.Return_ID
    GROUP BY s.Store_ID, s.Store_Name, s.Region
)
SELECT *
FROM Store_Refunds sr
WHERE sr.Total_Refund > ALL (
    SELECT other.Total_Refund
    FROM Store_Refunds other
    WHERE other.Region = sr.Region
      AND other.Store_ID <> sr.Store_ID
)
AND EXISTS (
    SELECT 1
    FROM Store_Refunds other
    WHERE other.Region = sr.Region
      AND other.Store_ID <> sr.Store_ID
);

-- nested subqueries

SELECT Customer_ID, Customer_Name
FROM Customers
WHERE Customer_ID IN (
    SELECT Customer_ID
    FROM Returns
    WHERE Product_ID IN (
        SELECT Product_ID
        FROM Products
        WHERE Category = 'Electronics'
    )
);

-- products whose total returned quantity is greater than the average returned quantity across all products.

SELECT
    p.Product_ID,
    p.Product_Name,
    SUM(r.Return_Quantity) AS Total_Returned
FROM Products p
INNER JOIN Returns r
    ON p.Product_ID = r.Product_ID
GROUP BY p.Product_ID, p.Product_Name
HAVING SUM(r.Return_Quantity) > (
    SELECT AVG(Product_Total)
    FROM (
        SELECT SUM(Return_Quantity) AS Product_Total
        FROM Returns
        GROUP BY Product_ID
    ) AS Product_Averages
);

CREATE TABLE emp (
    Employee_ID INT PRIMARY KEY,
    Employee_Name VARCHAR(50),
    Manager_ID INT
);


INSERT INTO emp VALUES
(1, 'Ramesh', NULL),
(2, 'Suresh', NULL),
(3, 'Arun', 1),
(4, 'Priya', 1),
(5, 'Vijay', 2),
(6, 'Kavya', 2);
select e.employee_name as Employee,m.employee_name as Manager from emp e inner join emp m on e.manager_id = m.employee_id;

