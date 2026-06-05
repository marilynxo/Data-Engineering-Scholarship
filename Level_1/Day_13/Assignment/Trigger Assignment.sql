-- Create Database
CREATE DATABASE TelecomTriggerDB;
GO

USE TelecomTriggerDB;
GO

-- Subscribers Table
CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY IDENTITY(1,1),
    subscriber_name VARCHAR(100),
    phone_number VARCHAR(20),
    package_name VARCHAR(50),
    balance MONEY,
    created_at DATETIME DEFAULT GETDATE()
);

-- Recharge Transactions
CREATE TABLE recharge_transactions (
    recharge_id INT PRIMARY KEY IDENTITY(1,1),
    subscriber_id INT,
    recharge_amount MONEY,
    recharge_time DATETIME DEFAULT GETDATE()
);

-- Audit Logs
CREATE TABLE audit_logs (
    audit_id INT PRIMARY KEY IDENTITY(1,1),
    action_type VARCHAR(50),
    table_name VARCHAR(100),
    description VARCHAR(255),
    action_time DATETIME DEFAULT GETDATE()
);

-- Package History
CREATE TABLE package_history (
    history_id INT PRIMARY KEY IDENTITY(1,1),
    subscriber_id INT,
    old_package VARCHAR(50),
    new_package VARCHAR(50),
    changed_time DATETIME DEFAULT GETDATE()
);
GO

-- Sample Data
INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
VALUES
('Aung Aung', '091111111', 'Basic', 5000),
('Su Su', '092222222', 'Premium', 10000),
('Kyaw Kyaw', '093333333', 'Student', 3000);
GO

------------------------------------------------------
-- Question 1: Audit New Subscriber Registration
------------------------------------------------------
CREATE TRIGGER trg_AuditNewSubscriber
ON subscribers
AFTER INSERT
AS
BEGIN
    INSERT INTO audit_logs (action_type, table_name, description)
    SELECT 'INSERT', 'subscribers', 'New subscriber: ' + subscriber_name
    FROM inserted;
END;
GO

-- Test
INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
VALUES ('Mya Mya', '094444444', 'Premium', 8000);
GO

SELECT * FROM audit_logs;
GO

------------------------------------------------------
-- Question 2: Track Package Changes
------------------------------------------------------
CREATE TRIGGER trg_PackageChange
ON subscribers
AFTER UPDATE
AS
BEGIN
    INSERT INTO package_history (subscriber_id, old_package, new_package)
    SELECT d.subscriber_id, d.package_name, i.package_name
    FROM deleted d
    JOIN inserted i ON d.subscriber_id = i.subscriber_id
    WHERE d.package_name <> i.package_name;
END;
GO

-- Test
UPDATE subscribers SET package_name = 'Gold' WHERE subscriber_id = 1;
GO

SELECT * FROM package_history;
GO

------------------------------------------------------
-- Question 3: Log Deleted Subscribers
------------------------------------------------------
CREATE TRIGGER trg_LogDeletedSubscriber
ON subscribers
AFTER DELETE
AS
BEGIN
    INSERT INTO audit_logs (action_type, table_name, description)
    SELECT 'DELETE', 'subscribers', 'Deleted subscriber: ' + subscriber_name
    FROM deleted;
END;
GO

-- Test
DELETE FROM subscribers WHERE subscriber_id = 3;
GO

SELECT * FROM audit_logs;
GO

------------------------------------------------------
-- Question 4: Validate Recharge Amount
------------------------------------------------------
CREATE TRIGGER trg_ValidateRecharge
ON recharge_transactions
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (SELECT * FROM inserted WHERE recharge_amount < 1000)
    BEGIN
        PRINT 'Recharge amount must be at least 1000 MMK';
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Test
INSERT INTO recharge_transactions (subscriber_id, recharge_amount)
VALUES (1, 500); -- Should fail
GO

------------------------------------------------------
-- Question 5: Prevent Premium Subscriber Deletion
------------------------------------------------------
CREATE TRIGGER trg_PreventPremiumDeletion
ON subscribers
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (SELECT * FROM deleted WHERE package_name = 'Premium')
    BEGIN
        PRINT 'Cannot delete Premium subscribers';
        ROLLBACK TRANSACTION;
    END
END;
GO

-- Test
DELETE FROM subscribers WHERE subscriber_id = 2; -- Should fail
GO

------------------------------------------------------
-- Question 6: Combined INSERT and UPDATE Logging
------------------------------------------------------
CREATE TRIGGER trg_InsertUpdateLogging
ON subscribers
AFTER INSERT, UPDATE
AS
BEGIN
    INSERT INTO audit_logs (action_type, table_name, description)
    SELECT 
        CASE WHEN d.subscriber_id IS NULL 
            THEN 'INSERT' 
            ELSE 'UPDATE' 
        END,
        'subscribers',
        'Subscriber change: ' + i.subscriber_name
    FROM inserted i
    LEFT JOIN deleted d ON i.subscriber_id = d.subscriber_id;
END;
GO

-- Test
UPDATE subscribers SET balance = balance + 1000 WHERE subscriber_id = 1;
GO

SELECT * FROM audit_logs;
GO

------------------------------------------------------
-- Question 7: Prevent Duplicate Phone Numbers
------------------------------------------------------
CREATE TRIGGER trg_PreventDuplicatePhone
ON subscribers
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT * FROM inserted i
        JOIN subscribers s ON i.phone_number = s.phone_number
    )
    BEGIN
        PRINT 'Duplicate phone number not allowed';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
        SELECT subscriber_name, phone_number, package_name, balance FROM inserted;
    END
END;
GO

-- Test
INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
VALUES ('Test User', '091111111', 'Basic', 2000); -- Should fail
GO

------------------------------------------------------
-- Question 8: Automatic Balance Update
------------------------------------------------------
CREATE TRIGGER trg_AutoBalanceUpdate
ON recharge_transactions
AFTER INSERT
AS
BEGIN
    UPDATE subscribers
    SET balance = balance + i.recharge_amount
    FROM subscribers s
    JOIN inserted i ON s.subscriber_id = i.subscriber_id;
END;
GO

-- Test
INSERT INTO recharge_transactions (subscriber_id, recharge_amount)
VALUES (1, 2000); -- Balance should increase
GO

SELECT * FROM subscribers WHERE subscriber_id = 1;
GO

------------------------------------------------------
-- Question 9: Recharge Audit Trigger
------------------------------------------------------
CREATE TRIGGER trg_RechargeAudit
ON recharge_transactions
AFTER INSERT
AS
BEGIN
    INSERT INTO audit_logs (action_type, table_name, description)
    SELECT 'INSERT', 'recharge_transactions',
           'Recharge of ' + CAST(i.recharge_amount AS VARCHAR) + ' for subscriber ' + CAST(i.subscriber_id AS VARCHAR)
    FROM inserted i;
END;
GO

-- Test
INSERT INTO recharge_transactions (subscriber_id, recharge_amount)
VALUES (2, 3000);
GO

SELECT * FROM audit_logs;
GO

------------------------------------------------------
-- Question 10: Security DDL Trigger
------------------------------------------------------
CREATE TRIGGER trg_PreventDDL
ON DATABASE
FOR DROP_TABLE, ALTER_TABLE
AS
BEGIN
    PRINT 'DDL operations are not allowed on this database';
    ROLLBACK TRANSACTION;
END;
GO

-- Test
DROP TABLE subscribers; -- Should fail
GO
