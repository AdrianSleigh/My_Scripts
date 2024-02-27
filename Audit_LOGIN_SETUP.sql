USE [master]
GO

/****** Object:  Audit [Audit_ACCOUNTS]    Script Date: 28/11/2020 20:05:57 ******/
--CREATE SERVER AUDIT FOR LOGINS 
--Adrian Sleigh 28/11/20
-----------------------------------------------
CREATE SERVER AUDIT [Audit_ACCOUNTS]
TO FILE 
(	FILEPATH = N'C:\PS_SQL\LOGS\'
	,MAXSIZE = 20 MB
	,MAX_FILES = 20
	,RESERVE_DISK_SPACE = ON
)
WITH
(	QUEUE_DELAY = 1000
	,ON_FAILURE = CONTINUE
	,AUDIT_GUID = 'cfd8edd3-78ae-4442-951b-9a37448e8128'
)
ALTER SERVER AUDIT [Audit_ACCOUNTS] WITH (STATE = ON)
GO
---------------------------------------------------------------------
USE [master]
GO

CREATE SERVER AUDIT SPECIFICATION [SERVER_AUDIT_ACCOUNTS]
FOR SERVER AUDIT [Audit_ACCOUNTS]
ADD (FAILED_LOGIN_GROUP),
ADD (SUCCESSFUL_LOGIN_GROUP)
WITH (STATE = ON)
GO
----------------------------------------------------
--READ LOGS-----------------------------------------
SELECT 
event_time,action_id,succeeded,session_id,session_server_principal_name,
server_instance_name,statement,file_name,client_ip,application_name
FROM sys.fn_get_audit_file
('C:\PS_SQL\LOGS\*', null, null)
GO
----------------------------------------------------
event_time,action_id,succeeded,session_id,session_server_principal_name,server_instance_name,statement,file_name,client_ip,application_name)