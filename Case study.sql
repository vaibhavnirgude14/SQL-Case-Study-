CREATE DATABASE Lib;
use Lib;

#Customers: Contains customer information such as customer ID, name, date of birth, and address.
CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    name VARCHAR(100),
    date_of_birth DATE,
    address VARCHAR(255)
);
DESC Customers;

INSERT INTO Customers (customer_id, name, date_of_birth, address)
VALUES 
(1, 'John Doe', '1980-05-15', 'INDIA'),
(2, 'Jane Smith', '1990-07-22', 'US'),
(3, 'Alice Johnson', '1975-03-30', 'UK');

#Accounts: Contains account information including account ID, customer ID, account type, balance, and date opened.
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    customer_id INT,
    account_type VARCHAR(50),
    balance DECIMAL(15, 2),
    date_opened DATE,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
DESC Accounts;

INSERT INTO Accounts (account_id, customer_id, account_type, balance, date_opened)
VALUES 
(101, 1, 'Savings', 1500.75, '2020-01-10'),
(102, 1, 'Checking', 500.50, '2019-05-15'),
(103, 2, 'Savings', 2500.00, '2021-03-20'),
(104, 3, 'Checking', 750.00, '2018-11-30');


#Transactions: Contains transaction information including transaction ID, account ID, transaction type, amount, transaction date, and merchant.
CREATE TABLE Transactions (
    transaction_id INT PRIMARY KEY,
    account_id INT,
    transaction_type VARCHAR(50),
    amount DECIMAL(15, 2),
    transaction_date DATE,
    merchant VARCHAR(100),
    FOREIGN KEY (account_id) REFERENCES Accounts(account_id)
);
DESC Transactions;

INSERT INTO Transactions (transaction_id, account_id, transaction_type, amount, transaction_date, merchant)
VALUES 
(1001, 101, 'Deposit', 500.00, '2023-01-10', 'Bank Transfer'),
(1002, 101, 'Withdrawal', 100.00, '2023-01-15', 'ATM Withdrawal'),
(1003, 102, 'Purchase', 50.75, '2023-01-20', 'Grocery Store'),
(1004, 103, 'Deposit', 1000.00, '2023-02-10', 'Direct Deposit'),
(1005, 104, 'Purchase', 200.00, '2023-02-15', 'Electronics Store');


#FinancialProducts: Contains financial product information including product ID, product name, interest rate, and terms.
CREATE TABLE FinancialProducts (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    interest_rate DECIMAL(5, 2),
    terms VARCHAR(255)
);
DESC FinancialProducts;

INSERT INTO FinancialProducts (product_id, product_name, interest_rate, terms)
VALUES 
(201, 'High Yield Savings', 1.50, 'Minimum balance $500'),
(202, 'Standard Savings', 0.75, 'No minimum balance'),
(203, 'Premium Checking', 0.25, 'No fees with direct deposit'),
(204, 'Basic Checking', 0.10, '$10 monthly fee without direct deposit');


#CustomerProducts: Contains information on which financial products each customer has including customer ID and product ID.
CREATE TABLE CustomerProducts (
    customer_id INT,
    product_id INT,
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id),
    FOREIGN KEY (product_id) REFERENCES FinancialProducts(product_id)
);
DESC CustomerProducts;

INSERT INTO CustomerProducts (customer_id, product_id)
VALUES 
(1, 201),
(1, 203),
(2, 202),
(3, 204);

#1 Retrieve the list of all customers who have savings accounts.
SELECT DISTINCT c.customer_id, c.name
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.account_type = 'Savings';

#2 Calculate the total transaction volume for each type of account.
SELECT a.account_type, SUM(t.amount) AS total_volume
FROM Accounts a
JOIN Transactions t ON a.account_id = t.account_id
GROUP BY a.account_type;

#3 Determine the average balance for each account type.
SELECT account_type, AVG(balance) AS average_balance
FROM Accounts
GROUP BY account_type;

#4 Identify the top 10 merchants by transaction volume.
SELECT merchant, SUM(amount) AS total_volume
FROM Transactions
GROUP BY merchant
ORDER BY total_volume DESC
LIMIT 10;

#5 Identify any accounts with suspiciously high transaction volumes over a short period.
-- Define "suspiciously high" based on business rules, e.g., transactions over $10,000 in a day
SELECT account_id, SUM(amount) AS total_volume, transaction_date
FROM Transactions
GROUP BY account_id, transaction_date
HAVING SUM(amount) > 10000;

#6  Detect any customers with negative balances and identify patterns.
SELECT c.customer_id, c.name, a.account_id, a.balance
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
WHERE a.balance < 0;


#7 Find customers who have multiple financial products and analyze their transaction behavior.
SELECT c.customer_id, c.name, COUNT(cp.product_id) AS product_count
FROM Customers c
JOIN CustomerProducts cp ON c.customer_id = cp.customer_id
GROUP BY c.customer_id, c.name
HAVING COUNT(cp.product_id) > 1;

-- Analyzing their transaction behavior
SELECT c.customer_id, c.name, t.*
FROM Customers c
JOIN Accounts a ON c.customer_id = a.customer_id
JOIN Transactions t ON a.account_id = t.account_id
WHERE c.customer_id IN (
  SELECT customer_id
  FROM CustomerProducts
  GROUP BY customer_id
  HAVING COUNT(product_id) > 1
);


#8 Determine the most popular financial products among customers based on the number of customers who have each product.
SELECT fp.product_name, COUNT(cp.customer_id) AS customer_count
FROM FinancialProducts fp
JOIN CustomerProducts cp ON fp.product_id = cp.product_id
GROUP BY fp.product_name
ORDER BY customer_count DESC;
