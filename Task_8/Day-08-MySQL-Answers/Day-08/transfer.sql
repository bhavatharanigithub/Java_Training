-- Day 8: Bank Funds Transfer
-- MySQL 8.4 LTS / InnoDB
-- Run this file in MySQL Workbench or the MySQL command-line client.
-- WARNING: This script creates a fresh training database named bank_db.

CREATE DATABASE IF NOT EXISTS bank_db;
USE bank_db;

DROP PROCEDURE IF EXISTS transfer_funds;
DROP TABLE IF EXISTS account_transactions;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id      INT PRIMARY KEY,
    account_holder  VARCHAR(100) NOT NULL,
    balance         DECIMAL(12,2) NOT NULL,
    status          ENUM('ACTIVE', 'INACTIVE', 'BLOCKED') NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT chk_nonnegative_balance CHECK (balance >= 0)
) ENGINE = InnoDB;

CREATE TABLE account_transactions (
    transaction_id   BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id       INT NOT NULL,
    transaction_type ENUM('DEBIT', 'CREDIT', 'FEE') NOT NULL,
    amount           DECIMAL(12,2) NOT NULL,
    balance_after    DECIMAL(12,2) NOT NULL,
    description      VARCHAR(255),
    transaction_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_transaction_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_positive_amount CHECK (amount > 0)
) ENGINE = InnoDB;

INSERT INTO accounts (account_id, account_holder, balance, status) VALUES
(101, 'Arun',  10000.00, 'ACTIVE'),
(102, 'Priya',  5000.00, 'ACTIVE'),
(103, 'Ravi',   2000.00, 'INACTIVE');

SELECT 'Initial account balances' AS evidence;
SELECT * FROM accounts ORDER BY account_id;

DELIMITER //

-- Reusable transfer routine.
-- The handler guarantees that any SQL error rolls back the complete transfer.
CREATE PROCEDURE transfer_funds(
    IN p_from_account INT,
    IN p_to_account   INT,
    IN p_amount       DECIMAL(12,2)
)
BEGIN
    DECLARE v_from_balance DECIMAL(12,2);
    DECLARE v_from_status VARCHAR(20);
    DECLARE v_to_status   VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    IF p_amount IS NULL OR p_amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Transfer amount must be greater than zero';
    END IF;

    IF p_from_account = p_to_account THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Source and destination accounts must be different';
    END IF;

    START TRANSACTION;

    -- Lock and validate the source account.
    SELECT balance, status
      INTO v_from_balance, v_from_status
      FROM accounts
     WHERE account_id = p_from_account
     FOR UPDATE;

    IF v_from_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Source account does not exist';
    END IF;

    IF v_from_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Source account is not active';
    END IF;

    IF v_from_balance < p_amount THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Insufficient funds';
    END IF;

    -- Lock and validate the destination account.
    SELECT status
      INTO v_to_status
      FROM accounts
     WHERE account_id = p_to_account
     FOR UPDATE;

    IF v_to_status IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Destination account does not exist';
    END IF;

    IF v_to_status <> 'ACTIVE' THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'Destination account is not active';
    END IF;

    -- Debit sender, then record the resulting balance.
    UPDATE accounts
       SET balance = balance - p_amount
     WHERE account_id = p_from_account;

    SELECT balance INTO v_from_balance
      FROM accounts
     WHERE account_id = p_from_account;

    INSERT INTO account_transactions
        (account_id, transaction_type, amount, balance_after, description)
    VALUES
        (p_from_account, 'DEBIT', p_amount, v_from_balance,
         CONCAT('Transfer to account ', p_to_account));

    -- Credit receiver, then record the resulting balance.
    UPDATE accounts
       SET balance = balance + p_amount
     WHERE account_id = p_to_account;

    INSERT INTO account_transactions
        (account_id, transaction_type, amount, balance_after, description)
    SELECT p_to_account, 'CREDIT', p_amount, balance,
           CONCAT('Transfer from account ', p_from_account)
      FROM accounts
     WHERE account_id = p_to_account;

    COMMIT;
END//

DELIMITER ;

-- TASK 1: Successful transfer of 2,000 from Arun (101) to Priya (102).
CALL transfer_funds(101, 102, 2000.00);

SELECT 'After successful transfer: Arun should have 8,000; Priya should have 7,000'
       AS evidence;
