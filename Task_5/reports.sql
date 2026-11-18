-- Telecom Usage and Billing Reports
-- SQL dialect: MySQL 8.0+
--
-- ASSUMED TABLE STRUCTURE (adjust column names if your supplied schema differs):
-- subscribers(subscriber_id, subscriber_name, circle_id, plan_id, data_limit_gb)
-- plans(plan_id, plan_name, monthly_rental)
-- call_records(call_id, subscriber_id, call_date, duration_minutes, data_used_gb)
-- invoices(invoice_id, subscriber_id, invoice_number, invoice_date, due_date,
--          paid_date, amount, invoice_status)
-- circles(circle_id, circle_name)
--
-- Relationship assumptions:
-- subscribers.plan_id -> plans.plan_id
-- subscribers.circle_id -> circles.circle_id
-- call_records.subscriber_id -> subscribers.subscriber_id
-- invoices.subscriber_id -> subscribers.subscriber_id
--
-- If data usage is stored in MB, convert the data-limit comparison accordingly.
-- Run each SELECT separately. These are reporting queries and do not modify data.

USE telecom_db;

-- 1. Total call minutes per plan
-- Purpose: Shows the total voice-call duration recorded for each plan.
-- Expected output: One row per plan with total call minutes.
SELECT
    p.plan_id,
    p.plan_name,
    COALESCE(SUM(cr.duration_minutes), 0) AS total_call_minutes
FROM plans p
LEFT JOIN subscribers s ON s.plan_id = p.plan_id
LEFT JOIN call_records cr ON cr.subscriber_id = s.subscriber_id
GROUP BY p.plan_id, p.plan_name
ORDER BY total_call_minutes DESC;

-- 2. Subscribers exceeding their data limit
-- Purpose: Finds subscribers whose total recorded data usage is above their plan limit.
-- Expected output: Subscriber, plan, data limit, actual usage and excess usage (GB).
SELECT
    s.subscriber_id,
    s.subscriber_name,
    p.plan_name,
    s.data_limit_gb,
    SUM(cr.data_used_gb) AS total_data_used_gb,
    SUM(cr.data_used_gb) - s.data_limit_gb AS excess_data_gb
FROM subscribers s
JOIN plans p ON p.plan_id = s.plan_id
JOIN call_records cr ON cr.subscriber_id = s.subscriber_id
GROUP BY
    s.subscriber_id, s.subscriber_name, p.plan_name, s.data_limit_gb
HAVING SUM(cr.data_used_gb) > s.data_limit_gb
ORDER BY excess_data_gb DESC;

-- 3. Month-wise revenue
-- Purpose: Calculates invoice revenue grouped by invoice month.
-- Expected output: One row per month with total invoiced revenue.
-- This uses invoice_date and includes invoices regardless of payment status.
SELECT
    DATE_FORMAT(invoice_date, '%Y-%m') AS revenue_month,
    SUM(amount) AS total_revenue
FROM invoices
GROUP BY DATE_FORMAT(invoice_date, '%Y-%m')
ORDER BY revenue_month;

-- 4. Invoices overdue by more than 15 days
-- Purpose: Lists unpaid/part-paid invoices whose due date was more than 15 days ago.
-- Expected output: Invoice details and number of days overdue.
SELECT
    invoice_id,
    invoice_number,
    subscriber_id,
    due_date,
    amount,
    DATEDIFF(CURDATE(), due_date) AS days_overdue
FROM invoices
WHERE due_date < DATE_SUB(CURDATE(), INTERVAL 15 DAY)
  AND (paid_date IS NULL OR invoice_status <> 'PAID')
ORDER BY days_overdue DESC;

-- 5. Subscribers with no usage
-- Purpose: Finds subscribers who have no call/data usage records.
-- Expected output: Subscriber ID and name for subscribers with no matching call record.
SELECT
    s.subscriber_id,
    s.subscriber_name
FROM subscribers s
LEFT JOIN call_records cr ON cr.subscriber_id = s.subscriber_id
WHERE cr.call_id IS NULL
ORDER BY s.subscriber_id;

-- 6. ARPU by circle
-- Purpose: Calculates average revenue per subscriber (ARPU) for each circle.
-- Definition used: total invoiced amount / number of distinct subscribers
-- with invoices in that circle, for the full period present in invoices.
-- Expected output: Circle, subscriber count, revenue and ARPU.
SELECT
    c.circle_id,
    c.circle_name,
    COUNT(DISTINCT i.subscriber_id) AS billed_subscribers,
    SUM(i.amount) AS total_revenue,
    SUM(i.amount) / NULLIF(COUNT(DISTINCT i.subscriber_id), 0) AS arpu
