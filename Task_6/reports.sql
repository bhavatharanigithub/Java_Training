-- Day 8 Set 2: Insurance Policy Reporting | MySQL 8.4 LTS
CREATE DATABASE IF NOT EXISTS insurance_reporting_db;
USE insurance_reporting_db;

DROP TABLE IF EXISTS claims;
DROP TABLE IF EXISTS policies;
DROP TABLE IF EXISTS agents;
DROP TABLE IF EXISTS customers;
DROP TABLE IF EXISTS products;

CREATE TABLE products (
  product_id INT PRIMARY KEY,
  product_name VARCHAR(100) NOT NULL UNIQUE
) ENGINE=InnoDB;

CREATE TABLE customers (
  customer_id INT PRIMARY KEY,
  customer_name VARCHAR(120) NOT NULL,
  date_of_birth DATE NOT NULL,
  email VARCHAR(150)
) ENGINE=InnoDB;

CREATE TABLE agents (
  agent_id INT PRIMARY KEY,
  agent_name VARCHAR(120) NOT NULL,
  branch_name VARCHAR(100)
) ENGINE=InnoDB;

CREATE TABLE policies (
  policy_id INT PRIMARY KEY,
  policy_number VARCHAR(30) NOT NULL UNIQUE,
  customer_id INT NOT NULL,
  product_id INT NOT NULL,
  agent_id INT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  annual_premium DECIMAL(12,2) NOT NULL,
  status ENUM('ACTIVE','EXPIRED','CANCELLED') NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id),
  FOREIGN KEY (agent_id) REFERENCES agents(agent_id),
  CHECK (end_date >= start_date),
  CHECK (annual_premium >= 0)
) ENGINE=InnoDB;

CREATE TABLE claims (
  claim_id INT PRIMARY KEY,
  policy_id INT NOT NULL,
  claim_date DATE NOT NULL,
  claim_amount DECIMAL(12,2) NOT NULL,
  claim_status ENUM('FILED','APPROVED','REJECTED','PAID') NOT NULL,
  FOREIGN KEY (policy_id) REFERENCES policies(policy_id),
  CHECK (claim_amount >= 0)
) ENGINE=InnoDB;

INSERT INTO products VALUES
(1,'Health Insurance'),(2,'Motor Insurance'),
(3,'Life Insurance'),(4,'Travel Insurance');

INSERT INTO customers VALUES
(101,'Ananya Kumar','1990-05-14','ananya@example.com'),
(102,'Rahul Sharma','1982-09-20','rahul@example.com'),
(103,'Meera Iyer','2001-02-11','meera@example.com'),
(104,'Karthik Rao','1970-12-05','karthik@example.com'),
(105,'Divya Nair','1996-07-29','divya@example.com'),
(106,'Arjun Das','2007-03-18','arjun@example.com');

INSERT INTO agents VALUES
(201,'Sanjay Patel','Chennai'),
(202,'Priya Menon','Bengaluru'),
(203,'Vikram Singh','Hyderabad'),
(204,'Nisha Reddy','Chennai');

-- Sample dates are relative to the day the script is executed.
INSERT INTO policies VALUES
(1001,'POL-HEALTH-0001',101,1,201,DATE_SUB(CURDATE(),INTERVAL 8 MONTH),DATE_ADD(CURDATE(),INTERVAL 10 DAY),12000,'ACTIVE'),
(1002,'POL-MOTOR-0002',101,2,201,DATE_SUB(CURDATE(),INTERVAL 5 MONTH),DATE_ADD(CURDATE(),INTERVAL 180 DAY),8000,'ACTIVE'),
(1003,'POL-LIFE-0003',102,3,202,DATE_SUB(CURDATE(),INTERVAL 2 MONTH),DATE_ADD(CURDATE(),INTERVAL 300 DAY),20000,'ACTIVE'),
(1004,'POL-HEALTH-0004',103,1,203,DATE_SUB(CURDATE(),INTERVAL 11 MONTH),DATE_ADD(CURDATE(),INTERVAL 25 DAY),10000,'ACTIVE'),
(1005,'POL-MOTOR-0005',104,2,202,DATE_SUB(CURDATE(),INTERVAL 15 MONTH),DATE_SUB(CURDATE(),INTERVAL 2 DAY),9000,'EXPIRED'),
(1006,'POL-TRAVEL-0006',105,4,204,DATE_SUB(CURDATE(),INTERVAL 20 DAY),DATE_ADD(CURDATE(),INTERVAL 60 DAY),5000,'ACTIVE'),
(1007,'POL-LIFE-0007',106,3,203,CURDATE(),DATE_ADD(CURDATE(),INTERVAL 365 DAY),15000,'ACTIVE'),
(1008,'POL-HEALTH-0008',102,1,201,DATE_SUB(CURDATE(),INTERVAL 3 MONTH),DATE_ADD(CURDATE(),INTERVAL 200 DAY),14000,'ACTIVE'),
(1009,'POL-MOTOR-0009',105,2,204,DATE_SUB(CURDATE(),INTERVAL 1 MONTH),DATE_ADD(CURDATE(),INTERVAL 330 DAY),11000,'ACTIVE'),
(1010,'POL-TRAVEL-0010',104,4,202,DATE_SUB(CURDATE(),INTERVAL 14 MONTH),DATE_SUB(CURDATE(),INTERVAL 30 DAY),4000,'EXPIRED');

