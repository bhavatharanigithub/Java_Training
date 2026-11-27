USE telecom_db;
 
-- task 2 Write sp_recharge with validation of amount and plan, transactional update of the balance
-- and an insert into the recharge history return the new balance as an OUT parameter

-- task 5 Show an error handled with DECLARE ... HANDLER FOR SQLEXCEPTION and SIGNAL.
DELIMITER //
CREATE PROCEDURE sp_recharge(
    IN p_subscriber_id INT,
    IN p_plan_id INT,
    IN p_amount DECIMAL(10,2),
    OUT p_new_balance DECIMAL(10,2)
)
BEGIN
    DECLARE v_plan_amount DECIMAL(10,2);
    DECLARE v_current_balance DECIMAL(10,2);
    DECLARE v_subscriber_count INT DEFAULT 0;
    DECLARE v_plan_count INT DEFAULT 0;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    -- Validate recharge amount
    IF p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Recharge amount must be positive';
    END IF;

    -- Check subscriber existence
    SELECT COUNT(*)
    INTO v_subscriber_count
    FROM subscribers
    WHERE subscriber_id = p_subscriber_id;

    IF v_subscriber_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Subscriber does not exist';
    END IF;

    -- Check recharge plan
    SELECT COUNT(*)
    INTO v_plan_count
    FROM recharge_plans
    WHERE plan_id = p_plan_id;

    IF v_plan_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Invalid recharge plan';
    END IF;

    SELECT recharge_amount
    INTO v_plan_amount
    FROM recharge_plans
    WHERE plan_id = p_plan_id;

    -- Validate recharge amount against plan
    IF p_amount <> v_plan_amount THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Recharge amount does not match plan';
    END IF;

    START TRANSACTION;

    -- Update subscriber balance
    UPDATE subscribers
    SET balance = balance + p_amount
    WHERE subscriber_id = p_subscriber_id;

    -- Insert recharge history
    INSERT INTO recharge_history
    (subscriber_id, plan_id, recharge_amount, recharge_date)
    VALUES
    (p_subscriber_id, p_plan_id, p_amount, CURDATE());

    -- Retrieve updated balance
    SELECT balance
    INTO p_new_balance
    FROM subscribers
    WHERE subscriber_id = p_subscriber_id;
    COMMIT;
END //
DELIMITER ;
CALL sp_recharge(1, 1, 99, @new_balance);
SELECT @new_balance AS Updated_Balance;
SELECT * FROM subscribers
WHERE subscriber_id = 1;

SELECT * FROM recharge_history
WHERE subscriber_id = 1;
-- testing with invalid inputs and plans
CALL sp_recharge(1, 1, -50, @new_balance);
CALL sp_recharge(1, 99, -50, @new_balance);


-- task 3 Create fn_validity_days_left and use it in a query.
DELIMITER //

CREATE FUNCTION fn_validity_days_left(
    p_subscriber_id INT
)
RETURNS INT
DETERMINISTIC
READS SQL DATA
BEGIN
    DECLARE v_days_left INT;

    SELECT DATEDIFF(validity_date, CURDATE())
    INTO v_days_left
    FROM subscribers
    WHERE subscriber_id = p_subscriber_id;

    RETURN v_days_left;
END //

DELIMITER ;

-- testing part
SELECT fn_validity_days_left(3) AS Days_Left;
SELECT
    subscriber_id,
    subscriber_name,
    validity_date,
    fn_validity_days_left(subscriber_id) AS days_left
FROM subscribers;
