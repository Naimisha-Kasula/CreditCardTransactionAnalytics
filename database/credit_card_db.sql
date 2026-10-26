-- ==========================================================
-- PROJECT: Digital Fraud Detection & Transaction Risk Analytics
-- DATABASE: credit_card_db
-- TECHNOLOGY: MySQL + Python + Streamlit
-- FRAUD DETECTION: Rule-based (No Machine Learning)
-- ==========================================================

CREATE DATABASE IF NOT EXISTS credit_card_db;
USE credit_card_db;

-- 1. DROP EXISTING TABLES
DROP TABLE IF EXISTS fraud_alerts;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS accounts;
DROP TABLE IF EXISTS customers;


-- 2. CREATE CUSTOMERS TABLE
CREATE TABLE customers (
    customer_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    customer_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(15),
    city VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


-- 3. CREATE ACCOUNTS TABLE
CREATE TABLE accounts (
    account_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    account_number VARCHAR(20) UNIQUE NOT NULL,
    credit_limit DECIMAL(12,2) DEFAULT 50000.00,
    account_status VARCHAR(20) DEFAULT 'Active',

    CONSTRAINT fk_accounts_customer
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
);


-- 4. CREATE TRANSACTIONS TABLE
CREATE TABLE transactions (
    transaction_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    account_id INT NOT NULL,
    transaction_amount DECIMAL(12,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    merchant_name VARCHAR(100),
    location VARCHAR(100),
    device VARCHAR(100),
    transaction_type VARCHAR(30),
    transaction_status VARCHAR(30),

    CONSTRAINT fk_transactions_account
        FOREIGN KEY (account_id)
        REFERENCES accounts(account_id)
);


-- 5. CREATE FRAUD ALERTS TABLE
CREATE TABLE fraud_alerts (
    alert_id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT NOT NULL,
    risk_score INT DEFAULT 0,
    risk_level VARCHAR(20),
    alert_reason VARCHAR(255),
    alert_status VARCHAR(30) DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_fraud_alerts_transaction
        UNIQUE (transaction_id),

    CONSTRAINT fk_fraud_alerts_transaction
        FOREIGN KEY (transaction_id)
        REFERENCES transactions(transaction_id)
);


-- ==========================================================
-- 6. INSERT 30 CUSTOMERS
-- ==========================================================

INSERT INTO customers
(customer_id, customer_name, email, phone, city)
VALUES
(1, 'Surya', 'surya@gmail.com', '7843629150', 'Vijayawada'),
(2, 'Ananya Reddy', 'ananyareddy@gmail.com', '9165072843', 'Hyderabad'),
(3, 'Rahul Varma', 'rahulvarma@gmail.com', '6381947502', 'Bangalore'),
(4, 'Priya Sharma', 'priyasharma@gmail.com', '8294751630', 'Chennai'),
(5, 'Arjun Kumar', 'arjunkumar@gmail.com', '7016384925', 'Vijayawada'),
(6, 'Sneha Rao', 'sneharao@gmail.com', '8652047193', 'Hyderabad'),
(7, 'Kiran Patel', 'kiranpatel@gmail.com', '6928174305', 'Bangalore'),
(8, 'Divya Naidu', 'divyanaidu@gmail.com', '9735106824', 'Chennai'),
(9, 'Rohit Verma', 'rohitverma@gmail.com', '7462918350', 'Vijayawada'),
(10, 'Kavya Reddy', 'kavyareddy@gmail.com', '8906342715', 'Hyderabad'),
(11, 'Sai Teja', 'saiteja@gmail.com', '6174829503', 'Bangalore'),
(12, 'Meera Iyer', 'meeraiyer@gmail.com', '9582716403', 'Chennai'),
(13, 'Aditya Rao', 'adityarao@gmail.com', '8326905174', 'Vijayawada'),
(14, 'Pooja Singh', 'poojasingh@gmail.com', '7059428163', 'Hyderabad'),
(15, 'Vikram Reddy', 'vikramreddy@gmail.com', '8617394205', 'Bangalore'),
(16, 'Sravani Kumar', 'sravanikumar@gmail.com', '6792051843', 'Chennai'),
(17, 'Nikhil Sharma', 'nikhilsharma@gmail.com', '9348162075', 'Vijayawada'),
(18, 'Lakshmi Prasad', 'lakshmiprasad@gmail.com', '7981635042', 'Hyderabad'),
(19, 'Harsha Vardhan', 'harshavardhan@gmail.com', '6248507391', 'Bangalore'),
(20, 'Keerthi Nair', 'keerthinair@gmail.com', '8794316052', 'Chennai'),
(21, 'Manoj Das', 'manojdas@gmail.com', '9617284035', 'Vijayawada'),
(22, 'Aishwarya Rao', 'aishwaryarao@gmail.com', '7368041952', 'Hyderabad'),
(23, 'Naveen Kumar', 'naveenkumar@gmail.com', '8042159673', 'Bangalore'),
(24, 'Neha Gupta', 'nehagupta@gmail.com', '6573918240', 'Chennai'),
(25, 'Sanjay Reddy', 'sanjayreddy@gmail.com', '9286041735', 'Vijayawada'),
(26, 'Bhavana Chowdary', 'bhavanachowdary@gmail.com', '7815402963', 'Hyderabad'),
(27, 'Abhishek Jain', 'abhishekjain@gmail.com', '6951738420', 'Bangalore'),
(28, 'Swathi Krishna', 'swathikrishna@gmail.com', '8529473016', 'Chennai'),
(29, 'Tarun Reddy', 'tarunreddy@gmail.com', '7130864259', 'Vijayawada'),
(30, 'Deepika Sharma', 'deepikasharma@gmail.com', '9462537180', 'Hyderabad');


-- ==========================================================
-- 7. INSERT 30 ACCOUNTS
-- ==========================================================

INSERT INTO accounts
(account_id, customer_id, account_number, credit_limit, account_status)
VALUES
(1,1,'ACC00001',100000,'Active'),
(2,2,'ACC00002',100000,'Active'),
(3,3,'ACC00003',100000,'Active'),
(4,4,'ACC00004',100000,'Active'),
(5,5,'ACC00005',100000,'Active'),
(6,6,'ACC00006',100000,'Active'),
(7,7,'ACC00007',100000,'Active'),
(8,8,'ACC00008',100000,'Active'),
(9,9,'ACC00009',100000,'Active'),
(10,10,'ACC00010',100000,'Active'),
(11,11,'ACC00011',100000,'Active'),
(12,12,'ACC00012',100000,'Active'),
(13,13,'ACC00013',100000,'Active'),
(14,14,'ACC00014',100000,'Active'),
(15,15,'ACC00015',100000,'Active'),
(16,16,'ACC00016',100000,'Active'),
(17,17,'ACC00017',100000,'Active'),
(18,18,'ACC00018',100000,'Active'),
(19,19,'ACC00019',100000,'Active'),
(20,20,'ACC00020',100000,'Active'),
(21,21,'ACC00021',100000,'Active'),
(22,22,'ACC00022',100000,'Active'),
(23,23,'ACC00023',100000,'Active'),
(24,24,'ACC00024',100000,'Active'),
(25,25,'ACC00025',100000,'Active'),
(26,26,'ACC00026',100000,'Active'),
(27,27,'ACC00027',100000,'Active'),
(28,28,'ACC00028',100000,'Active'),
(29,29,'ACC00029',100000,'Active'),
(30,30,'ACC00030',100000,'Active');


-- ==========================================================
-- 8. INSERT 100 TRANSACTIONS
-- ==========================================================

INSERT INTO transactions
(transaction_id, account_id, transaction_amount, transaction_date,
 merchant_name, location, device, transaction_type, transaction_status)
VALUES
(1,1,60100,'2026-10-12 01:00:00','Amazon','Vijayawada','Unknown Device','Online Payment','Success'),
(2,2,60200,'2026-10-12 01:05:00','Flipkart','Hyderabad','Unknown Device','Purchase','Success'),
(3,3,60300,'2026-10-12 01:10:00','Reliance Digital','Bangalore','Unknown Device','Online Payment','Success'),
(4,4,60400,'2026-10-12 01:15:00','Amazon','Chennai','Unknown Device','Purchase','Success'),
(5,5,60500,'2026-10-12 01:20:00','Flipkart','Vijayawada','Unknown Device','Online Payment','Success'),
(6,6,60600,'2026-10-12 01:25:00','Reliance Digital','Hyderabad','Unknown Device','Purchase','Success'),
(7,7,60700,'2026-10-12 01:30:00','Amazon','Bangalore','Unknown Device','Online Payment','Success'),
(8,8,60800,'2026-10-12 01:35:00','Flipkart','Chennai','Unknown Device','Purchase','Success'),
(9,9,60900,'2026-10-12 01:40:00','Reliance Digital','Vijayawada','Unknown Device','Online Payment','Success'),
(10,10,61000,'2026-10-12 01:45:00','Amazon','Hyderabad','Unknown Device','Purchase','Success'),
(11,11,61100,'2026-10-12 01:50:00','Flipkart','Bangalore','Unknown Device','Online Payment','Success'),
(12,12,61200,'2026-10-12 01:55:00','Reliance Digital','Chennai','Unknown Device','Purchase','Success'),
(13,13,61300,'2026-10-12 02:00:00','Amazon','Vijayawada','Unknown Device','Online Payment','Success'),
(14,14,61400,'2026-10-12 02:05:00','Flipkart','Hyderabad','Unknown Device','Purchase','Success'),
(15,15,61500,'2026-10-12 02:10:00','Reliance Digital','Bangalore','Unknown Device','Online Payment','Success');

-- Remaining 85 normal transactions are generated below.
-- This keeps the SQL shorter while still creating 100 transactions.
INSERT INTO transactions
(account_id, transaction_amount, transaction_date,
 merchant_name, location, device, transaction_type, transaction_status)
SELECT
    ((n - 16) % 30) + 1,
    1500 + (n * 100),
    DATE_ADD('2026-10-04 10:00:00', INTERVAL (n - 16) HOUR),
    CASE
        WHEN MOD(n, 3) = 0 THEN 'Amazon'
        WHEN MOD(n, 3) = 1 THEN 'Flipkart'
        ELSE 'Swiggy'
    END,
    CASE
        WHEN MOD(n, 4) = 0 THEN 'Hyderabad'
        WHEN MOD(n, 4) = 1 THEN 'Vijayawada'
        WHEN MOD(n, 4) = 2 THEN 'Bangalore'
        ELSE 'Chennai'
    END,
    CASE WHEN MOD(n, 5) = 0 THEN 'Laptop' ELSE 'Mobile' END,
    CASE WHEN MOD(n, 2) = 0 THEN 'Purchase' ELSE 'Online Payment' END,
    'Success'
FROM (
    SELECT 16 AS n UNION ALL SELECT 17 UNION ALL SELECT 18 UNION ALL
    SELECT 19 UNION ALL SELECT 20 UNION ALL SELECT 21 UNION ALL
    SELECT 22 UNION ALL SELECT 23 UNION ALL SELECT 24 UNION ALL
    SELECT 25 UNION ALL SELECT 26 UNION ALL SELECT 27 UNION ALL
    SELECT 28 UNION ALL SELECT 29 UNION ALL SELECT 30 UNION ALL
    SELECT 31 UNION ALL SELECT 32 UNION ALL SELECT 33 UNION ALL
    SELECT 34 UNION ALL SELECT 35 UNION ALL SELECT 36 UNION ALL
    SELECT 37 UNION ALL SELECT 38 UNION ALL SELECT 39 UNION ALL
    SELECT 40 UNION ALL SELECT 41 UNION ALL SELECT 42 UNION ALL
    SELECT 43 UNION ALL SELECT 44 UNION ALL SELECT 45 UNION ALL
    SELECT 46 UNION ALL SELECT 47 UNION ALL SELECT 48 UNION ALL
    SELECT 49 UNION ALL SELECT 50 UNION ALL SELECT 51 UNION ALL
    SELECT 52 UNION ALL SELECT 53 UNION ALL SELECT 54 UNION ALL
    SELECT 55 UNION ALL SELECT 56 UNION ALL SELECT 57 UNION ALL
    SELECT 58 UNION ALL SELECT 59 UNION ALL SELECT 60 UNION ALL
    SELECT 61 UNION ALL SELECT 62 UNION ALL SELECT 63 UNION ALL
    SELECT 64 UNION ALL SELECT 65 UNION ALL SELECT 66 UNION ALL
    SELECT 67 UNION ALL SELECT 68 UNION ALL SELECT 69 UNION ALL
    SELECT 70 UNION ALL SELECT 71 UNION ALL SELECT 72 UNION ALL
    SELECT 73 UNION ALL SELECT 74 UNION ALL SELECT 75 UNION ALL
    SELECT 76 UNION ALL SELECT 77 UNION ALL SELECT 78 UNION ALL
    SELECT 79 UNION ALL SELECT 80 UNION ALL SELECT 81 UNION ALL
    SELECT 82 UNION ALL SELECT 83 UNION ALL SELECT 84 UNION ALL
    SELECT 85 UNION ALL SELECT 86 UNION ALL SELECT 87 UNION ALL
    SELECT 88 UNION ALL SELECT 89 UNION ALL SELECT 90 UNION ALL
    SELECT 91 UNION ALL SELECT 92 UNION ALL SELECT 93 UNION ALL
    SELECT 94 UNION ALL SELECT 95 UNION ALL SELECT 96 UNION ALL
    SELECT 97 UNION ALL SELECT 98 UNION ALL SELECT 99 UNION ALL
    SELECT 100
) AS numbers;


-- ==========================================================
-- 9. INSERT 15 SAMPLE FRAUD ALERTS
-- ==========================================================

INSERT INTO fraud_alerts
(alert_id, transaction_id, risk_score, risk_level, alert_reason, alert_status)
VALUES
(1,1,65,'High','High amount, unknown device and unusual time','Pending'),
(2,2,65,'High','High amount, unknown device and unusual time','Pending'),
(3,3,65,'High','High amount, unknown device and unusual time','Pending'),
(4,4,65,'High','High amount, unknown device and unusual time','Pending'),
(5,5,65,'High','High amount, unknown device and unusual time','Pending'),
(6,6,65,'High','High amount, unknown device and unusual time','Pending'),
(7,7,65,'High','High amount, unknown device and unusual time','Pending'),
(8,8,65,'High','High amount, unknown device and unusual time','Pending'),
(9,9,65,'High','High amount, unknown device and unusual time','Pending'),
(10,10,65,'High','High amount, unknown device and unusual time','Pending'),
(11,11,65,'High','High amount, unknown device and unusual time','Pending'),
(12,12,65,'High','High amount, unknown device and unusual time','Pending'),
(13,13,65,'High','High amount, unknown device and unusual time','Pending'),
(14,14,65,'High','High amount, unknown device and unusual time','Pending'),
(15,15,65,'High','High amount, unknown device and unusual time','Pending');


-- ==========================================================
-- 10. VERIFY DATABASE RECORD COUNTS
-- ==========================================================

SELECT COUNT(*) AS total_customers FROM customers;
SELECT COUNT(*) AS total_accounts FROM accounts;
SELECT COUNT(*) AS total_transactions FROM transactions;
SELECT COUNT(*) AS total_fraud_alerts FROM fraud_alerts;


-- ==========================================================
-- 11. VIEW ALL CUSTOMERS
-- ==========================================================

SELECT *
FROM customers
ORDER BY customer_id;


-- ==========================================================
-- 12. CUSTOMER AND ACCOUNT DETAILS
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    c.email,
    c.city,
    a.account_number,
    a.credit_limit,
    a.account_status
FROM customers c
JOIN accounts a
    ON c.customer_id = a.customer_id
ORDER BY c.customer_id;


-- ==========================================================
-- 13. CUSTOMER-WISE TRANSACTION COUNT
-- ==========================================================

SELECT
    c.customer_id,
    c.customer_name,
    COUNT(t.transaction_id) AS total_transactions
FROM customers c
LEFT JOIN accounts a
    ON c.customer_id = a.customer_id
LEFT JOIN transactions t
    ON a.account_id = t.account_id
GROUP BY c.customer_id, c.customer_name
ORDER BY c.customer_id;


-- ==========================================================
-- 14. TRANSACTIONS WITH CUSTOMER DETAILS
-- ==========================================================

SELECT
    t.transaction_id,
    c.customer_name,
    c.email,
    t.transaction_amount,
    t.transaction_date,
    t.merchant_name,
    t.location,
    t.device,
    t.transaction_type,
    t.transaction_status
FROM transactions t
JOIN accounts a
    ON t.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
ORDER BY t.transaction_id;


-- ==========================================================
-- 15. FRAUD ALERTS WITH CUSTOMER DETAILS
-- ==========================================================

SELECT
    fa.alert_id,
    c.customer_name,
    c.email,
    t.transaction_id,
    t.transaction_amount,
    t.merchant_name,
    t.device,
    fa.risk_score,
    fa.risk_level,
    fa.alert_reason,
    fa.alert_status
FROM fraud_alerts fa
JOIN transactions t
    ON fa.transaction_id = t.transaction_id
JOIN accounts a
    ON t.account_id = a.account_id
JOIN customers c
    ON a.customer_id = c.customer_id
ORDER BY fa.alert_id;


-- ==========================================================
-- 16. VIEW INDIVIDUAL TABLES
-- ==========================================================

SELECT * FROM customers;
SELECT * FROM accounts;
SELECT * FROM transactions;
SELECT * FROM fraud_alerts;


-- ==========================================================
-- END OF DATABASE SETUP
-- Project: Digital Fraud Detection & Transaction Risk Analytics
-- ==========================================================