INSERT INTO claims VALUES
(5001,1001,DATE_SUB(CURDATE(),INTERVAL 20 DAY),5000,'PAID'),
(5002,1001,DATE_SUB(CURDATE(),INTERVAL 10 DAY),2500,'APPROVED'),
(5003,1002,DATE_SUB(CURDATE(),INTERVAL 45 DAY),3000,'PAID'),
(5004,1003,DATE_SUB(CURDATE(),INTERVAL 15 DAY),15000,'PAID'),
(5005,1004,DATE_SUB(CURDATE(),INTERVAL 5 DAY),7000,'FILED'),
(5006,1005,DATE_SUB(CURDATE(),INTERVAL 60 DAY),2000,'REJECTED'),
(5007,1008,DATE_SUB(CURDATE(),INTERVAL 12 DAY),2000,'PAID');

-- 1. Policies expiring in the next 30 days.
-- INNER JOIN: only policies with matching customer and product records.
SELECT p.policy_id,
       CONCAT(SUBSTRING(p.policy_number,1,8),'****',SUBSTRING(p.policy_number,-4)) AS masked_policy_number,
       c.customer_name, pr.product_name, p.end_date,
       DATEDIFF(p.end_date,CURDATE()) AS days_until_expiry
FROM policies p
INNER JOIN customers c ON c.customer_id=p.customer_id
INNER JOIN products pr ON pr.product_id=p.product_id
WHERE p.status='ACTIVE'
  AND p.end_date BETWEEN CURDATE() AND DATE_ADD(CURDATE(),INTERVAL 30 DAY)
ORDER BY p.end_date,p.policy_id;

-- 2. Premium per product.
-- INNER JOIN: only products having policies are included.
SELECT pr.product_id,pr.product_name,COUNT(p.policy_id) AS policy_count,
       SUM(p.annual_premium) AS total_annual_premium,
       AVG(p.annual_premium) AS average_annual_premium
FROM products pr
INNER JOIN policies p ON p.product_id=pr.product_id
GROUP BY pr.product_id,pr.product_name
ORDER BY total_annual_premium DESC;

-- 3. Customers with more than one active, unexpired policy.
-- INNER JOIN finds matching policies; HAVING filters grouped customers.
SELECT c.customer_id,c.customer_name,COUNT(p.policy_id) AS active_policy_count,
       SUM(p.annual_premium) AS total_active_premium
FROM customers c
INNER JOIN policies p ON p.customer_id=c.customer_id
WHERE p.status='ACTIVE' AND p.end_date>=CURDATE()
GROUP BY c.customer_id,c.customer_name
HAVING COUNT(p.policy_id)>1
ORDER BY active_policy_count DESC,c.customer_name;

-- 4. Claim ratio per product.
-- Claims are pre-aggregated per policy so multiple claims do not multiply premium.
-- LEFT JOIN keeps policies with no claims; their claim amount is treated as zero.
WITH claims_per_policy AS (
  SELECT policy_id,SUM(claim_amount) AS total_claim_amount
  FROM claims GROUP BY policy_id
)
SELECT pr.product_id,pr.product_name,
       SUM(p.annual_premium) AS total_annual_premium,
       SUM(COALESCE(cp.total_claim_amount,0)) AS total_claim_amount,
       ROUND(100.0*SUM(COALESCE(cp.total_claim_amount,0))/
             NULLIF(SUM(p.annual_premium),0),2) AS claim_ratio_percent
FROM products pr
INNER JOIN policies p ON p.product_id=pr.product_id
LEFT JOIN claims_per_policy cp ON cp.policy_id=p.policy_id
GROUP BY pr.product_id,pr.product_name
ORDER BY claim_ratio_percent DESC;

-- 5. Policies without claims.
-- LEFT JOIN + IS NULL finds policies with no matching claim.
SELECT p.policy_id,
       CONCAT(SUBSTRING(p.policy_number,1,8),'****',SUBSTRING(p.policy_number,-4)) AS masked_policy_number,
       c.customer_name,pr.product_name,p.status,p.annual_premium