SELECT * FROM accounts WHERE account_id IN (101, 102) ORDER BY account_id;
SELECT * FROM account_transactions ORDER BY transaction_id;

-- TASK 2: Deliberate failure AFTER the debit.
-- This manual demonstration debits Arun, displays the temporary value,
-- then simulates a later-step failure by rolling back before the credit.
-- The account and ledger changes are both undone.
SELECT balance INTO @arun_before_failure
  FROM accounts WHERE account_id = 101;

SELECT balance INTO @priya_before_failure
  FROM accounts WHERE account_id = 102;

START TRANSACTION;

UPDATE accounts
   SET balance = balance - 500.00
 WHERE account_id = 101
   AND status = 'ACTIVE'
   AND balance >= 500.00;

SELECT 'Temporary balance after debit, before simulated failure' AS evidence;
SELECT account_id, account_holder, balance
  FROM accounts WHERE account_id = 101;

-- Simulate an error occurring before the receiver is credited.
ROLLBACK;

SELECT 'Rollback evidence: balances must match the values before the failed attempt'
       AS evidence;
SELECT
    a.account_id,
    a.account_holder,
    a.balance,
    CASE
      WHEN a.account_id = 101 AND a.balance = @arun_before_failure THEN 'UNCHANGED'
      WHEN a.account_id = 102 AND a.balance = @priya_before_failure THEN 'UNCHANGED'
      ELSE 'CHECK RESULT'
    END AS rollback_check
FROM accounts AS a
WHERE a.account_id IN (101, 102)
ORDER BY a.account_id;

-- TASK 3: SAVEPOINT - retain transfer but undo only the fee.
-- Start with Arun (101) transferring 1,000 to Priya (102).
START TRANSACTION;

-- Validate and lock both accounts before changing balances.
SELECT balance, status INTO @sender_balance, @sender_status
  FROM accounts WHERE account_id = 101 FOR UPDATE;
SELECT status INTO @receiver_status
  FROM accounts WHERE account_id = 102 FOR UPDATE;

-- Stop this demonstration if the accounts cannot safely be used.
-- The sample data has both accounts ACTIVE and enough funds.
UPDATE accounts
   SET balance = balance - 1000.00
 WHERE account_id = 101
   AND status = 'ACTIVE'
   AND balance >= 1000.00;

UPDATE accounts
   SET balance = balance + 1000.00
 WHERE account_id = 102
   AND status = 'ACTIVE';

INSERT INTO account_transactions
    (account_id, transaction_type, amount, balance_after, description)
SELECT 101, 'DEBIT', 1000.00, balance, 'Transfer to account 102'
  FROM accounts WHERE account_id = 101;

INSERT INTO account_transactions
    (account_id, transaction_type, amount, balance_after, description)
SELECT 102, 'CREDIT', 1000.00, balance, 'Transfer from account 101'
  FROM accounts WHERE account_id = 102;

SAVEPOINT after_transfer;

-- Fee-posting step: debit a 50 fee from Arun and add a fee ledger row.
UPDATE accounts
   SET balance = balance - 50.00
 WHERE account_id = 101;

INSERT INTO account_transactions
    (account_id, transaction_type, amount, balance_after, description)
SELECT 101, 'FEE', 50.00, balance, 'Transfer fee (will be reversed)'
  FROM accounts WHERE account_id = 101;

-- Undo only the fee update and fee ledger insert.
ROLLBACK TO SAVEPOINT after_transfer;

-- The transfer remains in the transaction; commit it.
COMMIT;

SELECT 'SAVEPOINT evidence: 1,000 transfer retained; 50 fee removed'
       AS evidence;
SELECT * FROM accounts WHERE account_id IN (101, 102) ORDER BY account_id;
SELECT * FROM account_transactions ORDER BY transaction_id;

-- TASK 1 validation examples: these calls should raise a clear error and roll back.
-- Uncomment one at a time to test:
-- CALL transfer_funds(101, 102, 999999.00); -- insufficient funds
-- CALL transfer_funds(103, 102, 100.00);    -- source account inactive
-- CALL transfer_funds(101, 103, 100.00);    -- destination account inactive

-- Final balances and transaction history.
SELECT * FROM accounts ORDER BY account_id;
SELECT * FROM account_transactions ORDER BY transaction_date, transaction_id;
