-- Create Database
CREATE DATABASE TelecomSPDB;
GO

USE TelecomSPDB;
GO

-- Create Subscribers Table
CREATE TABLE subscribers (
    subscriber_id INT PRIMARY KEY IDENTITY(1,1),
    subscriber_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    package_name VARCHAR(50),
    balance MONEY DEFAULT 0,
    created_at DATETIME DEFAULT GETDATE()
);
GO

-- Insert Sample Data
INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
VALUES
('Aung Aung', '091111111', 'Basic', 5000),
('Su Su', '092222222', 'Premium', 10000),
('Kyaw Kyaw', '093333333', 'Student', 3000);
GO

------------------------------------------------------
-- Question 1: Insert New Subscriber
------------------------------------------------------
CREATE PROCEDURE sp_InsertSubscriber
    @name VARCHAR(100),
    @phone VARCHAR(20),
    @package VARCHAR(50),
    @balance MONEY
AS
BEGIN
    INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
    VALUES (@name, @phone, @package, @balance);
END;
GO

-- Test Call
EXEC sp_InsertSubscriber 'Mya Mya', '094444444', 'Premium', 8000;
GO

------------------------------------------------------
-- Question 2: View All Subscribers
------------------------------------------------------
CREATE PROCEDURE sp_ViewSubscribers
AS
BEGIN
    SELECT * FROM subscribers;
END;
GO

-- Test Call
EXEC sp_ViewSubscribers;
GO

------------------------------------------------------
-- Question 3: Search Subscriber by Phone Number
------------------------------------------------------
CREATE PROCEDURE sp_SearchSubscriberByPhone
    @phone VARCHAR(20)
AS
BEGIN
    SELECT * FROM subscribers WHERE phone_number = @phone;
END;
GO

-- Test Call
EXEC sp_SearchSubscriberByPhone '092222222';
GO

------------------------------------------------------
-- Question 4: Update Subscriber Package
------------------------------------------------------
CREATE PROCEDURE sp_UpdateSubscriberPackage
    @id INT,
    @package VARCHAR(50)
AS
BEGIN
    UPDATE subscribers SET package_name = @package WHERE subscriber_id = @id;
END;
GO

-- Test Call
EXEC sp_UpdateSubscriberPackage 1, 'Gold';
GO

------------------------------------------------------
-- Question 5: Recharge Subscriber Balance
------------------------------------------------------
CREATE PROCEDURE sp_RechargeSubscriber
    @id INT,
    @amount MONEY
AS
BEGIN
    UPDATE subscribers SET balance = balance + @amount WHERE subscriber_id = @id;
END;
GO

-- Test Call
EXEC sp_RechargeSubscriber 2, 2000;
GO

------------------------------------------------------
-- Question 6: Delete Subscriber
------------------------------------------------------
CREATE PROCEDURE sp_DeleteSubscriber
    @id INT
AS
BEGIN
    DELETE FROM subscribers WHERE subscriber_id = @id;
END;
GO

-- Test Call
EXEC sp_DeleteSubscriber 3;
GO

------------------------------------------------------
-- Question 7: Package-Based Report
------------------------------------------------------
CREATE PROCEDURE sp_ReportByPackage
    @package VARCHAR(50)
AS
BEGIN
    SELECT * FROM subscribers WHERE package_name = @package;
END;
GO

-- Test Call
EXEC sp_ReportByPackage 'Premium';
GO

------------------------------------------------------
-- Question 8: Balance Report
------------------------------------------------------
CREATE PROCEDURE sp_ReportByBalance
    @amount MONEY
AS
BEGIN
    SELECT * FROM subscribers WHERE balance > @amount;
END;
GO

-- Test Call
EXEC sp_ReportByBalance 5000;
GO

------------------------------------------------------
-- Question 9: Count Subscribers by Package
------------------------------------------------------
CREATE PROCEDURE sp_CountSubscribersByPackage
AS
BEGIN
    SELECT package_name, COUNT(*) AS SubscriberCount
    FROM subscribers
    GROUP BY package_name;
END;
GO

-- Test Call
EXEC sp_CountSubscribersByPackage;
GO

------------------------------------------------------
-- Question 10: Validate Recharge Amount
------------------------------------------------------
CREATE PROCEDURE sp_ValidateRecharge
    @id INT,
    @amount MONEY
AS
BEGIN
    IF @amount < 1000
        PRINT 'Recharge amount must be at least 1000 MMK';
    ELSE
        UPDATE subscribers SET balance = balance + @amount WHERE subscriber_id = @id;
END;
GO

-- Test Calls
EXEC sp_ValidateRecharge 1, 500;   -- Should print warning
EXEC sp_ValidateRecharge 1, 1500;  -- Should update balance
GO
