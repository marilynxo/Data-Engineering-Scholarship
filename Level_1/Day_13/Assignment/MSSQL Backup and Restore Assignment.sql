CREATE DATABASE TelecomBackupDB; 
GO 
 
USE TelecomBackupDB; 
GO 

CREATE TABLE subscribers (     
	subscriber_id INT PRIMARY KEY IDENTITY(1,1),     
	subscriber_name VARCHAR(100),     
	phone_number VARCHAR(20),     
	package_name VARCHAR(50),     
	balance MONEY,     
	created_at DATETIME DEFAULT GETDATE() 
); 
GO 

INSERT INTO subscribers 
(subscriber_name, phone_number, package_name, balance) 
VALUES 
('Aung Aung', '091111111', 'Basic', 5000), 
('Su Su', '092222222', 'Premium', 10000), 
('Kyaw Kyaw', '093333333', 'Student', 3000); 
GO 

BACKUP DATABASE TelecomBackupDB
TO DISK = 'C:\MSSQLBackup\TelecomBackupDB_Full.bak'
WITH INIT, NAME = 'Full Backup of TelecomBackupDB';

INSERT INTO subscribers (subscriber_name, phone_number, package_name, balance)
VALUES
('Mya Mya', '094444444', 'Premium', 8000),
('Hla Hla', '095555555', 'Basic', 4000),
('Ko Ko', '096666666', 'Student', 2000);

BACKUP DATABASE TelecomBackupDB
TO DISK = 'C:\MSSQLBackup\TelecomBackupDB_Diff.bak'
WITH DIFFERENTIAL, INIT, NAME = 'Differential Backup of TelecomBackupDB';

DELETE FROM subscribers;

USE master;
ALTER DATABASE TelecomBackupDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE TelecomBackupDB
FROM DISK = 'C:\MSSQLBackup\TelecomBackupDB_Full.bak'
WITH REPLACE;

ALTER DATABASE TelecomBackupDB SET MULTI_USER;

USE master;
ALTER DATABASE TelecomBackupDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;

RESTORE DATABASE TelecomBackupDB
FROM DISK = 'C:\MSSQLBackup\TelecomBackupDB_Full.bak'
WITH NORECOVERY;

RESTORE DATABASE TelecomBackupDB
FROM DISK = 'C:\MSSQLBackup\TelecomBackupDB_Diff.bak'
WITH RECOVERY;

ALTER DATABASE TelecomBackupDB SET MULTI_USER;

USE TelecomBackupDB; 
GO 

SELECT * FROM subscribers;

RESTORE VERIFYONLY
FROM DISK = 'C:\MSSQLBackup\TelecomBackupDB_Full.bak';

RESTORE VERIFYONLY
FROM DISK = 'C:\MSSQLBackup\TelecomBackupDB_Diff.bak';

SELECT database_name, backup_start_date, backup_finish_date, backup_size, type, physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m
ON b.media_set_id = m.media_set_id
WHERE database_name = 'TelecomBackupDB'
ORDER BY backup_finish_date DESC;

SELECT name, recovery_model_desc
FROM sys.databases
WHERE name = 'TelecomBackupDB';

