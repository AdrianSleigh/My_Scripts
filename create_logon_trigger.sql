---CREATES A LOGON_AUDIT TABLE AND TRIGGER
---Adrian Sleigh 28/11/20
-----------------------------------------------------
--- DISABLE TRIGGER ALL ON ALL SERVER
--- DROP TRIGGER LogonTrigger_For_Audit ON ALL SERVER
----DISABLE TRIGGER LogonTrigger_For_Audit ON SERVER
----ENABLE TRIGGER LogonTrigger_For_Audit ON SERVER
---TRUNCATE TABLE DBA_Admin.dbo.LogonAudit
---select * from DBA_Admin.dbo.LogonAudit

USE DBA_Admin
GO
CREATE TABLE LogonAudit
(
ID INT PRIMARY KEY IDENTITY(1,1),
Username NVARCHAR(250),
LogonTime DATETIME,
Spid INT
);
GO

CREATE OR ALTER TRIGGER LogonTrigger_For_Audit ON ALL SERVER FOR LOGON
AS BEGIN
INSERT INTO DBA_Admin.dbo.LogonAudit (Username,LogonTime,Spid)
VALUES (ORIGINAL_LOGIN(), GETDATE(), @@SPID);
END;
GO