FROM policies p
INNER JOIN customers c ON c.customer_id=p.customer_id
INNER JOIN products pr ON pr.product_id=p.product_id
LEFT JOIN claims cl ON cl.policy_id=p.policy_id
WHERE cl.claim_id IS NULL
ORDER BY p.policy_id;

-- 6. Average premium by age band.
-- CROSS JOIN generates all age-band/customer combinations.
-- LEFT JOIN preserves bands/customers even if they have no active policy.
WITH age_bands AS (
  SELECT 1 AS band_order,'Under 25' AS age_band,0 AS min_age,24 AS max_age
  UNION ALL SELECT 2,'25-39',25,39
  UNION ALL SELECT 3,'40-59',40,59
  UNION ALL SELECT 4,'60+',60,200
),
customer_ages AS (
  SELECT customer_id,customer_name,
         TIMESTAMPDIFF(YEAR,date_of_birth,CURDATE()) AS age
  FROM customers
)
SELECT b.age_band,COUNT(DISTINCT ca.customer_id) AS customer_count,
       COUNT(p.policy_id) AS policy_count,
       ROUND(AVG(p.annual_premium),2) AS average_annual_premium
FROM age_bands b
CROSS JOIN customer_ages ca
LEFT JOIN policies p
  ON p.customer_id=ca.customer_id
 AND p.status='ACTIVE'
 AND ca.age BETWEEN b.min_age AND b.max_age
GROUP BY b.band_order,b.age_band
ORDER BY b.band_order;

-- 7. Monthly new policies.
-- LEFT JOIN ensures products with zero new policies are also reported.
-- Current month: first day inclusive, first day of next month exclusive.
SELECT pr.product_name,COUNT(p.policy_id) AS new_policies_this_month
FROM products pr
LEFT JOIN policies p
  ON p.product_id=pr.product_id
 AND p.start_date>=DATE_SUB(DATE_ADD(LAST_DAY(CURDATE()),INTERVAL 1 DAY),INTERVAL 1 MONTH)
 AND p.start_date<DATE_ADD(LAST_DAY(CURDATE()),INTERVAL 1 DAY)
GROUP BY pr.product_id,pr.product_name
ORDER BY new_policies_this_month DESC,pr.product_name;

-- 8. Top five agents by total policy premium.
-- INNER JOIN includes agents who have sold at least one policy.
SELECT a.agent_id,a.agent_name,a.branch_name,
       COUNT(p.policy_id) AS policies_sold,
       SUM(p.annual_premium) AS total_annual_premium
FROM agents a
INNER JOIN policies p ON p.agent_id=a.agent_id
GROUP BY a.agent_id,a.agent_name,a.branch_name
ORDER BY total_annual_premium DESC,a.agent_id
LIMIT 5;

-- Additional requirement: products whose claim ratio is above 60%.
-- GROUP BY calculates one ratio per product; HAVING filters aggregate results.
WITH claims_per_policy AS (
  SELECT policy_id,SUM(claim_amount) AS total_claim_amount
  FROM claims GROUP BY policy_id
)
SELECT pr.product_name,
       SUM(p.annual_premium) AS total_annual_premium,
       SUM(COALESCE(cp.total_claim_amount,0)) AS total_claim_amount,
       ROUND(100.0*SUM(COALESCE(cp.total_claim_amount,0))/
             NULLIF(SUM(p.annual_premium),0),2) AS claim_ratio_percent
FROM products pr
INNER JOIN policies p ON p.product_id=pr.product_id
LEFT JOIN claims_per_policy cp ON cp.policy_id=p.policy_id
GROUP BY pr.product_id,pr.product_name
HAVING SUM(COALESCE(cp.total_claim_amount,0))/
       NULLIF(SUM(p.annual_premium),0)>0.60
ORDER BY claim_ratio_percent DESC;

-- Function examples: DATE_ADD, DATEDIFF, CASE, CONCAT and SUBSTRING.
SELECT CURDATE() AS report_date,
       DATE_ADD(CURDATE(),INTERVAL 30 DAY) AS date_30_days_from_now,
       DATEDIFF(DATE_ADD(CURDATE(),INTERVAL 30 DAY),CURDATE()) AS days_in_window,
       CASE
         WHEN TIMESTAMPDIFF(YEAR,'2001-02-11',CURDATE())<25 THEN 'Under 25'
         WHEN TIMESTAMPDIFF(YEAR,'2001-02-11',CURDATE())<40 THEN '25-39'
         WHEN TIMESTAMPDIFF(YEAR,'2001-02-11',CURDATE())<60 THEN '40-59'
         ELSE '60+'
       END AS example_age_band,
       CONCAT(SUBSTRING('POL-HEALTH-0001',1,8),'****',
              SUBSTRING('POL-HEALTH-0001',-4)) AS masked_policy_number;
