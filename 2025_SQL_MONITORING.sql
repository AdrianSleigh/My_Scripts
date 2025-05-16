/* Build script for SQL Monitoring database SQL_Monitoring 
V2.0 28/12/22 Adrian Sleigh
Assumes databases is already created
*/
---------------------------------------------------------------------------------------
USE [SQL_Monitoring]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[LAST_USED_DB](
	[Id] [bigint] IDENTITY(1,1) NOT NULL,
	[Last_Restart] [datetime] NOT NULL,
	[DbName] [nvarchar](50) NOT NULL,
	[Last_User_Seek] [datetime] NULL,
	[Last_User_Scan] [datetime] NULL,
	[Last_User_Lookup] [datetime] NULL,
	[Last_User_Update] [datetime] NULL
) ON [PRIMARY]
GO
----------------------------------------------------------------------------------
CREATE TABLE [dbo].[BACKUPS](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[Run_Date] [smalldatetime] NULL,
	[HA_Primary] [sql_variant] NULL,
	[Database_Name] [nchar](60) NOT NULL,
	[DaysSinceLastBackup] [smallint] NOT NULL,
	[LastBackupDate] [smalldatetime] NOT NULL,
	[BackupType] [nchar](1) NOT NULL,
 CONSTRAINT [PK_LAST_BACKUP] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[BLOCKING](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[Ran_Date] [datetime] NOT NULL,
	[Spid] [int] NOT NULL,
	[Blocked] [int] NOT NULL,
	[LeadBlocker] [int] NOT NULL,
	[BObject] [nvarchar](50) NOT NULL,
	[WaitTime] [int] NOT NULL,
	[LastWaitType] [nchar](20) NOT NULL,
	[PhysicalIO] [int] NOT NULL,
	[LoginTime] [datetime] NOT NULL,
	[LastBatch] [datetime] NOT NULL,
	[OpenTran] [int] NOT NULL,
	[BStatus] [nchar](50) NOT NULL,
	[Hostname] [nchar](50) NOT NULL,
	[ProgramName] [nchar](100) NOT NULL,
	[LoginName] [nchar](50) NOT NULL,
 CONSTRAINT [PK_BLOCKING] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CONNECTION_MONITOR](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoginName] [nvarchar](100) NULL,
	[Host] [nvarchar](20) NULL,
	[ProgName] [nvarchar](100) NULL,
	[DbName] [nvarchar](50) NULL,
	[Connections] [int] NULL,
	[EarliestLogin] [datetime] NULL,
	[LatestLogin] [datetime] NULL,
	[Status] [nvarchar](20) NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[CPU_DETAILS](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[Ran_date] [smalldatetime] NOT NULL,
	[object_name] [nchar](100) NULL,
	[text_data] [ntext] NOT NULL,
	[disk_reads] [int] NOT NULL,
	[memory_reads] [int] NOT NULL,
	[executions] [int] NOT NULL,
	[total_cpu_time] [int] NOT NULL,
	[average_cpu_time] [int] NOT NULL,
	[disk_wait_and_cpu_time] [int] NOT NULL,
	[memory_writes] [int] NOT NULL,
	[date_cached] [smalldatetime] NOT NULL,
	[database_name] [nchar](100) NULL,
	[last_execution] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_CPU_DETAILS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[CPU_USAGE](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[SQL_CPU_UTILISATION] [int] NOT NULL,
	[SYSTEM_IDLE] [int] NOT NULL,
	[OTHER_CPU_UTILISATION] [int] NOT NULL,
	[EVENT_TIME] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_CPU_USAGE] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[DB_ACTIVITY](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[collected_date] [smalldatetime] NOT NULL,
	[TotalPageReads] [int] NOT NULL,
	[TotalPageWrites] [int] NOT NULL,
	[Databasename] [nchar](60) NOT NULL,
 CONSTRAINT [PK_DB_ACTIVITY] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[DB_SIZES](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[RAN_DATE] [smalldatetime] NOT NULL,
	[DB_NAME] [nchar](60) NOT NULL,
	[DB_STATUS] [nchar](10) NOT NULL,
	[RECOVERY_MODEL] [nchar](10) NOT NULL,
	[DB_SIZE] [decimal](18, 0) NOT NULL,
	[FILE_SIZE_MB] [decimal](18, 0) NOT NULL,
	[SPACE_USED_MB] [decimal](18, 0) NOT NULL,
	[FREE_SPACE_MB] [decimal](18, 0) NOT NULL,
	[LOG_FILE_MB] [decimal](18, 0) NOT NULL,
	[LOG_SPACE_USED_MB] [decimal](18, 0) NOT NULL,
	[LOG_FREE_SPACE_MB] [decimal](18, 0) NOT NULL,
	[DB_FREESPACE] [nchar](20) NOT NULL,
 CONSTRAINT [PK_DB_SIZES] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
CREATE TABLE [dbo].[DRIVE_SPACE_FREE](
	[Id] [int] IDENTITY(1,1) NOT NULL,
	[Ran_Date] [smalldatetime] NOT NULL,
	[Drive] [nchar](10) NOT NULL,
	[Total_Space_GB] [decimal](18, 0) NOT NULL,
	[Free_Space_GB] [decimal](18, 0) NOT NULL,
	[percent_Free_GB] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_DRIVE_SPACE_FREE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[FAILED_LOGINS](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[NumberOfAttempts] [smallint] NOT NULL,
	[Details] [ntext] NOT NULL,
	[MinLogDate] [smalldatetime] NOT NULL,
	[MaxLogDate] [smalldatetime] NOT NULL,
 CONSTRAINT [PK_FAILED_LOGINS] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[FRAGMENTATION](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[Ran_Date] [smalldatetime] NOT NULL,
	[Databasename] [nchar](100) NOT NULL,
	[Tablename] [nchar](100) NOT NULL,
	[Indexname] [nchar](100) NOT NULL,
	[Fragpercent] [decimal](18, 0) NOT NULL,
	[IndexType] [nchar](20) NOT NULL,
	[Pagecount] [int] NOT NULL
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[JOB_FAILS](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[Job_ran] [smalldatetime] NOT NULL,
	[Job_name] [nchar](100) NOT NULL,
	[Job_step] [smallint] NOT NULL,
	[Error_message] [ntext] NULL,
 CONSTRAINT [PK_JOB_FAILS] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

CREATE TABLE [dbo].[LOGINS_ISSUE](
	[id] [smallint] IDENTITY(1,1) NOT NULL,
	[ran_date] [smalldatetime] NOT NULL,
	[primary_instance] [nchar](50) NULL,
	[secondary_instance] [nchar](50) NULL,
 CONSTRAINT [PK_LOGINS_ISSUE] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[MEMORY_USAGE](
	[Id] [smallint] IDENTITY(1,1) NOT NULL,
	[Ran_date] [smalldatetime] NOT NULL,
	[DbName] [nchar](30) NOT NULL,
	[DB_buffer_pages] [int] NOT NULL,
	[DB_buffer_MB] [smallint] NOT NULL,
	[DB_buffer_percent] [decimal](18, 0) NOT NULL,
 CONSTRAINT [PK_MEMORY_USAGE] PRIMARY KEY CLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[PLE](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[TimeRan] [smalldatetime] NOT NULL,
	[Countername] [nchar](25) NOT NULL,
	[PagelifeValue] [int] NOT NULL,
 CONSTRAINT [PK_PLE] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 90) ON [PRIMARY]
) ON [PRIMARY]
GO

CREATE TABLE [dbo].[WORST_QUERIES](
	[id] [int] IDENTITY(1,1) NOT NULL,
	[database_name] [nchar](60) NOT NULL,
	[collected_time] [smalldatetime] NOT NULL,
	[object_name] [nchar](60) NOT NULL,
	[max_logical_reads] [int] NOT NULL,
	[max_logical_writes] [int] NOT NULL,
	[total_RW] [int] NOT NULL,
	[max_elapsed_time_MS] [int] NOT NULL,
	[execution_cost] [int] NOT NULL,
	[last_execution_time] [smalldatetime] NOT NULL,
	[execution_count] [int] NOT NULL,
	[object_text] [text] NOT NULL,
 CONSTRAINT [PK_WORST_QUERIES] PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

---------------------------------------------------------------
	---STORED PROCEDURES
	-------------------------------------------------------
--added 16/05/25 as missing from build. Table already present
Create Procedure [dbo].[sp_last_used_db]
AS
Insert into [SQL_Monitoring].[dbo].[LAST_USED_DB]
( [dbname],[last_Restart],[Last_User_Seek],[Last_User_Scan],[Last_User_Lookup],[Last_User_Update]
)
SELECT d.name,
(SELECT sqlserver_start_time FROM sys.dm_os_sys_info) AS Last_Restart,
Last_user_seek = MAX(Last_user_seek),
Last_user_scan = MAX (Last_user_scan), 
Last_user_lookup = MAX(Last_user_lookup),
Last_user_update = MAX (Last_user_update)
FROM sys.dm_db_index_usage_stats AS i
JOIN sys.databases AS d ON i.database_id=d.database_id
GROUP BY d.name
-------------------------------------------------------------	
CREATE PROCEDURE [dbo].[sp_alert_backup]

AS

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/16 V2.0
-- Item:	sp_alert_backup sends email alert on issues
-- Description Part of suite of scripts for monitoring
-- =============================================

SELECT getdate()AS run_date,
SUBSTRING(B.name,1,30) AS Database_Name, ISNULL(STR(ABS(DATEDIFF(day, GetDate(), 
                MAX(Backup_finish_date)))), 'NEVER') AS DaysSinceLastBackup,
                ISNULL(Convert(char(10), MAX(backup_finish_date), 101), 'NEVER') AS LastBackupDate,
				A.type AS 'TYPE'
 INTO ##LastBackup 
                FROM MASTER.dbo.sysdatabases B LEFT OUTER JOIN MSDB.dbo.backupset A 
                ON A.database_name = B.name 
				AND A.type = 'D' 
				OR A.type = 'I'  
				OR A.type = 'L'
                WHERE B.name NOT IN ('Tempdb','model')

                GROUP BY B.name, A.type
				ORDER BY B.name

               -----------Return values
			/*	SELECT * FROM ##LastBackup
				WHERE DaysSinceLastBackup >6 AND TYPE = 'D'
				OR    DaysSinceLastBackup >1 AND TYPE = 'I'
				OR    DaysSinceLastBackup >1 AND TYPE = 'L'
			*/	
  ----------------------------------------------------------------------------------------
  	IF NOT EXISTS ( select 1 from ##LastBackup )
BEGIN
 PRINT 'empty table... '  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body = 'SQL Missing Backup Issue',
    @query = 'SET NOCOUNT ON PRINT ''Missing Backups on ....''
          SELECT * FROM ##LastBackup
				WHERE DaysSinceLastBackup >=6 AND TYPE = ''D''
				OR    DaysSinceLastBackup >=1 AND TYPE = ''I''
				OR    DaysSinceLastBackup >=1 AND TYPE = ''L'' ',
    
	@subject = 'ALERTS- MISSING BACKUP ISSUES' ,
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'MissingBackupIssue.txt';  
PRINT 'Missing Backup Issue '
------------------------------------------------------------
GO
/****** Object:  StoredProcedure [dbo].[sp_alert_drvspace]    Script Date: 9/11/2022 
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/21 V1.0
-- Item:	sp_alert_drvspace alerts space less than 20% free. Run job every 15 mins
-- Description Part of suite of scripts for monitoring
-- =============================================
CREATE PROCEDURE [dbo].[sp_alert_drvspace]
AS
	IF OBJECT_ID(N'tempdb..##drvspace') IS NOT NULL
BEGIN
DROP TABLE ##drvspace
END

CREATE TABLE ##drvspace(ran_date smalldatetime ,drive varchar(4), totalspacegb float, freespacegb float, pctfree float )
INSERT INTO ##drvspace

SELECT  getdate() AS Ran_Date
    ,   Drive
    ,   TotalSpaceGB
    ,   FreeSpaceGB
    ,   PctFree
  FROM
    (SELECT DISTINCT
        SUBSTRING(dovs.volume_mount_point, 1, 10) AS Drive
    ,   CONVERT(INT, dovs.total_bytes / 1024.0 / 1024.0 / 1024.0) AS TotalSpaceGB
    ,   CONVERT(INT, dovs.available_bytes / 1048576.0) / 1024 AS FreeSpaceGB
    ,   CAST(ROUND(( CONVERT(FLOAT, dovs.available_bytes / 1048576.0) / CONVERT(FLOAT, dovs.total_bytes / 1024.0 /
                         1024.0) * 100 ), 2) AS NVARCHAR(50)) AS PctFree
    FROM    sys.master_files AS mf
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS dovs) AS DE

  --	SELECT * FROM ##drvspace WHERE pctfree <=20

	IF NOT EXISTS ( SELECT 1 FROM ##drvspace WHERE pctfree <=20 )
BEGIN
 PRINT 'Empty table... no drive space issues '  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body  = 'Drive Space alert in the last 15 mins......Space less than 20% free',
    @query = 'SET NOCOUNT ON PRINT ''Recent drive space alert''
         SELECT * FROM ##drvspace WHERE pctfree <=20 AND ran_date > dateadd(mi,-15,Getdate()) ',
    @subject = 'ALERTS- RECENT DRIVE SPACE ALERT LESS THAN 20% FREE', 
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'RecentDriveSpaceAlert.txt'; 
PRINT 'Recent Drive Space Alert'
GO

CREATE PROCEDURE [dbo].[sp_alert_jobfail]
AS
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/04/20 V2.0
-- Excluded alerting job
-- Item:	job_fail alert run every 15 mins
-- Description Part of suite of scripts for monitoring
-- =============================================

IF NOT EXISTS( SELECT 1 FROM msdb.dbo.sysjobs AS j
    INNER JOIN msdb.dbo.sysjobsteps AS js ON js.job_id = j.job_id
    INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = j.job_id AND jh.step_id = js.step_id
    WHERE jh.run_status = 0 
	AND j.name <> 'alerting'
    AND MSDB.dbo.agent_datetime(jh.run_date,jh.run_time) > dateadd(mi,-15,Getdate())
	)
	BEGIN
 PRINT 'empty table... no job fails' 
 GOTO ENDIT
END
ELSE
PRINT 'FAILED AGENT JOB OCCURRED'
BEGIN
 EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body = 'A FAILED AGENT JOB OCCURRED',
    @query = 'SET NOCOUNT ON PRINT ''FAILED AGENT JOB OCCURRED''
    SELECT  MSDB.dbo.agent_datetime(jh.run_date,jh.run_time) AS job_ran_time,
    SUBSTRING(j.name,1,50) AS job_name,
	js.step_id AS job_step,
	SUBSTRING(jh.message,1,180) AS error_message
     FROM msdb.dbo.sysjobs AS j
      INNER JOIN msdb.dbo.sysjobsteps AS js ON js.job_id = j.job_id
      INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = j.job_id AND jh.step_id = js.step_id
         WHERE jh.run_status = 0 
       AND MSDB.dbo.agent_datetime(jh.run_date,jh.run_time) > dateadd(mi,-15,Getdate())',
    @subject = 'ALERTS - FAILED AGENT JOB OCCURRED' ,
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'FAILED_AGENT_JOB_OCCURRED.txt';  
END

ENDIT:
PRINT 'ENDED'
GO
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/21 V1.0
-- Item:	sp_alert_loginfail alert run every 15 mins
-- Description Part of suite of scripts for monitoring
-- =============================================
CREATE PROCEDURE [dbo].[sp_alert_loginfail]
AS

IF OBJECT_ID(N'tempdb..##LoginFail') IS NOT NULL
BEGIN
DROP TABLE ##LoginFail
END

CREATE TABLE ##LoginFail(logdate smalldatetime ,processInfo varchar(10), TextDesc Text)
INSERT INTO ##LoginFail
 EXEC sp_readerrorlog 0, 1, 'Login failed' 

IF NOT EXISTS ( select 1 from ##LoginFail )
BEGIN
 PRINT 'empty table... no failed logins'  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body  = 'Failed logins in the last 15 mins......',
    @query = 'SET NOCOUNT ON PRINT ''Recent Failed Logins''
       SELECT * FROM ##LoginFail WHERE logdate > dateadd(mi,-15,Getdate())',
    @subject = 'ALERTS- RECENT LOGIN FAILS', 
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'RecentLoginFails.txt'; 
PRINT 'Recent Login fails present'
GO
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/17 V3.0
-- Added email alerting triggered if blocking occurs - time limit 10 mins
-- Item:	Blocking
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE [dbo].[sp_blocking]
AS
BEGIN
INSERT INTO BLOCKING (Ran_Date,Spid,Blocked,LeadBlocker,BObject,WaitTime,LastWaitType,PhysicalIO,LoginTime,LastBatch,OpenTran,BStatus,Hostname,ProgramName,LoginName)
SELECT  getdate() AS 'Ran_Date' 
  , p.spid
  , p.blocked
  , ISNULL(l.spid, 0) AS 'LeadBlocker'
  , d.name
  , p.waittime
  , p.lastwaittype
  , p.physical_io
  , p.login_time
  , p.last_batch
  , p.open_tran
  , p.status
  , p.hostname
  , p.program_name
  , p.loginame
 
FROM sysprocesses p
 INNER JOIN sysdatabases d
  ON p.dbid = d.dbid
 LEFT OUTER JOIN (SELECT spid 
      FROM  master..sysprocesses a
         WHERE  exists ( SELECT b.*
                FROM master..sysprocesses b
                WHERE b.blocked > 0 
          AND b.blocked = a.spid ) 
           AND NOT
           EXISTS ( SELECT b.*
              FROM master..sysprocesses b
              WHERE b.blocked > 0 
              AND b.spid = a.spid )) l
     ON p.spid = l.spid
WHERE p.spid > 50
AND p.blocked <> 0
OR  l.spid <> 0
END
----------------------------------------------------------------
 IF NOT EXISTS ( SELECT 1 FROM[SQL_Monitoring].[dbo].[BLOCKING] WHERE ran_date > dateadd(mi,-10,Getdate()) )
  BEGIN
  PRINT 'empty table... no issues'  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body = 'There was a blocking issue',
    @query = 'SET NOCOUNT ON PRINT ''Blocking detected''
SELECT [Ran_Date],[Spid],[Blocked],[LeadBlocker],
SUBSTRING([BObject],1,20)AS Object,[WaitTime],
[LastWaitType],[PhysicalIO],[LoginTime],[LastBatch],[OpenTran],
SUBSTRING([BStatus],1,20)AS Status,
SUBSTRING([Hostname],1,30) AS Hostname,
SUBSTRING([ProgramName],1,40)AS ProgramName ,
SUBSTRING([LoginName],1,40)AS LoginName
FROM[SQL_Monitoring].[dbo].[BLOCKING]

-------SENDS EMAIL IF BLOCKING LESS THAN 10 MINS OLD
WHERE ran_date > dateadd(mi,-10,Getdate())',
    @subject = 'ALERTS- BLOCKING DETECTED' ,
	@attach_query_result_as_file = 1 , 
	@query_attachment_filename = 'Blocking_detected.txt';
PRINT 'Blocking detected'

SELECT * FROM[SQL_Monitoring].[dbo].[BLOCKING] WHERE ran_date > dateadd(mi,-10,Getdate())
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item:	Connection Monitor
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE [dbo].[sp_connection_monitor] 
	
AS
BEGIN
	
	SET NOCOUNT ON;

-- Create the data table if its not already there
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.Connection_Monitor') and OBJECTPROPERTY(id, N'IsTable') = 1)
	BEGIN
		CREATE TABLE dbo.CONNECTION_MONITOR
		(
			[ID] [int]		IDENTITY(1,1) NOT NULL,
--			SessId			INT,
			LoginName		NVARCHAR(100),
			Host			NVARCHAR(100),
			ProgName		NVARCHAR(100),
			DbName			NVARCHAR(50),
			Connections		INT,
			EarliestLogin	        DATETIME,
			LatestLogin		DATETIME,
			[Status]		NVARCHAR(100)
		)
	END

-- Create a temporary store for extract
	IF OBJECT_ID('tempdb..#tabConnMon') IS NULL
	BEGIN
		CREATE TABLE #tabConnMon
		(
			[ID] [int]		IDENTITY(1,1) NOT NULL,
--			SessId			INT,
			LoginName		NVARCHAR(100),
			Host			NVARCHAR(100),
			ProgName		NVARCHAR(100),
			DbName			NVARCHAR(50),
			Connections		INT,
			EarliestLogin	DATETIME,
			LatestLogin		DATETIME,
			[Status]		NVARCHAR(100)
		)
	END

-- Extract from system tables to temp table grouping by user, host, prog
	BEGIN
		INSERT INTO
			#tabConnMon
		(
--			SessId,
			LoginName,
			Host,
			ProgName,
			DbName,
			Connections,
			EarliestLogin,
			LatestLogin,
			[Status]
		)
		SELECT
--			A.spid,
			LEFT(ISNULL(A.loginame, ''), 100) AS LoginName,
			LEFT(ISNULL(A.hostname, ''), 100) AS Host,
			LEFT(ISNULL(B.program_name, ''), 100),
			DB_NAME(LEFT(ISNULL(A.dbid, ''), 50)) AS DBName, 
			COUNT(A.dbid) AS NumberOfConnections,
			MIN(A.login_time) AS EarliestLogin,
			MAX(A.login_time) AS LatestLogin,
			LEFT(A.status, 100) AS Status
		FROM
			sys.sysprocesses AS A
		LEFT OUTER JOIN
            sys.dm_exec_sessions AS B
		ON
			A.spid = B.session_id
		WHERE 
			A.dbid > 4
		GROUP BY 
--			A.spid,
			A.dbid, A.hostname, B.program_name, A.loginame, A.status
	END

-- Save results to data table without duplicating Login, Host, Prog and DbName
	BEGIN
		INSERT INTO
			dbo.Connection_Monitor
		(
--			SessId,
			LoginName,
			Host,
			ProgName,
			DbName,
			Connections,
			EarliestLogin,
			LatestLogin,
			[Status]
		)
		SELECT
--			#tabConnMon.SessId,
			#tabConnMon.LoginName,
			#tabConnMon.Host,
			#tabConnMon.ProgName,
			#tabConnMon.DbName,
			#tabConnMon.Connections,
			#tabConnMon.EarliestLogin,
			#tabConnMon.LatestLogin,
			#tabConnMon.[Status]
		FROM
			#tabConnMon
		LEFT OUTER JOIN
            Connection_Monitor
		ON
			#tabConnMon.LoginName = dbo.Connection_Monitor.LoginName
		AND
			#tabConnMon.Host = dbo.Connection_Monitor.Host
		AND 
			#tabConnMon.ProgName = dbo.Connection_Monitor.ProgName
		AND
			#tabConnMon.DbName = dbo.Connection_Monitor.DbName
		WHERE
			(dbo.Connection_Monitor.ID IS NULL)
	END

 -- Update latest login and status where login, host, prog and db are the same
	BEGIN
		UPDATE
			dbo.Connection_Monitor
		SET
			dbo.Connection_Monitor.LatestLogin = dbo.#tabConnMon.LatestLogin,
			dbo.Connection_Monitor.Status = dbo.#tabConnMon.Status
		FROM
			dbo.Connection_Monitor
		INNER JOIN
			dbo.#tabConnMon
		ON
			dbo.Connection_Monitor.LoginName = dbo.#tabConnMon.LoginName
		AND
			dbo.Connection_Monitor.Host = dbo.#tabConnMon.Host
		AND 
			dbo.Connection_Monitor.ProgName = dbo.#tabConnMon.ProgName
		AND 
			dbo.Connection_Monitor.DbName = dbo.#tabConnMon.DbName
	END

--SELECT * FROM dbo.Connection_Monitor

-- Remove temp table
	BEGIN
		IF OBJECT_ID('tempdb..#tabConnMon') IS NOT NULL DROP TABLE #tabConnMon
	END
END
GO

CREATE PROCEDURE [dbo].[sp_cpu_details]

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/08 V1.0
-- Item:	cpu_details
-- Description Part of suite of scripts for monitoring
-- =============================================
AS
INSERT INTO [SQL_Monitoring].[dbo].[CPU_DETAILS]
([Ran_date],[object_name],[text_data],[disk_reads],[memory_reads],[executions],
[total_cpu_time],[average_cpu_time],[disk_wait_and_cpu_time],[memory_writes],[date_cached],
[database_name],[last_execution]
)

SELECT TOP 20
   getdate() as Ran_date,
    ObjectName          = OBJECT_SCHEMA_NAME(qt.objectid,dbid) + '.' + OBJECT_NAME(qt.objectid, qt.dbid)
    ,TextData           = qt.text
    ,DiskReads          = qs.total_physical_reads   -- The worst reads, disk reads
    ,MemoryReads        = qs.total_logical_reads    --Logical Reads are memory reads
    ,Executions         = qs.execution_count
    ,TotalCPUTime       = qs.total_worker_time
    ,AverageCPUTime     = qs.total_worker_time/qs.execution_count
    ,DiskWaitAndCPUTime = qs.total_elapsed_time
    ,MemoryWrites       = qs.max_logical_writes
    ,DateCached         = qs.creation_time
    ,DatabaseName       = DB_Name(qt.dbid)
    ,LastExecutionTime  = qs.last_execution_time
 FROM sys.dm_exec_query_stats AS qs
 CROSS APPLY sys.dm_exec_sql_text(qs.sql_handle) AS qt
-- ORDER BY qs.total_worker_time DESC
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item:	db_activity
-- Description Part of suite of scripts for monitoring
-- =============================================
CREATE PROCEDURE [dbo].[sp_db_activity]

AS

INSERT INTO SQL_Monitoring.dbo.DB_ACTIVITY (collected_date,TotalPageReads,TotalPageWrites,Databasename)

SELECT 
Getdate() AS collected_date,
SUM(deqs.total_logical_reads) TotalPageReads,
SUM(deqs.total_logical_writes) TotalPageWrites, 
CASE
WHEN DB_NAME(dest.dbid) IS NULL THEN 'AdhocSQL'
ELSE DB_NAME(dest.dbid) END Databasename
FROM sys.dm_exec_query_stats deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
GROUP BY DB_NAME(dest.dbid)
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/02/22 V1.0
-- Item:	db_sizes
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE  [dbo].[sp_db_sizes]

AS
--USE [SQL_Monitoring]

--if exists (select * from tempdb.sys.all_objects where name like '%#dbsize%')
--drop table #dbsize
create table #dbsize
(Dbname varchar(300),dbstatus varchar(200),Recovery_Model varchar(100) default ('NA'), file_Size_MB decimal(20,2)default (0),Space_Used_MB decimal(20,2)default (0),Free_Space_MB decimal(20,2) default (0))
 
insert into #dbsize(Dbname,dbstatus,Recovery_Model,file_Size_MB,Space_Used_MB,Free_Space_MB)
exec sp_msforeachdb
'use [?];
  select DB_NAME() AS DbName,
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Status'')) , 
    CONVERT(varchar(20),DatabasePropertyEx(''?'',''Recovery'')), 
sum(size)/128.0 AS File_Size_MB,
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as Space_Used_MB,
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS Free_Space_MB 
from sys.database_files  where type=0 group by type'
 
  -------------------log size--------------------------------------
  if exists (select * from tempdb.sys.all_objects where name like '#logsize%')
drop table #logsize
create table #logsize
(Dbname varchar(300), Log_File_Size_MB decimal(20,2)default (0),log_Space_Used_MB decimal(20,2)default (0),log_Free_Space_MB decimal(20,2)default (0))

 insert into #logsize(Dbname,Log_File_Size_MB,log_Space_Used_MB,log_Free_Space_MB)
exec sp_msforeachdb
'use [?];
  select DB_NAME() AS DbName,
sum(size)/128.0 AS Log_File_Size_MB,
sum(CAST(FILEPROPERTY(name, ''SpaceUsed'') AS INT))/128.0 as log_Space_Used_MB,
SUM( size)/128.0 - sum(CAST(FILEPROPERTY(name,''SpaceUsed'') AS INT))/128.0 AS log_Free_Space_MB 
from sys.database_files  where type=1 group by type'
 
--------------------------------database free size
  if exists (select * from tempdb.sys.all_objects where name like '%#dbfreesize%')
drop table #dbfreesize
create table #dbfreesize
(name varchar(500),
database_size varchar(500),
Freespace varchar(500)default (0.00))
 
insert into #dbfreesize(name,database_size,Freespace)
exec sp_msforeachdb
'use ?;SELECT database_name = db_name()
    ,database_size = ltrim(str((convert(DECIMAL(15, 2), dbsize) + convert(DECIMAL(15, 2), logsize)) * 8192 / 1048576, 15, 2) + ''MB'')
    ,''unallocated space'' = ltrim(str((
                CASE 
                    WHEN dbsize >= reservedpages
                        THEN (convert(DECIMAL(15, 2), dbsize) - convert(DECIMAL(15, 2), reservedpages)) * 8192 / 1048576
                    ELSE 0
                    END
                ), 15, 2) + '' MB'')
FROM (
    SELECT dbsize = sum(convert(BIGINT, CASE 
                    WHEN type = 0
                        THEN size
                    ELSE 0
                    END))
        ,logsize = sum(convert(BIGINT, CASE 
                    WHEN type <> 0
                        THEN size
                    ELSE 0
                    END))
    FROM sys.database_files
) AS files
,(
    SELECT reservedpages = sum(a.total_pages)
        ,usedpages = sum(a.used_pages)
        ,pages = sum(CASE 
                WHEN it.internal_type IN (
                        202
                        ,204
                        ,211
                        ,212
                        ,213
                        ,214
                        ,215
                        ,216
                        )
                    THEN 0
                WHEN a.type <> 1
                    THEN a.used_pages
                WHEN p.index_id < 2
                    THEN a.data_pages
                ELSE 0
                END)
    FROM sys.partitions p
    INNER JOIN sys.allocation_units a
        ON p.partition_id = a.container_id
    LEFT JOIN sys.internal_tables it
        ON p.object_id = it.object_id
) AS partitions'
-----------------------------------
 
if exists (select * from tempdb.sys.all_objects where name like '%#alldbstate%')
drop table #alldbstate 
create table #alldbstate 
(dbname varchar(250),
DBstatus varchar(250),
R_model Varchar(200))
  
--select * from sys.master_files
 
insert into #alldbstate (dbname,DBstatus,R_model)
select name,CONVERT(varchar(200),DATABASEPROPERTYEX(name,'status')),recovery_model_desc from sys.databases
--select * from #dbsize
 
insert into #dbsize(Dbname,dbstatus,Recovery_Model)
select dbname,dbstatus,R_model from #alldbstate where DBstatus <> 'online'
 
insert into #logsize(Dbname)
select dbname from #alldbstate where DBstatus <> 'online'
 
insert into #dbfreesize(name)
select dbname from #alldbstate where DBstatus <> 'online'
 
INSERT INTO  SQL_Monitoring.dbo.DB_SIZES 

(RAN_DATE,DB_NAME,DB_STATUS,RECOVERY_MODEL,DB_SIZE,FILE_SIZE_MB,SPACE_USED_MB,FREE_SPACE_MB,LOG_FILE_MB,LOG_SPACE_USED_MB,LOG_FREE_SPACE_MB,DB_FREESPACE)

select 
getdate(),
d.Dbname,d.dbstatus,d.Recovery_Model,
(file_size_mb + log_file_size_mb) as DBsize,
d.file_Size_MB,d.Space_Used_MB,d.Free_Space_MB,
l.Log_File_Size_MB,log_Space_Used_MB,l.log_Free_Space_MB,fs.Freespace as DB_Freespace
from #dbsize d join #logsize l 
on d.Dbname=l.Dbname join #dbfreesize fs 
on d.Dbname=fs.name
order by Dbname
--------------------------------------------------------------------------------------
GO
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/14 V2.0
-- Added Drive space free
-- Item:	Agent Job fails
-- Description Part of suite of scripts for monitoring
-- =============================================
CREATE PROCEDURE [dbo].[sp_drive_space_free]
AS
INSERT INTO [SQL_Monitoring].[dbo].[DRIVE_SPACE_FREE]

SELECT  getdate() AS Ran_Date
    ,   Drive
    ,   TotalSpaceGB
    ,   FreeSpaceGB
    ,   PctFree
    FROM
    (SELECT DISTINCT
        SUBSTRING(dovs.volume_mount_point, 1, 10) AS Drive
    ,   CONVERT(INT, dovs.total_bytes / 1024.0 / 1024.0 / 1024.0) AS TotalSpaceGB
    ,   CONVERT(INT, dovs.available_bytes / 1048576.0) / 1024 AS FreeSpaceGB
    ,   CAST(ROUND(( CONVERT(FLOAT, dovs.available_bytes / 1048576.0) / CONVERT(FLOAT, dovs.total_bytes / 1024.0 /
                         1024.0) * 100 ), 2) AS NVARCHAR(50)) AS PctFree
              
    FROM    sys.master_files AS mf
    CROSS APPLY sys.dm_os_volume_stats(mf.database_id, mf.file_id) AS dovs) AS DE
--------------------------------------------------------------------------------------------


GO
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/20 V3.0
-- Item:	Inserts Agent Job fails into table SQL_Monitoring.dbo.job_fails
-- based on number of days @numdays, Example Exec sp_failed_jobs 2  (2 day fails)
-- Description Part of suite of scripts for monitoring
-- =============================================
--run daily
CREATE PROCEDURE [dbo].[sp_failed_jobs] @numdays INT
AS
INSERT INTO [SQL_Monitoring].[dbo].[JOB_FAILS] 
([Job_ran],[Job_name],[Job_step],[Error_message])

SELECT MSDB.dbo.agent_datetime(jh.run_date,jh.run_time) AS job_ran_time
    ,j.name AS job_name,js.step_id AS job_step,jh.message AS error_message
    FROM msdb.dbo.sysjobs AS j
    INNER JOIN msdb.dbo.sysjobsteps AS js ON js.job_id = j.job_id
    INNER JOIN msdb.dbo.sysjobhistory AS jh ON jh.job_id = j.job_id AND jh.step_id = js.step_id
    WHERE jh.run_status = 0 
	AND MSDB.dbo.agent_datetime(jh.run_date,jh.run_time) >= GETDATE()- @numdays

-------------------------------------------------------------------------------------------------

GO

CREATE PROCEDURE [dbo].[sp_find_unused_logins] @domain Varchar(30) 

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item: finds unused old logins and generates drop script output
-- passes a single name example exec sp_find_unused_logins '<domainname>'
-- Description Part of suite of scripts for monitoring 
-- =============================================
AS

declare @user sysname

declare recscan cursor for

select name from sys.server_principals
where type IN ('U','G') and name like @domain+'%'
 
open recscan 
fetch next from recscan into @user
 
while @@fetch_status = 0
begin
    begin try
        exec xp_logininfo @user
    end try
    begin catch
        --Error on xproc because login doesn't exist
        print 'drop login ['+convert(varchar(100),@user+']')
    end catch
 
    fetch next from recscan into @user
end
 
close recscan
deallocate recscan
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item:	fragmentation
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE [dbo].[sp_fragmentation]
 AS
EXEC master.sys.sp_MSforeachdb ' USE [?]

INSERT INTO SQL_Monitoring.dbo.Fragmentation
([Ran_Date],[Databasename],[Tablename],[Indexname],[Fragpercent],[IndexType],[Pagecount]
)
SELECT 
getdate()AS Ran_Date,
SUBSTRING (db_name(),1,20) as DatabaseName, 

SUBSTRING (OBJECT_NAME (sysst.object_id),1,30) as ObjectName,

SUBSTRING (sysind.name,1,50) as IndexName,

avg_fragmentation_in_percent as fragmented, 

SUBSTRING (index_type_desc,1,20)as IndexType,

sysst.page_count

  FROM sys.dm_db_index_physical_stats (db_id(), NULL, NULL, NULL, NULL) AS sysst

    JOIN sys.indexes AS sysind

       ON sysst.object_id = sysind.object_id AND sysst.index_id = sysind.index_id

       WHERE sysst.index_id <> 0 and avg_fragmentation_in_percent >20
	   AND sysst.page_count >=2000
	   '
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/14 V2.0
-- Item:	failed_logins last 7 days
-- Added email alerting
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROC [dbo].[sp_get_failed_login_list_last_week]
AS
BEGIN
   SET NOCOUNT ON

   DECLARE @ErrorLogCount INT 
   DECLARE @LastLogDate DATETIME
   DECLARE @ErrorLogInfo TABLE (
       LogDate DATETIME
      ,ProcessInfo NVARCHAR (50)
      ,[Text] NVARCHAR (MAX)
      )
   
   DECLARE @EnumErrorLogs TABLE (
       [Archive#] INT
      ,[Date] DATETIME
      ,LogFileSizeMB INT
      )

   INSERT INTO @EnumErrorLogs
   EXEC sp_enumerrorlogs

   SELECT @ErrorLogCount = MIN([Archive#]), @LastLogDate = MAX([Date])
   FROM @EnumErrorLogs

   WHILE @ErrorLogCount IS NOT NULL
   BEGIN

      INSERT INTO @ErrorLogInfo
      EXEC sp_readerrorlog @ErrorLogCount

      SELECT @ErrorLogCount = MIN([Archive#]), @LastLogDate = MAX([Date])
      FROM @EnumErrorLogs
      WHERE [Archive#] > @ErrorLogCount
      AND @LastLogDate > getdate() - 7 
  
   END

   -- List all last week failed logins count of attempts and the Login failure message
   TRUNCATE TABLE SQL_Monitoring.dbo.FAILED_LOGINS

   INSERT INTO SQL_Monitoring.dbo.FAILED_LOGINS
   SELECT COUNT (TEXT) AS NumberOfAttempts, TEXT AS Details, MIN(LogDate) as MinLogDate, MAX(LogDate) as MaxLogDate
   FROM @ErrorLogInfo
   WHERE ProcessInfo = 'Logon'
      AND TEXT LIKE '%fail%'
      AND LogDate > getdate() - 7
   GROUP BY TEXT
   ORDER BY NumberOfAttempts DESC
   -----added 17/03/22
   DELETE  @ErrorLogInfo
  END    
----------------------------------------------------------------------------
IF NOT EXISTS ( select 1 from SQL_Monitoring.dbo.FAILED_LOGINS )
BEGIN
 PRINT 'empty table... no failed logins'  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body = 'Failed logins......',
    @query = 'SET NOCOUNT ON PRINT ''Failed Logins Last 7 Days''
    SELECT  [NumberOfAttempts]AS Attempts,
   SUBSTRING([Details],1, 190)AS Details,
   [MinLogDate]AS Oldest_attempt,
   [MaxLogDate]AS Latest_attempt
     FROM SQL_Monitoring.dbo.FAILED_LOGINS ',
    @subject = 'ALERTS- LOGIN FAILS LAST 7 DAYS' ,
	@attach_query_result_as_file = 1,
	@query_attachment_filename = '7_daysLoginFails.txt';  ;  
PRINT 'Login fails occurred in last 7 days'
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item:	Connection Monitor
-- Description Part of suite of scripts for monitoring
-- stored procedure used to insert CPU usage data into table CPU_USAGE
-- single parameter required number in mins 59 would be an hour . An hourly job required to populate the table
-- =============================================

CREATE PROCEDURE [dbo].[sp_getcpu_use]

@mins INT

AS

BEGIN
DECLARE @ts_now BIGINT = (SELECT cpu_ticks/(cpu_ticks/ms_ticks)FROM sys.dm_os_sys_info); 

INSERT INTO SQL_MONITORING.DBO.CPU_Usage (SQL_CPU_UTILISATION,SYSTEM_IDLE,OTHER_CPU_UTILISATION,EVENT_TIME)

SELECT TOP(@mins) SQLProcessUtilization AS [SQL Server Process CPU Utilization], 
               SystemIdle AS [System Idle Process], 
               100 - SystemIdle - SQLProcessUtilization AS [Other Process CPU Utilization], 
               DATEADD(ms, -1 * (@ts_now - [timestamp]), GETDATE()) AS [Event Time] 
FROM ( 
	  SELECT record.value('(./Record/@id)[1]', 'int') AS record_id, 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/SystemIdle)[1]', 'int') 
			AS [SystemIdle], 
			record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 
			'int') 
			AS [SQLProcessUtilization], [timestamp] 
	  FROM ( 
			SELECT [timestamp], CONVERT(xml, record) AS [record] 
			FROM sys.dm_os_ring_buffers 
			WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR' 
			AND record LIKE '%<SystemHealth>%') AS x 
	  ) AS y 

  END
GO

-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/03/20 V4.0
-- Item:	last_backup added email alerting added HA column
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE [dbo].[sp_last_backup]

-------------------------------------------------------------------------------------------------------
AS
INSERT INTO [SQL_Monitoring].[dbo].[BACKUPS] (Run_date,HA_Primary,Database_name,DaysSinceLastBackup,LastBackupDate,BackupType)

SELECT getdate()AS run_date,
SERVERPROPERTY ('IsHadrEnabled')AS 'HA_Primary',
SUBSTRING(B.name,1,30) AS Database_name, ISNULL(STR(ABS(DATEDIFF(day, GetDate(), 
                MAX(Backup_finish_date)))), 'NEVER') AS DaysSinceLastBackup,
                ISNULL(Convert(char(10), MAX(backup_finish_date), 101), 'NEVER') AS LastBackupDate,
				A.type AS 'TYPE'
                FROM master.dbo.sysdatabases B LEFT OUTER JOIN msdb.dbo.backupset A 
                ON A.Database_name = B.name 
				AND A.type = 'D' 
				OR A.type = 'I'  
				OR A.type = 'L'
                WHERE B.name NOT IN ('Tempdb','model')
                GROUP BY B.name, A.type
				ORDER BY B.name
  ----------------------------------------------------------------------------------------
 /* REM out this section as superseded by SP_Missing_backup
 20/03/22 APS
 IF NOT EXISTS ( select 1 from [SQL_Monitoring].[dbo].[BACKUPS] )
BEGIN
 PRINT 'empty table... '  
END
ELSE
EXEC msdb.dbo.sp_send_dbmail
    @profile_name = 'newemailprofile',
    @recipients = 'user.address@.com',  
    @body = 'SQL Backup Issues',
    @query = 'SET NOCOUNT ON PRINT ''Backup Issues ''
    SELECT 
        SUBSTRING(@@servername,1,40),
		[Run_Date],
        [Database_Name],
        [DaysSinceLastBackup],
        [LastBackupDate],
        [BackupType]
  FROM [SQL_Monitoring].[dbo].[BACKUPS]

  WHERE [Run_date] >= getdate()-1
  
  AND  [BackupType]= ''D'' AND DaysSinceLastBackup >=1

  OR   [BackupType]= ''I'' AND DaysSinceLastBackup > 1
  
  OR   [BackupType]= ''L'' AND DaysSinceLastBackup  >=2
	ORDER BY Database_Name ASC',
    
	@subject = 'ALERTS-  BACKUP ISSUES' ,
	@attach_query_result_as_file = 1,
	@query_attachment_filename = 'BackupIssues.txt';  
PRINT 'Backup Issues '
*/

GO
-- =============================================
-- Author:		Adrian Sleigh
-- Create date: 2022/01/02 V1.0
-- Item:	memory_usage
-- Description Part of suite of scripts for monitoring
-- =============================================

CREATE PROCEDURE [dbo].[sp_memory_usage]
AS

DECLARE @total_buffer INT;

SELECT @total_buffer = cntr_value
FROM sys.dm_os_performance_counters 
WHERE RTRIM([object_name]) LIKE '%Buffer Manager'
AND counter_name = 'Database Pages';

;WITH src AS
(
SELECT 
database_id, db_buffer_pages = COUNT_BIG(*)
FROM sys.dm_os_buffer_descriptors
--WHERE database_id BETWEEN 5 AND 32766
GROUP BY database_id
)

---table insert
INSERT INTO sql_monitoring.dbo.MEMORY_USAGE

SELECT
Getdate() AS ran_date,
[db_name] = CASE [database_id] WHEN 32767 
THEN 'Resource DB' 
ELSE DB_NAME([database_id]) END,
db_buffer_pages,
db_buffer_MB = db_buffer_pages / 128,
db_buffer_percent = CONVERT(DECIMAL(6,3), 
db_buffer_pages * 100.0 / @total_buffer)
FROM src
ORDER BY db_buffer_MB DESC;
------------------------------------------------------ 

GO
USE [master]
CREATE PROCEDURE [dbo].[sp_ineachdb]
  @command             nvarchar(max),
  @replace_character   nchar(1) = N'?',
  @print_dbname        bit = 0,
  @select_dbname       bit = 0, -- new
  @print_command       bit = 0, -- new
  @print_command_only  bit = 0,
  @suppress_quotename  bit = 0, -- use with caution
  @system_only         bit = 0,
  @user_only           bit = 0,
  @name_pattern        nvarchar(300)  = N'%', 
  @database_list       nvarchar(max)  = NULL,
  @exclude_list        nvarchar(max)  = NULL, -- from First Responder Kit
  @recovery_model_desc nvarchar(120)  = NULL,
  @compatibility_level tinyint        = NULL,
  @state_desc          nvarchar(120)  = N'ONLINE',
  @is_read_only        bit = 0,
  @is_auto_close_on    bit = NULL,
  @is_auto_shrink_on   bit = NULL,
  @is_broker_enabled   bit = NULL,
  @user_access         nvarchar(128)  = NULL  -- new
-- WITH EXECUTE AS OWNER – maybe not a great idea, depending on the security your system
AS
BEGIN
  SET NOCOUNT ON;
  DECLARE @exec   nvarchar(150),
          @sx     nvarchar(18) = N'.sys.sp_executesql',
          @db     sysname,
          @dbq    sysname,
          @cmd    nvarchar(max),
          @thisdb sysname,
          @cr     char(2) = CHAR(13) + CHAR(10);
  CREATE TABLE #ineachdb(id int, name nvarchar(512));
  IF @database_list > N''
  -- comma-separated list of potentially valid/invalid/quoted/unquoted names
  BEGIN
    ;WITH n(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM n WHERE n < 4000),
    names AS
    (
      SELECT name = LTRIM(RTRIM(PARSENAME(SUBSTRING(@database_list, n, 
        CHARINDEX(N',', @database_list + N',', n) - n), 1)))
      FROM n WHERE n <= LEN(@database_list)
        AND SUBSTRING(N',' + @database_list, n, 1) = N','
    ) 
    INSERT #ineachdb(id,name) SELECT d.database_id, d.name
    FROM sys.databases AS d
    WHERE EXISTS (SELECT 1 FROM names WHERE name = d.name)
    OPTION (MAXRECURSION 0);
  END
  ELSE
  BEGIN
    INSERT #ineachdb SELECT database_id, name FROM sys.databases;
  END
  -- first, let's delete any that have been explicitly excluded
  IF @exclude_list > N'' 
  -- comma-separated list of potentially valid/invalid/quoted/unquoted names
  -- exclude trumps include
  BEGIN
    ;WITH n(n) AS (SELECT 1 UNION ALL SELECT n+1 FROM n WHERE n < 4000),
    names AS
    (
      SELECT name = LTRIM(RTRIM(PARSENAME(SUBSTRING(@exclude_list, n, 
        CHARINDEX(N',', @exclude_list + N',', n) - n), 1)))
      FROM n WHERE n <= LEN(@exclude_list)
          AND SUBSTRING(N',' + @exclude_list, n, 1) = N','
    )
    DELETE d FROM #ineachdb AS d
    INNER JOIN names
    ON names.name = d.name
    OPTION (MAXRECURSION 0);
  END
  -- next, let's delete any that *don't* match various criteria passed in
  DELETE dbs FROM #ineachdb AS dbs
  WHERE (@system_only = 1 AND id NOT IN (1,2,3,4))
     OR (@user_only   = 1 AND id     IN (1,2,3,4))
     OR name NOT LIKE @name_pattern
     OR EXISTS
     (
       SELECT 1 FROM sys.databases AS d
       WHERE d.database_id = dbs.id
       AND NOT
       (
         recovery_model_desc     = COALESCE(@recovery_model_desc, recovery_model_desc)
         AND compatibility_level = COALESCE(@compatibility_level, compatibility_level)
         AND is_read_only        = COALESCE(@is_read_only, is_read_only)
         AND is_auto_close_on    = COALESCE(@is_auto_close_on, is_auto_close_on)
         AND is_auto_shrink_on   = COALESCE(@is_auto_shrink_on, is_auto_shrink_on)
         AND is_broker_enabled   = COALESCE(@is_broker_enabled, is_broker_enabled)
       )
     );
  -- if a user access is specified, remove any that are NOT in that state
  IF @user_access IN (N'SINGLE_USER', N'MULTI_USER', N'RESTRICTED_USER')
  BEGIN
    DELETE #ineachdb WHERE 
      CONVERT(nvarchar(128), DATABASEPROPERTYEX(name, 'UserAccess')) <> @user_access;
  END  
  -- finally, remove any that are not *fully* online or we can't access
  DELETE dbs FROM #ineachdb AS dbs
  WHERE EXISTS
  (
    SELECT 1 FROM sys.databases
    WHERE database_id = dbs.id
    AND
    ( 
      @state_desc = N'ONLINE' AND
      (
        [state] & 992 <> 0  -- inaccessible
        OR state_desc <> N'ONLINE' -- not online
        OR HAS_DBACCESS(name) = 0  -- don't have access
        OR DATABASEPROPERTYEX(name, 'Collation') IS NULL -- not fully online. See "status" here:
        -- https://docs.microsoft.com/en-us/sql/t-sql/functions/databasepropertyex-transact-sql
      )
      OR (@state_desc <> N'ONLINE' AND state_desc <> @state_desc)
      OR
      (
        -- from Andy Mallon / First Responders Kit. Make sure that if we're an 
        -- AG secondary, we skip any database where allow connections is off
        SERVERPROPERTY('IsHadrEnabled') = 1
        AND EXISTS
        (
          SELECT 1 FROM sys.dm_hadr_database_replica_states AS drs 
            INNER JOIN sys.availability_replicas AS ar
            ON ar.replica_id = drs.replica_id
            INNER JOIN sys.dm_hadr_availability_group_states ags 
            ON ags.group_id = ar.group_id
            WHERE drs.database_id = dbs.id
            AND ar.secondary_role_allow_connections = 0
            AND ags.primary_replica <> @@SERVERNAME
        )
      )
    )
  );
  -- Well, if we deleted them all...
  IF NOT EXISTS (SELECT 1 FROM #ineachdb)
  BEGIN
    RAISERROR(N'No databases to process.', 1, 0);
    RETURN;
  END
  -- ok, now, let's go through what we have left
  DECLARE dbs CURSOR LOCAL FAST_FORWARD
    FOR SELECT DB_NAME(id), QUOTENAME(DB_NAME(id))
    FROM #ineachdb;
  OPEN dbs;
  FETCH NEXT FROM dbs INTO @db, @dbq;
  DECLARE @msg1 nvarchar(512) = N'Could not run against %s : %s.',
          @msg2 nvarchar(max);
  WHILE @@FETCH_STATUS <> -1
  BEGIN
    SET @thisdb = CASE WHEN @suppress_quotename = 1 THEN @db ELSE @dbq END;
    SET @cmd = REPLACE(@command, @replace_character, REPLACE(@thisdb,'''',''''''));
    BEGIN TRY
      IF @print_dbname = 1
      BEGIN
        PRINT N'/* ' + @thisdb + N' */';
      END
      IF @select_dbname = 1
      BEGIN
        SELECT [ineachdb current database] = @thisdb;
      END
      IF 1 IN (@print_command, @print_command_only)
      BEGIN
        PRINT N'/* For ' + @thisdb + ': */' + @cr + @cr + @cmd + @cr + @cr;
      END
      IF COALESCE(@print_command_only,0) = 0
      BEGIN
        SET @exec = @dbq + @sx;
        EXEC @exec @cmd;
      END
    END TRY
    BEGIN CATCH
      SET @msg2 = ERROR_MESSAGE();
      RAISERROR(@msg1, 1, 0, @db, @msg2);
    END CATCH
    FETCH NEXT FROM dbs INTO @db, @dbq;
  END
  CLOSE dbs; DEALLOCATE dbs;
END
GO

ALTER DATABASE [SQL_Monitoring] SET  READ_WRITE 
GO
----------------------------------------------------
--Create operator for job alerts
USE [msdb]
GO

/****** Object:  Operator [SQL_DBA_SUPPORT]    Script Date: 9/12/2022 8:39:15 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'SQL_DBA_SUPPORT', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'user.address@.com', 
		@category_name=N'[Uncategorized]'
GO

USE [msdb]
GO

/****** Object:  Job [CPU_Gather]    Script Date: 9/12/2022 7:54:04 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 7:54:04 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CPU_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'gathers CPU % usage for each database', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run hourly]    Script Date: 9/12/2022 7:54:04 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run hourly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_getCPU_use 59', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1e3c2f4-dc55-41e9-80dd-e4d7364aa0a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
----------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [CPU_Gather]    Script Date: 9/12/2022 8:42:08 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:08 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CPU_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'gathers CPU % usage for each database', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run hourly]    Script Date: 9/12/2022 8:42:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run hourly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_getCPU_use 59', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1e3c2f4-dc55-41e9-80dd-e4d7364aa0a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--------------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [PLE_Gather]    Script Date: 9/12/2022 8:42:36 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:36 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PLE_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Gathers Page Life Expectancy into PLE table in Dba_admin datababase. Run every 5 mins.', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Page Life Expectancy]    Script Date: 9/12/2022 8:42:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Page Life Expectancy', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE

SQL_Monitoring
GO

INSERT INTO PLE (Timeran,Countername,PagelifeValue)

select getdate(),counter_name,cntr_value

FROM sys.dm_os_performance_counters WHERE
object_name like ''%Buffer Manager%''
AND counter_name = ''Page life expectancy''  ', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Blocking]    Script Date: 9/12/2022 8:42:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Blocking', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_blocking', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 min intervals', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd6ca402e-a666-42d5-bd8a-71f990a4a5f2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-------------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [sp_ConnectionMonitor]    Script Date: 9/12/2022 8:42:54 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:54 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sp_ConnectionMonitor', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect user connections]    Script Date: 9/12/2022 8:42:54 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect user connections', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_Connection_Monitor', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220203, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'62b9e0c7-94d3-474e-a79d-fe0702f9c252'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
----------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [SQL_Monitoring]    Script Date: 9/11/2022 10:51:07 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/11/2022 10:51:07 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SQL_Monitoring', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Age out Data]    Script Date: 9/11/2022 10:51:07 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Age out Data', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'-- =============================================

DELETE  FROM [SQL_Monitoring].[dbo].[CPU_USAGE]
  WHERE SYSTEM_IDLE >= 98

  DELETE FROM [SQL_Monitoring].[dbo].[DB_SIZES]
  WHERE Ran_date <= getdate() -180

  DELETE  FROM [SQL_Monitoring].[dbo].[DRIVE_SPACE_FREE]
  WHERE Ran_date <= getdate() -180

  DELETE FROM [SQL_Monitoring].[dbo].[BACKUPS]
  WHERE  LastBackupDate <= getdate() -180
-----------------------------------------------

DELETE FROM [SQL_Monitoring].[dbo].[BLOCKING]
  WHERE Ran_date <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[CONNECTION_MONITOR]
  WHERE latestLogin <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[CPU_DETAILS]
  WHERE Ran_date <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[DB_ACTIVITY]
  WHERE collected_Date <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[FRAGMENTATION]
  WHERE Ran_date <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[JOB_FAILS]
  WHERE job_ran <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[LOGINS_ISSUE]
  WHERE Ran_date <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[PLE]
  WHERE Timeran <= getdate() -60

DELETE FROM [SQL_Monitoring].[dbo].[WORST_QUERIES]
	WHERE Collected_time <= getdate() -60
----------------------------------------------------------------

', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Failed Jobs]    Script Date: 9/11/2022 10:51:07 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Failed Jobs', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_failed_jobs 7', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Last Backup]    Script Date: 9/11/2022 10:51:07 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Last Backup', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_last_backup

', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Drive Space Free]    Script Date: 9/11/2022 10:51:07 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Drive Space Free', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_drive_space_free', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Worst Queries]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Worst Queries', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'--FROM SQL_MONITORING DATABASE to populate WORST_QUERIES
--job required to run daily
----------------------------------------------------------------------

EXEC [dbo].[sp_ineachdb]''

INSERT INTO SQL_Monitoring.dbo.WORST_QUERIES (database_name,collected_time,object_name,max_logical_reads,max_logical_writes,
total_RW,max_elapsed_time_MS,execution_cost,last_execution_time,execution_count,object_text)

(SELECT TOP 10 
db_name() as database_name,
getdate()as collected_time,
obj.name, 
max_logical_reads, 
max_logical_writes,
max_logical_reads + max_logical_writes as total_RW,
max_elapsed_time,
max_logical_reads + max_logical_writes/execution_count as execution_cost,
last_execution_time,
execution_count,[text]

FROM sys.dm_exec_query_stats a
CROSS APPLY sys.dm_exec_sql_text(sql_handle) hnd
INNER JOIN sys.sysobjects obj on hnd.objectid = obj.id)
ORDER BY max_elapsed_time DESC
''
---END', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Fragmentation]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Fragmentation', 
		@step_id=6, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_fragmentation', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database Sizes]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Sizes', 
		@step_id=7, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_db_Sizes', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Database Activity]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Database Activity', 
		@step_id=8, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_db_Activity', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [CPU Details]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'CPU Details', 
		@step_id=9, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_cpu_details', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Memory Usage]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Memory Usage', 
		@step_id=10, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_memory_usage', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Failed Logins 7 Days]    Script Date: 9/11/2022 10:51:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Failed Logins 7 Days', 
		@step_id=11, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC [SQL_Monitoring].[dbo].[sp_get_failed_login_list_last_week]', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily @24:00', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220206, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'be3b5886-6104-43d3-bad8-c53918a91e39'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
--------------------------------------------------------------------
--Create operator for job alerts
USE [msdb]
GO

/****** Object:  Operator [SQL_DBA_SUPPORT]    Script Date: 9/12/2022 8:39:15 AM ******/
EXEC msdb.dbo.sp_add_operator @name=N'SQL_DBA_SUPPORT', 
		@enabled=1, 
		@weekday_pager_start_time=90000, 
		@weekday_pager_end_time=180000, 
		@saturday_pager_start_time=90000, 
		@saturday_pager_end_time=180000, 
		@sunday_pager_start_time=90000, 
		@sunday_pager_end_time=180000, 
		@pager_days=0, 
		@email_address=N'user.address@.com', 
		@category_name=N'[Uncategorized]'
GO

USE [msdb]
GO

/****** Object:  Job [CPU_Gather]    Script Date: 9/12/2022 7:54:04 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 7:54:04 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CPU_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'gathers CPU % usage for each database', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run hourly]    Script Date: 9/12/2022 7:54:04 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run hourly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_getCPU_use 59', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1e3c2f4-dc55-41e9-80dd-e4d7364aa0a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
----------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [CPU_Gather]    Script Date: 9/12/2022 8:42:08 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:08 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'CPU_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'gathers CPU % usage for each database', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Run hourly]    Script Date: 9/12/2022 8:42:08 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Run hourly', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC SP_getCPU_use 59', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'hourly', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'e1e3c2f4-dc55-41e9-80dd-e4d7364aa0a4'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--------------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [PLE_Gather]    Script Date: 9/12/2022 8:42:36 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:36 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'PLE_Gather', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=2, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Gathers Page Life Expectancy into PLE table in Dba_admin datababase. Run every 5 mins.', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', 
		@notify_email_operator_name=N'SQL_DBA_SUPPORT', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Page Life Expectancy]    Script Date: 9/12/2022 8:42:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Page Life Expectancy', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'USE

SQL_Monitoring
GO

INSERT INTO PLE (Timeran,Countername,PagelifeValue)

select getdate(),counter_name,cntr_value

FROM sys.dm_os_performance_counters WHERE
object_name like ''%Buffer Manager%''
AND counter_name = ''Page life expectancy''  ', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Blocking]    Script Date: 9/12/2022 8:42:36 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Blocking', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_blocking', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 min intervals', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20201124, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'd6ca402e-a666-42d5-bd8a-71f990a4a5f2'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

-------------------------------------------------------------------------
USE [msdb]
GO

/****** Object:  Job [sp_ConnectionMonitor]    Script Date: 9/12/2022 8:42:54 AM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[STATISTICS]]    Script Date: 9/12/2022 8:42:54 AM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[STATISTICS]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[STATISTICS]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'sp_ConnectionMonitor', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[STATISTICS]', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Collect user connections]    Script Date: 9/12/2022 8:42:54 AM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Collect user connections', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'EXEC sp_Connection_Monitor', 
		@database_name=N'SQL_Monitoring', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=15, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20220203, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'62b9e0c7-94d3-474e-a79d-fe0702f9c252'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

--------------------------------END---------------------------------------------




