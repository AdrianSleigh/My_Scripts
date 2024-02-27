----USED TO CREATE A DATABASES AND ASSOCATED TABLES PLUS JOBS TO
----DO PERFOMANCE AND CAPACITY TESTING
----ADRIAN SSLEIGH 13/01/2020
---------------------------------------------------------------
USE [master]
GO

/****** Object:  Database [random_table_data2]    Script Date: 13/01/2020 14:55:54 ******/
CREATE DATABASE [random_table_data2]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = N'random_table_data2', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\random_table_data2.mdf' , SIZE = 121176064KB , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'random_table_data2_log', FILENAME = N'F:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\random_table_data2_log.ldf' , SIZE = 8192000KB , MAXSIZE = 2048GB , FILEGROWTH = 65536KB )
GO

ALTER DATABASE [random_table_data2] SET COMPATIBILITY_LEVEL = 130
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [random_table_data2].[dbo].[sp_fulltext_database] @action = 'enable'
end
GO

ALTER DATABASE [random_table_data2] SET ANSI_NULL_DEFAULT OFF 
GO

ALTER DATABASE [random_table_data2] SET ANSI_NULLS OFF 
GO

ALTER DATABASE [random_table_data2] SET ANSI_PADDING OFF 
GO

ALTER DATABASE [random_table_data2] SET ANSI_WARNINGS OFF 
GO

ALTER DATABASE [random_table_data2] SET ARITHABORT OFF 
GO

ALTER DATABASE [random_table_data2] SET AUTO_CLOSE OFF 
GO

ALTER DATABASE [random_table_data2] SET AUTO_SHRINK OFF 
GO

ALTER DATABASE [random_table_data2] SET AUTO_UPDATE_STATISTICS ON 
GO

ALTER DATABASE [random_table_data2] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO

ALTER DATABASE [random_table_data2] SET CURSOR_DEFAULT  GLOBAL 
GO

ALTER DATABASE [random_table_data2] SET CONCAT_NULL_YIELDS_NULL OFF 
GO

ALTER DATABASE [random_table_data2] SET NUMERIC_ROUNDABORT OFF 
GO

ALTER DATABASE [random_table_data2] SET QUOTED_IDENTIFIER OFF 
GO

ALTER DATABASE [random_table_data2] SET RECURSIVE_TRIGGERS OFF 
GO

ALTER DATABASE [random_table_data2] SET  DISABLE_BROKER 
GO

ALTER DATABASE [random_table_data2] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO

ALTER DATABASE [random_table_data2] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO

ALTER DATABASE [random_table_data2] SET TRUSTWORTHY OFF 
GO

ALTER DATABASE [random_table_data2] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO

ALTER DATABASE [random_table_data2] SET PARAMETERIZATION SIMPLE 
GO

ALTER DATABASE [random_table_data2] SET READ_COMMITTED_SNAPSHOT OFF 
GO

ALTER DATABASE [random_table_data2] SET HONOR_BROKER_PRIORITY OFF 
GO

ALTER DATABASE [random_table_data2] SET RECOVERY SIMPLE 
GO

ALTER DATABASE [random_table_data2] SET  MULTI_USER 
GO

ALTER DATABASE [random_table_data2] SET PAGE_VERIFY CHECKSUM  
GO

ALTER DATABASE [random_table_data2] SET DB_CHAINING OFF 
GO

ALTER DATABASE [random_table_data2] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO

ALTER DATABASE [random_table_data2] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO

ALTER DATABASE [random_table_data2] SET DELAYED_DURABILITY = DISABLED 
GO

ALTER DATABASE [random_table_data2] SET QUERY_STORE = OFF
GO

USE [random_table_data2]
GO

ALTER DATABASE SCOPED CONFIGURATION SET LEGACY_CARDINALITY_ESTIMATION = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET MAXDOP = 0;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET MAXDOP = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET PARAMETER_SNIFFING = ON;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET PARAMETER_SNIFFING = PRIMARY;
GO

ALTER DATABASE SCOPED CONFIGURATION SET QUERY_OPTIMIZER_HOTFIXES = OFF;
GO

ALTER DATABASE SCOPED CONFIGURATION FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = PRIMARY;
GO

ALTER DATABASE [random_table_data2] SET  READ_WRITE 
GO





