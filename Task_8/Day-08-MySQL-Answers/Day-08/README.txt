DAY 8 - MYSQL 8.4 LTS ANSWER FILES

Files:
1. transfer.sql
   Creates bank_db, sample accounts, a safe transfer stored procedure,
   successful transfer, deliberate rollback demonstration, and SAVEPOINT
   example that removes only the fee while retaining the transfer.

2. statement_cte.sql
   Creates bank_statement_db and sample November 2026 transactions.
   Uses a CTE, ROW_NUMBER(), and LAG() to produce a monthly statement.

3. isolation-level-note.txt
   Step-by-step two-session experiments for autocommit, READ COMMITTED,
   and REPEATABLE READ, plus a comparison of isolation levels.

HOW TO RUN:
- Open MySQL Workbench and connect to your local MySQL 8.4 server.
- Open transfer.sql and execute the entire script.
- Open statement_cte.sql and execute the entire script.
- Follow isolation-level-note.txt using two separate query tabs/sessions.

IMPORTANT:
- transfer.sql creates/uses bank_db.
- statement_cte.sql creates/uses bank_statement_db.
- The scripts are training examples, not production banking software.
- Run the scripts on a test database, not a real banking database.
- The deliberate failure section uses ROLLBACK after a debit to simulate
  a failure between debit and credit. The stored procedure also has an
  exception handler that rolls back on SQL errors.