FROM circles c
JOIN subscribers s ON s.circle_id = c.circle_id
JOIN invoices i ON i.subscriber_id = s.subscriber_id
GROUP BY c.circle_id, c.circle_name
ORDER BY arpu DESC;

-- 7. Plan popularity
-- Purpose: Counts the number of subscribers assigned to each plan.
-- Expected output: Plan name, subscriber count and percentage of all subscribers.
SELECT
    p.plan_id,
    p.plan_name,
    COUNT(s.subscriber_id) AS subscriber_count,
    ROUND(
        100.0 * COUNT(s.subscriber_id) /
        NULLIF((SELECT COUNT(*) FROM subscribers), 0),
        2
    ) AS subscriber_percentage
FROM plans p
LEFT JOIN subscribers s ON s.plan_id = p.plan_id
GROUP BY p.plan_id, p.plan_name
ORDER BY subscriber_count DESC;

-- 8. Top 10 data consumers
-- Purpose: Ranks subscribers by their total recorded data usage.
-- Expected output: Up to 10 subscribers, highest data usage first.
SELECT
    s.subscriber_id,
    s.subscriber_name,
    SUM(cr.data_used_gb) AS total_data_used_gb
FROM subscribers s
JOIN call_records cr ON cr.subscriber_id = s.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY total_data_used_gb DESC
LIMIT 10;

-- 9. String and date functions: formatted invoice number and due-date status
-- Purpose: Formats invoice identifiers and labels each invoice's due-date position.
-- Expected output: Formatted invoice number and status such as PAID, OVERDUE,
-- DUE TODAY or NOT YET DUE.
SELECT
    invoice_id,
    CONCAT('INV-', DATE_FORMAT(invoice_date, '%Y%m'), '-',
           LPAD(invoice_id, 6, '0')) AS formatted_invoice_number,
    DATE_FORMAT(due_date, '%d-%b-%Y') AS formatted_due_date,
    CASE
        WHEN paid_date IS NOT NULL OR invoice_status = 'PAID' THEN 'PAID'
        WHEN due_date < CURDATE() THEN 'OVERDUE'
        WHEN due_date = CURDATE() THEN 'DUE TODAY'
        ELSE 'NOT YET DUE'
    END AS due_date_status
FROM invoices
ORDER BY invoice_date DESC, invoice_id DESC;

-- 10. Demonstrating NULL effect on SUM and AVG, then fixing it
-- Purpose: Shows how a LEFT JOIN creates NULL usage values for subscribers
-- with no usage rows. SUM/AVG ignore NULL values; COUNT(*) still counts
-- the subscriber row. COALESCE changes a missing aggregate result to zero.
-- Expected output: Raw and corrected usage summaries.
SELECT
    s.subscriber_id,
    s.subscriber_name,
    SUM(cr.data_used_gb) AS sum_usage_raw,
    AVG(cr.data_used_gb) AS avg_usage_raw,
    COALESCE(SUM(cr.data_used_gb), 0) AS sum_usage_fixed,
    COALESCE(AVG(cr.data_used_gb), 0) AS avg_usage_fixed
FROM subscribers s
LEFT JOIN call_records cr ON cr.subscriber_id = s.subscriber_id
GROUP BY s.subscriber_id, s.subscriber_name
ORDER BY s.subscriber_id;

-- 10A. Overall NULL demonstration:
-- SUM and AVG ignore NULL values. IFNULL/COALESCE can replace each missing
-- row value with 0 before aggregation. This changes the average denominator
-- because zero-valued rows are included.
SELECT
    SUM(cr.data_used_gb) AS sum_ignoring_nulls,
    AVG(cr.data_used_gb) AS avg_ignoring_nulls,
    SUM(IFNULL(cr.data_used_gb, 0)) AS sum_with_null_as_zero,
    AVG(COALESCE(cr.data_used_gb, 0)) AS avg_with_null_as_zero
FROM subscribers s
LEFT JOIN call_records cr ON cr.subscriber_id = s.subscriber_id;

-- 11. Revenue per plan and circle (JOIN + GROUP BY + aggregate)
-- Purpose: Summarizes invoiced revenue by plan and subscriber circle.
-- Expected output: One row for each plan/circle combination with invoice count
-- and total revenue.
SELECT
    p.plan_name,
    c.circle_name,
    COUNT(i.invoice_id) AS invoice_count,
    COALESCE(SUM(i.amount), 0) AS total_revenue
FROM subscribers s
JOIN plans p ON p.plan_id = s.plan_id
JOIN circles c ON c.circle_id = s.circle_id
LEFT JOIN invoices i ON i.subscriber_id = s.subscriber_id
GROUP BY p.plan_id, p.plan_name, c.circle_id, c.circle_name
ORDER BY p.plan_name, c.circle_name;

-- END OF REPORT QUERIES
