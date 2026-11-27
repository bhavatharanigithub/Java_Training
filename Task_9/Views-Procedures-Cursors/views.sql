USE telecom_db;

CREATE VIEW vw_prepaid_subscribers AS
SELECT
    subscriber_id,
    subscriber_name,
    phone_number,
    balance,
    plan_id,
    validity_date
FROM subscribers
WHERE user_type = 'Prepaid';

SELECT * FROM vw_prepaid_subscribers;
CREATE VIEW vw_recharge_summary AS
SELECT
    s.subscriber_id,
    s.subscriber_name,
    rp.plan_name,
    COUNT(rh.recharge_id) AS total_recharges,
    SUM(rh.recharge_amount) AS total_recharge_amount,
    MAX(rh.recharge_date) AS last_recharge_date
FROM subscribers s
JOIN recharge_history rh
    ON s.subscriber_id = rh.subscriber_id
JOIN recharge_plans rp
    ON rh.plan_id = rp.plan_id
GROUP BY
    s.subscriber_id,
    s.subscriber_name,
    rp.plan_name;
    SELECT * FROM vw_recharge_summary;
    
    SHOW FULL TABLES
WHERE Table_type = 'VIEW';