USE [random_table_data2]
GO
/****** Object:  Table [dbo].[BLOB_TABLE]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[BLOB_TABLE](
	[BLOBName] [nvarchar](max) NULL,
	[Blobdata] [image] NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fyi_random1]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fyi_random1](
	[id] [int] NULL,
	[rand_integer] [int] NULL,
	[rand_number] [numeric](18, 9) NULL,
	[rand_datetime] [datetime] NULL,
	[rand_string] [varchar](80) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fyi_random2]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fyi_random2](
	[id] [int] NULL,
	[rand_integer] [int] NULL,
	[rand_number] [numeric](18, 9) NULL,
	[rand_datetime] [datetime] NULL,
	[rand_string] [varchar](80) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fyi_random3]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fyi_random3](
	[id] [int] NULL,
	[rand_integer] [int] NULL,
	[rand_number] [numeric](18, 9) NULL,
	[rand_datetime] [datetime] NULL,
	[rand_string] [varchar](80) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fyi_random4]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fyi_random4](
	[id] [int] NULL,
	[rand_integer] [int] NULL,
	[rand_number] [numeric](18, 9) NULL,
	[rand_datetime] [datetime] NULL,
	[rand_string] [varchar](80) NULL
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[fyi_random5]    Script Date: 13/01/2020 14:55:13 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[fyi_random5](
	[id] [int] NULL,
	[rand_integer] [int] NULL,
	[rand_number] [numeric](18, 9) NULL,
	[rand_datetime] [datetime] NULL,
	[rand_string] [varchar](80) NULL
) ON [PRIMARY]
GO

-----------------------------------------------------------------------

--------jobs

USE [msdb]
GO

/****** Object:  Job [BOOSTFS BLOB LOAD]    Script Date: 13/01/2020 14:56:31 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13/01/2020 14:56:31 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BOOSTFS BLOB LOAD', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'OURCHESHIRE\ASleigh', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [insert blob]    Script Date: 13/01/2020 14:56:32 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'insert blob', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @row BIGINT

SET @row =0
WHILE @row <1000 BEGIN

INSERT INTO BLOB_TABLE (BLOBName, BLOBData)
 
SELECT ''First test file'', BulkColumn
 
FROM OPENROWSET(Bulk ''C:\temp\test.jpg'', SINGLE_BLOB) AS BLOB
 
 SET @row = @row + 1;

  END', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'5 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=3, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190829, 
		@active_end_date=99991231, 
		@active_start_time=10000, 
		@active_end_time=235959, 
		@schedule_uid=N'a311485d-56f1-4034-be31-16adaa8ead0a'
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

/****** Object:  Job [BOOSTFS DELETE DATA]    Script Date: 13/01/2020 14:56:44 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13/01/2020 14:56:44 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BOOSTFS DELETE DATA', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'No description available.', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'OURCHESHIRE\ASleigh', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DELETE 1 [fyi_random1]]    Script Date: 13/01/2020 14:56:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DELETE 1 [fyi_random1]', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'  SET NOCOUNT ON;
--  SELECT COUNT(*) FROM [fyi_random1]

  DELETE TOP (1) percent FROM [fyi_random1] WHERE 1=1 
 
-- SELECT COUNT(*) FROM [fyi_random1]

', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DELETE 1 [fyi_random2]]    Script Date: 13/01/2020 14:56:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DELETE 1 [fyi_random2]', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'  SET NOCOUNT ON;
--  SELECT COUNT(*) FROM [fyi_random1]

  DELETE TOP (1) percent FROM [fyi_random2] WHERE 1=1 
 
-- SELECT COUNT(*) FROM [fyi_random1]', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DELETE 1 [fyi_random3]    Script Date: 13/01/2020 14:56:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DELETE 1 [fyi_random3', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'  SET NOCOUNT ON;
--  SELECT COUNT(*) FROM [fyi_random1]

  DELETE TOP (1) percent FROM [fyi_random3] WHERE 1=1 
 
-- SELECT COUNT(*) FROM [fyi_random1]

', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [DELETE 1 [fyi_random4]    Script Date: 13/01/2020 14:56:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'DELETE 1 [fyi_random4', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'  SET NOCOUNT ON;
--  SELECT COUNT(*) FROM [fyi_random1]

  DELETE TOP (1) percent FROM [fyi_random4] WHERE 1=1 
 
-- SELECT COUNT(*) FROM [fyi_random1]

', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [delete 1 blob_table]    Script Date: 13/01/2020 14:56:44 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'delete 1 blob_table', 
		@step_id=5, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'SET NOCOUNT ON;
--  SELECT COUNT(*) FROM [fyi_random1]

  DELETE TOP (25) percent FROM [blob_table] WHERE 1=1 
 
-- SELECT COUNT(*) FROM [fyi_random1]

', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'every 10 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=8, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190902, 
		@active_end_date=99991231, 
		@active_start_time=90000, 
		@active_end_time=145959, 
		@schedule_uid=N'd549f708-c99d-45c2-8639-19a889f0e24b'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

---------------------------------------------------------------

USE [msdb]
GO

/****** Object:  Job [BOOSTFS random data load]    Script Date: 13/01/2020 14:57:00 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 13/01/2020 14:57:00 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'BOOSTFS random data load', 
		@enabled=0, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'random test data load', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'OURCHESHIRE\AJ921D', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [random1]    Script Date: 13/01/2020 14:57:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'random1', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @row INT;
DECLARE @string VARCHAR(80), @length INT, @code INT;
SET @row = 0;
WHILE @row < 100000 BEGIN
   SET @row = @row + 1;

   -- Build the random string
   SET @length = ROUND(80*RAND(),0);
   SET @string = '''';
   WHILE @length > 0 BEGIN
      SET @length = @length - 1;
      SET @code = ROUND(32*RAND(),0) - 6;
      IF @code BETWEEN 1 AND 26 
         SET @string = @string + CHAR(ASCII(''a'')+@code-1);
      ELSE
         SET @string = @string + '' '';
   END 

   -- Ready for the record
   SET NOCOUNT ON;
   INSERT INTO fyi_random1 VALUES (
      @row,
      ROUND(2000000*RAND()-1000000,0),
      ROUND(2000000*RAND()-1000000,9),
      CONVERT(DATETIME, ROUND(60000*RAND()-30000,9)),
      @string
   )
END
PRINT ''Rows inserted: ''+CONVERT(VARCHAR(20),@row);
GO', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [random2]    Script Date: 13/01/2020 14:57:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'random2', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @row INT;
DECLARE @string VARCHAR(80), @length INT, @code INT;
SET @row = 0;
WHILE @row < 100000 BEGIN
   SET @row = @row + 1;

   -- Build the random string
   SET @length = ROUND(80*RAND(),0);
   SET @string = '''';
   WHILE @length > 0 BEGIN
      SET @length = @length - 1;
      SET @code = ROUND(32*RAND(),0) - 6;
      IF @code BETWEEN 1 AND 26 
         SET @string = @string + CHAR(ASCII(''a'')+@code-1);
      ELSE
         SET @string = @string + '' '';
   END 

   -- Ready for the record
   SET NOCOUNT ON;
   INSERT INTO fyi_random2 VALUES (
      @row,
      ROUND(2000000*RAND()-1000000,0),
      ROUND(2000000*RAND()-1000000,9),
      CONVERT(DATETIME, ROUND(60000*RAND()-30000,9)),
      @string
   )
END
PRINT ''Rows inserted: ''+CONVERT(VARCHAR(20),@row);
GO', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [random3]    Script Date: 13/01/2020 14:57:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'random3', 
		@step_id=3, 
		@cmdexec_success_code=0, 
		@on_success_action=3, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @row INT;
DECLARE @string VARCHAR(80), @length INT, @code INT;
SET @row = 0;
WHILE @row < 100000 BEGIN
   SET @row = @row + 1;

   -- Build the random string
   SET @length = ROUND(80*RAND(),0);
   SET @string = '''';
   WHILE @length > 0 BEGIN
      SET @length = @length - 1;
      SET @code = ROUND(32*RAND(),0) - 6;
      IF @code BETWEEN 1 AND 26 
         SET @string = @string + CHAR(ASCII(''a'')+@code-1);
      ELSE
         SET @string = @string + '' '';
   END 

   -- Ready for the record
   SET NOCOUNT ON;
   INSERT INTO fyi_random3 VALUES (
      @row,
      ROUND(2000000*RAND()-1000000,0),
      ROUND(2000000*RAND()-1000000,9),
      CONVERT(DATETIME, ROUND(60000*RAND()-30000,9)),
      @string
   )
END
PRINT ''Rows inserted: ''+CONVERT(VARCHAR(20),@row);
GO', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [random4]    Script Date: 13/01/2020 14:57:00 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'random4', 
		@step_id=4, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @row INT;
DECLARE @string VARCHAR(80), @length INT, @code INT;
SET @row = 0;
WHILE @row < 100000 BEGIN
   SET @row = @row + 1;

   -- Build the random string
   SET @length = ROUND(80*RAND(),0);
   SET @string = '''';
   WHILE @length > 0 BEGIN
      SET @length = @length - 1;
      SET @code = ROUND(32*RAND(),0) - 6;
      IF @code BETWEEN 1 AND 26 
         SET @string = @string + CHAR(ASCII(''a'')+@code-1);
      ELSE
         SET @string = @string + '' '';
   END 

   -- Ready for the record
   SET NOCOUNT ON;
   INSERT INTO fyi_random4 VALUES (
      @row,
      ROUND(2000000*RAND()-1000000,0),
      ROUND(2000000*RAND()-1000000,9),
      CONVERT(DATETIME, ROUND(60000*RAND()-30000,9)),
      @string
   )
END
PRINT ''Rows inserted: ''+CONVERT(VARCHAR(20),@row);
GO', 
		@database_name=N'random_table_data2', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'8 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=7, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20190829, 
		@active_end_date=99991231, 
		@active_start_time=80000, 
		@active_end_time=165959, 
		@schedule_uid=N'21181e27-f8f8-4ca4-80c9-f8029ec964cd'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

------------------------------------------------------------