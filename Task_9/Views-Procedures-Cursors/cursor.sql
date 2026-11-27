USE telecom_db;
DROP PROCEDURE IF EXISTS sp_notify_low_balance_cursor;
DELIMITER //
CREATE PROCEDURE sp_notify_low_balance_cursor()
BEGIN
    DECLARE v_subscriber_id INT;
    DECLARE v_done INT DEFAULT 0;

    -- Declare cursor
    DECLARE subscriber_cursor CURSOR FOR
        SELECT subscriber_id
        FROM subscribers
        WHERE user_type = 'Prepaid'
        AND balance < 50;

    -- Declare NOT FOUND handler
    DECLARE CONTINUE HANDLER FOR NOT FOUND
        SET v_done = 1;

    -- Open cursor
    OPEN subscriber_cursor;
    read_loop: LOOP
        -- Fetch subscriber ID
        FETCH subscriber_cursor
        INTO v_subscriber_id;

        -- Check whether all records are fetched
        IF v_done = 1 THEN
            LEAVE read_loop;
        END IF;

        -- Insert notification
        INSERT INTO notifications
        (subscriber_id, message, notification_date)
        VALUES
        (
            v_subscriber_id,
            'Your prepaid balance is below 50 units. Please recharge.',
            CURDATE()
        );
    END LOOP;
    -- Close cursor
    CLOSE subscriber_cursor;

END //
DELIMITER ;
CALL sp_notify_low_balance_cursor();
select * from notifications;

-- Cursor approach
DELETE FROM notifications;

SET @start_time = NOW(6);

CALL sp_notify_low_balance_cursor();

SET @cursor_time = TIMESTAMPDIFF(
    MICROSECOND,
    @start_time,
    NOW(6)
);


-- Set-based approach
DELETE FROM notifications;

SET @start_time = NOW(6);

INSERT INTO notifications
(subscriber_id, message, notification_date)
SELECT
    subscriber_id,
    'Your prepaid balance is below 50 units. Please recharge.',
    CURDATE()
FROM subscribers
WHERE user_type = 'Prepaid'
AND balance < 50;

SET @set_time = TIMESTAMPDIFF(
    MICROSECOND,
    @start_time,
    NOW(6)
);

-- Final comparison
SELECT
    @cursor_time AS Cursor_Time_Microseconds,
    @set_time AS Set_Based_Time_Microseconds;