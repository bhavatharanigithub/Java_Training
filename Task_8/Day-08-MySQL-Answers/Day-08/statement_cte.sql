-- Day 8: Monthly Bank Statement using CTEs and Window Functions
-- MySQL 8.4 LTS / InnoDB
-- Run independently. This file creates/uses bank_statement_db.

CREATE DATABASE IF NOT EXISTS bank_statement_db;
USE bank_statement_db;

DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;

CREATE TABLE accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(100) NOT NULL
) ENGINE = InnoDB;

CREATE TABLE transactions (
    transaction_id BIGINT PRIMARY KEY AUTO_INCREMENT,
    account_id INT NOT NULL,
    transaction_date DATETIME NOT NULL,
    transaction_type ENUM('DEBIT', 'CREDIT') NOT NULL,
    amount DECIMAL(12,2) NOT NULL,
    balance_after DECIMAL(12,2) NOT NULL,
    description VARCHAR(255),
    CONSTRAINT fk_statement_account
        FOREIGN KEY (account_id) REFERENCES accounts(account_id),
    CONSTRAINT chk_statement_amount CHECK (amount > 0)
) ENGINE = InnoDB;

INSERT INTO accounts (account_id, account_holder) VALUES
(101, 'Arun'),
(102, 'Priya');

-- The balance_after values are the account balances after each transaction.
INSERT INTO transactions
    (account_id, transaction_date, transaction_type, amount, balance_after, description)
VALUES
(101, '2026-11-01 09:00:00', 'CREDIT', 5000.00, 15000.00, 'Salary credit'),
(101, '2026-11-03 10:30:00', 'DEBIT',  2000.00, 13000.00, 'Rent payment'),
(101, '2026-11-10 14:15:00', 'DEBIT',   500.00, 12500.00, 'Shopping'),
(101, '2026-11-18 11:00:00', 'CREDIT', 1500.00, 14000.00, 'Refund received'),
(101, '2026-11-25 16:45:00', 'DEBIT',  1000.00, 13000.00, 'Utility bill'),
(102, '2026-11-02 08:30:00', 'CREDIT', 3000.00,  8000.00, 'Salary credit'),
(102, '2026-11-06 12:00:00', 'DEBIT',   750.00,  7250.00, 'Groceries'),
(102, '2026-11-20 17:30:00', 'CREDIT',  200.00,  7450.00, 'Cashback');

-- TASK 1: CTE + ROW_NUMBER() + LAG()
-- Change the date range to the month you want to display.
WITH monthly_statement AS (
    SELECT
        t.transaction_id,
        t.account_id,
        a.account_holder,
        t.transaction_date,
        t.transaction_type,
        t.amount,
        t.balance_after,
        t.description
    FROM transactions AS t
    JOIN accounts AS a
      ON a.account_id = t.account_id
    WHERE t.transaction_date >= '2026-11-01'
      AND t.transaction_date <  '2026-12-01'
),
statement_with_windows AS (
    SELECT
        transaction_id,
        account_id,
        account_holder,
        transaction_date,
        transaction_type,
        amount,
        description,
        ROW_NUMBER() OVER (
            PARTITION BY account_id
            ORDER BY transaction_date, transaction_id
        ) AS transaction_number,
        LAG(balance_after) OVER (
            PARTITION BY account_id
            ORDER BY transaction_date, transaction_id
        ) AS previous_balance,
        balance_after AS current_balance
    FROM monthly_statement
)
SELECT
    account_id,
    account_holder,
    transaction_number,
    transaction_id,
    transaction_date,
    transaction_type,
    amount,
    previous_balance,
    current_balance,
    description
FROM statement_with_windows
ORDER BY account_id, transaction_date, transaction_id;

-- TASK 2: Optional statement summary by account for the same month.
WITH monthly_totals AS (
    SELECT
        account_id,
        SUM(CASE WHEN transaction_type = 'CREDIT' THEN amount ELSE 0 END) AS total_credits,
        SUM(CASE WHEN transaction_type = 'DEBIT'  THEN amount ELSE 0 END) AS total_debits,
        COUNT(*) AS transaction_count
    FROM transactions
    WHERE transaction_date >= '2026-11-01'
      AND transaction_date <  '2026-12-01'
    GROUP BY account_id
)
SELECT
    a.account_id,
    a.account_holder,
    COALESCE(m.transaction_count, 0) AS transaction_count,
    COALESCE(m.total_credits, 0.00) AS total_credits,
    COALESCE(m.total_debits, 0.00) AS total_debits
FROM accounts AS a
LEFT JOIN monthly_totals AS m
  ON m.account_id = a.account_id
ORDER BY a.account_id;

-- TASK 3: Demonstrate LAG() without a monthly filter, for all history.
SELECT
    account_id,
    transaction_id,
    transaction_date,
    balance_after,
    LAG(balance_after, 1) OVER (
        PARTITION BY account_id
        ORDER BY transaction_date, transaction_id
    ) AS previous_transaction_balance
FROM transactions
ORDER BY account_id, transaction_date, transaction_id;
