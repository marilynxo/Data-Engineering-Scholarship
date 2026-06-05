-- Create Database
CREATE DATABASE StudentFunctionDB;
GO

USE StudentFunctionDB;
GO

-- Create Students Table
CREATE TABLE students (
    student_id INT PRIMARY KEY IDENTITY(1,1),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    marks INT,
    gpa DECIMAL(3,2),
    tuition_fee MONEY
);
GO

-- Insert Sample Data
INSERT INTO students (first_name, last_name, date_of_birth, marks, gpa, tuition_fee)
VALUES
('Aung', 'Aung', '2005-01-15', 85, 3.80, 500000),
('Su', 'Su', '2006-03-20', 72, 3.20, 500000),
('Kyaw', 'Kyaw', '2004-07-10', 45, 2.10, 500000),
('Hla', 'Hla', '2005-11-05', 90, 3.95, 500000);
GO

------------------------------------------------------
-- Question 1: Grade Point Function
------------------------------------------------------
CREATE FUNCTION fn_GradePoint (@marks INT)
RETURNS DECIMAL(3,2)
AS
BEGIN
    DECLARE @gradePoint DECIMAL(3,2);
    IF @marks >= 80 SET @gradePoint = 4.0;
    ELSE IF @marks >= 70 SET @gradePoint = 3.0;
    ELSE IF @marks >= 60 SET @gradePoint = 2.0;
    ELSE IF @marks >= 50 SET @gradePoint = 1.0;
    ELSE SET @gradePoint = 0.0;
    RETURN @gradePoint;
END;
GO

------------------------------------------------------
-- Question 2: Grade Letter Function
------------------------------------------------------
CREATE FUNCTION fn_GradeLetter (@marks INT)
RETURNS VARCHAR(2)
AS
BEGIN
    DECLARE @gradeLetter VARCHAR(2);
    IF @marks >= 80 SET @gradeLetter = 'A';
    ELSE IF @marks >= 70 SET @gradeLetter = 'B';
    ELSE IF @marks >= 60 SET @gradeLetter = 'C';
    ELSE IF @marks >= 50 SET @gradeLetter = 'D';
    ELSE SET @gradeLetter = 'F';
    RETURN @gradeLetter;
END;
GO

------------------------------------------------------
-- Question 3: Pass or Fail Function
------------------------------------------------------
CREATE FUNCTION fn_PassFail (@marks INT)
RETURNS VARCHAR(10)
AS
BEGIN
    RETURN (CASE WHEN @marks >= 50 THEN 'Pass' ELSE 'Fail' END);
END;
GO

------------------------------------------------------
-- Question 4: GPA Status Function
------------------------------------------------------
CREATE FUNCTION fn_GPAStatus (@gpa DECIMAL(3,2))
RETURNS VARCHAR(20)
AS
BEGIN
    DECLARE @status VARCHAR(20);
    IF @gpa >= 3.5 SET @status = 'Excellent';
    ELSE IF @gpa >= 3.0 SET @status = 'Good';
    ELSE IF @gpa >= 2.0 SET @status = 'Average';
    ELSE SET @status = 'Poor';
    RETURN @status;
END;
GO

------------------------------------------------------
-- Question 5: Scholarship Eligibility Function
------------------------------------------------------
CREATE FUNCTION fn_ScholarshipEligibility (@gpa DECIMAL(3,2))
RETURNS BIT
AS
BEGIN
    RETURN (CASE WHEN @gpa >= 3.5 THEN 1 ELSE 0 END);
END;
GO

------------------------------------------------------
-- Question 6: Age Calculation Function
------------------------------------------------------
CREATE FUNCTION fn_CalculateAge (@dob DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @dob, GETDATE());
END;
GO

------------------------------------------------------
-- Question 7: Full Name Function
------------------------------------------------------
CREATE FUNCTION fn_FullName (@firstName VARCHAR(50), @lastName VARCHAR(50))
RETURNS VARCHAR(100)
AS
BEGIN
    RETURN @firstName + ' ' + @lastName;
END;
GO

------------------------------------------------------
-- Question 8: Tuition Discount Function
------------------------------------------------------
CREATE FUNCTION fn_TuitionDiscount (@gpa DECIMAL(3,2), @tuition MONEY)
RETURNS MONEY
AS
BEGIN
    DECLARE @discount MONEY;
    IF @gpa >= 3.8 SET @discount = @tuition * 0.20; -- 20% discount
    ELSE IF @gpa >= 3.5 SET @discount = @tuition * 0.10; -- 10% discount
    ELSE SET @discount = 0;
    RETURN @discount;
END;
GO

------------------------------------------------------
-- Test Queries
------------------------------------------------------
SELECT 
    student_id,
    dbo.fn_FullName(first_name, last_name) AS FullName,
    dbo.fn_CalculateAge(date_of_birth) AS Age,
    marks,
    dbo.fn_GradePoint(marks) AS GradePoint,
    dbo.fn_GradeLetter(marks) AS GradeLetter,
    dbo.fn_PassFail(marks) AS PassFail,
    gpa,
    dbo.fn_GPAStatus(gpa) AS GPAStatus,
    dbo.fn_ScholarshipEligibility(gpa) AS ScholarshipEligible,
    tuition_fee,
    dbo.fn_TuitionDiscount(gpa, tuition_fee) AS DiscountAmount
FROM students;
GO
