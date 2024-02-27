/*
C2 audit trace option in SQL Server.C2 is security-auditing level defined by the US Government’s Trusted Computer Security Evaluation Criteria (TCSEC) program. Microsoft added the C2 audit mode option to address government requirements that certain contractors document database activity and possible security policy violations. So what does this audit trace do and how can we enable\disable the audit trace.

This audit captures the following information on the SQL server.
 1) End User Activity (All SQL commands, logins and logouts)
 2) Security Events (Grant/Revoke/Deny, login/user/role add/remove/configure)
 3) Utility Events (Backup/Restore/ Bulk Insert/BCP/DBCC commands)
 4) Server Events (Shutdown, Pause, Start)

/*


--GET LIST OF TRACES RUNNING

select * from sys.traces

--OUTPUTS CURRENT FILE WITHOUT USING PROFILER

SELECT 
--*
[TextData],[HostName],[ApplicationName],
[LOGINName],[StartTime],[EndTime],[DatabaseName],[Reads],[Writes],[Success],[IntegerData],
[ServerName],[ObjectName],[FileName]

 FROM ::fn_trace_gettable(
   'D:\Program Files\Microsoft SQL Server\MSSQL12.OSQL113\MSSQL\DATA\audittrace20181026141446.trc', default
	)
GO


--START AUDITING

EXEC sys.sp_configure N'c2 audit mode', N'1'
GO
RECONFIGURE WITH OVERRIDE

--restart SQL


---STOP AUDITING
EXEC sys.sp_configure N'c2 audit mode', N'0'
GO
RECONFIGURE WITH OVERRIDE
GO

--restart SQL