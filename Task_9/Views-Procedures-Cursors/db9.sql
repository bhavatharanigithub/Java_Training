CREATE DATABASE telecom_db;
USE telecom_db;
CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY AUTO_INCREMENT,
    subscriber_name VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(100),
    user_type VARCHAR(20),
    balance DECIMAL(10,2),
    plan_id INT,
    validity_date DATE
);
CREATE TABLE recharge_plans (
    plan_id INT PRIMARY KEY AUTO_INCREMENT,
    plan_name VARCHAR(50),
    recharge_amount DECIMAL(10,2),
    validity_days INT
);
CREATE TABLE recharge_history (
    recharge_id INT PRIMARY KEY AUTO_INCREMENT,
    subscriber_id INT,
    plan_id INT,
    recharge_amount DECIMAL(10,2),
    recharge_date DATE,
    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id),
    FOREIGN KEY (plan_id)
        REFERENCES recharge_plans(plan_id)
);
CREATE TABLE notifications (
    notification_id INT PRIMARY KEY AUTO_INCREMENT,
    subscriber_id INT,
    message VARCHAR(255),
    notification_date DATE,
    FOREIGN KEY (subscriber_id)
        REFERENCES subscribers(subscriber_id)
);
INSERT INTO recharge_plans
(plan_name, recharge_amount, validity_days)
VALUES
('Basic Plan', 99, 28),
('Smart Plan', 199, 56),
('Premium Plan', 299, 84),
('Unlimited Plan', 499, 90);

INSERT INTO subscribers
(subscriber_name, phone_number, email, user_type,
 balance, plan_id, validity_date)
VALUES
('Arun', '9876543210', 'arun@gmail.com', 'Prepaid', 25, 1, '2026-12-10'),
('Priya', '9876543211', 'priya@gmail.com', 'Prepaid', 40, 2, '2026-12-15'),
('Rahul', '9876543212', 'rahul@gmail.com', 'Prepaid', 150, 3, '2027-01-10'),
('Divya', '9876543213', 'divya@gmail.com', 'Prepaid', 15, 1, '2026-12-05'),
('Karthik', '9876543214', 'karthik@gmail.com', 'Postpaid', 200, 4, '2027-01-15'),
('Sneha', '9876543215', 'sneha@gmail.com', 'Prepaid', 75, 2, '2026-12-20'),
('Vijay', '9876543216', 'vijay@gmail.com', 'Prepaid', 10, 3, '2026-12-08'),
('Meena', '9876543217', 'meena@gmail.com', 'Postpaid', 300, 4, '2027-01-20');

INSERT INTO recharge_history
(subscriber_id, plan_id, recharge_amount, recharge_date)
VALUES
(1, 1, 99, '2026-11-10'),
(2, 2, 199, '2026-11-12'),
(3, 3, 299, '2026-11-13'),
(4, 1, 99, '2026-11-14'),
(5, 4, 499, '2026-11-15'),
(6, 2, 199, '2026-11-16'),
(7, 3, 299, '2026-11-17');

SELECT * FROM recharge_plans;

SELECT * FROM subscribers;

SELECT * FROM recharge_history;

SELECT * FROM notifications;