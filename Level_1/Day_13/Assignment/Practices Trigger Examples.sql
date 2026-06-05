-- Create Database 
CREATE DATABASE BankDB; 
GO 
 
USE BankDB; 
GO 
 
-- Customer Table 
CREATE TABLE customers ( 
    customer_id INT PRIMARY KEY IDENTITY(1,1),     
    customer_name VARCHAR(100),     
    email VARCHAR(100),     
    created_at DATETIME DEFAULT GETDATE() 
); 
 
-- Audit Table 
CREATE TABLE customer_audit (     
    audit_id INT PRIMARY KEY IDENTITY(1,1),     
    customer_id INT,     
    action_type VARCHAR(50),     
    action_time DATETIME 
); 
GO 
 
-- Trigger 
CREATE TRIGGER trg_after_insert_customer 
ON customers 
AFTER INSERT 
AS 
BEGIN 
    INSERT INTO customer_audit ( 
        customer_id,         
        action_type,         
        action_time 
    ) 
    SELECT         
        customer_id, 
        'NEW CUSTOMER INSERTED', 
        GETDATE() 
    FROM inserted; 
END; 
GO 
 
-- Test 
INSERT INTO customers(customer_name, email) 
VALUES ('Aung Aung', 'aung@gmail.com'); 
 
-- Check Result 
SELECT * FROM customer_audit; 

USE BankDB; 
GO 
 
-- Subscriber Table 
CREATE TABLE subscribers (     
    subscriber_id INT PRIMARY KEY IDENTITY(1,1),     
    subscriber_name VARCHAR(100),     
    package_name VARCHAR(50) 
); 
 
-- Package History 
CREATE TABLE package_history (     
    history_id INT PRIMARY KEY IDENTITY(1,1),     
    subscriber_id INT,     
    old_package VARCHAR(50), 
    new_package VARCHAR(50),     
    changed_time DATETIME 
); 
GO 
 
-- Trigger 
CREATE TRIGGER trg_after_update_package 
ON subscribers 
AFTER UPDATE 
AS 
BEGIN 
    INSERT INTO package_history ( 
        subscriber_id,         
        old_package,         
        new_package,         
        changed_time 
    ) 
    SELECT 
        d.subscriber_id, 
        d.package_name, 
        i.package_name,         
        GETDATE() 
    FROM deleted d 
    INNER JOIN inserted i 
        ON d.subscriber_id = i.subscriber_id; 
END; 
GO 
 
-- Test Data 
INSERT INTO subscribers(subscriber_name, package_name) 
VALUES ('Su Su', 'Basic'); 
 
-- Update 
UPDATE subscribers 
SET package_name = 'Premium' 
WHERE subscriber_id = 1; 
 
-- Check History 
SELECT * FROM package_history; 

USE BankDB; 
GO 
 
-- Employee Table 
CREATE TABLE employees (     
    emp_id INT PRIMARY KEY IDENTITY(1,1),     
    emp_name VARCHAR(100),     
    department VARCHAR(50) 
); 
 
-- Delete Log Table 
CREATE TABLE employee_delete_log (     
    log_id INT PRIMARY KEY IDENTITY(1,1),     
    emp_id INT, 
    emp_name VARCHAR(100),     
    deleted_time DATETIME 
);
GO 
 
-- Trigger 
CREATE TRIGGER trg_after_delete_employee 
ON employees 
AFTER DELETE 
AS 
BEGIN 
    INSERT INTO employee_delete_log ( 
        emp_id,         
        emp_name,         
        deleted_time 
    ) 
    SELECT         
        emp_id,         
        emp_name,         
        GETDATE() 
    FROM deleted; 
END; 
GO 
 
-- Test 
INSERT INTO employees(emp_name, department) 
VALUES ('Kyaw Kyaw', 'IT'); 
 
DELETE FROM employees 
WHERE emp_id = 1; 
 
-- Check Log 
SELECT * FROM employee_delete_log; 

USE BankDB; 
GO 
 
CREATE TABLE protected_accounts (     
    account_id INT PRIMARY KEY,     
    account_name VARCHAR(100),     
    balance MONEY 
); 
GO 
 
-- Trigger 
CREATE TRIGGER trg_prevent_delete 
ON protected_accounts 
INSTEAD OF DELETE 
AS 
BEGIN 
    PRINT 'DELETE operation is not allowed.'; 
END; 
GO 
 
-- Test Data 
INSERT INTO protected_accounts 
VALUES (1, 'VIP Customer', 1000000); 
 
-- Try Delete 
DELETE FROM protected_accounts 
WHERE account_id = 1; 
 
-- Check Data 
SELECT * FROM protected_accounts; 

USE BankDB; 
GO 
 
CREATE TRIGGER trg_prevent_drop_table 
ON DATABASE 
FOR DROP_TABLE 
AS 
BEGIN 
    PRINT 'Dropping tables is not allowed!'; 
    ROLLBACK; 
END; 
GO 

USE BankDB; 
GO 
 
CREATE TABLE staff (     
    staff_id INT PRIMARY KEY IDENTITY(1,1),     
    staff_name VARCHAR(100),     
    salary MONEY 
); 
GO 
 
CREATE TRIGGER trg_validate_salary 
ON staff 
AFTER INSERT, UPDATE 
AS 
BEGIN 
    IF EXISTS ( 
        SELECT * 
        FROM inserted 
        WHERE salary < 0 
    ) 
    BEGIN 
        PRINT 'Negative salary is not allowed.'; 
        ROLLBACK TRANSACTION; 
    END 
END; 
GO 
 
-- Test 
INSERT INTO staff(staff_name, salary) 
VALUES ('Mg Mg', -50000); 

SELECT name 
FROM sys.triggers; 

DISABLE TRIGGER trg_validate_salary 
ON staff; 

ENABLE TRIGGER trg_validate_salary 
ON staff; 

DROP TRIGGER trg_validate_salary; 