---------------FIND WHATS USING TEMPDB
Adrian Sleigh 20/01/21 V1.0
----Write to table TEMPRESULTS

USE [DBA_Admin]
GO
/*

SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[TEMPRESULTS](
	[QueryExecutionContextDBID] [smallint] NULL,
	[QueryExecContextDBNAME] [nvarchar](128) NULL,
	[ModuleObjectId] [int] NULL,
	[Query_Text] [nvarchar](max) NULL,
	[session_id] [smallint] NULL,
	[request_id] [int] NULL,
	[exec_context_id] [int] NULL,
	[OutStanding_user_objects_page_counts] [bigint] NULL,
	[OutStanding_internal_objects_page_counts] [bigint] NULL,
	[start_time] [datetime] NOT NULL,
	[command] [nvarchar](32) NOT NULL,
	[open_transaction_count] [int] NOT NULL,
	[percent_complete] [real] NOT NULL,
	[estimated_completion_time] [bigint] NOT NULL,
	[cpu_time] [int] NOT NULL,
	[total_elapsed_time] [int] NOT NULL,
	[reads] [bigint] NOT NULL,
	[writes] [bigint] NOT NULL,
	[logical_reads] [bigint] NOT NULL,
	[granted_query_memory] [int] NOT NULL,
	[HOST_NAME] [nvarchar](128) NULL,
	[login_name] [nvarchar](128) NOT NULL,
	[program_name] [nvarchar](128) NULL
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO

/*




--------------------------------------------------------------------------
USE [DBA_Admin]
GO

DECLARE @i INT = 00;

WHILE (@i < 6000)
 BEGIN
  WAITFOR DELAY '00:00:01'

INSERT INTO [dbo].[TEMPRESULTS]
           ([QueryExecutionContextDBID]
           ,[QueryExecContextDBNAME]
           ,[ModuleObjectId]
           ,[Query_Text]
           ,[session_id]
           ,[request_id]
           ,[exec_context_id]
           ,[OutStanding_user_objects_page_counts]
           ,[OutStanding_internal_objects_page_counts]
           ,[start_time]
           ,[command]
           ,[open_transaction_count]
           ,[percent_complete]
           ,[estimated_completion_time]
           ,[cpu_time]
           ,[total_elapsed_time]
           ,[reads]
           ,[writes]
           ,[logical_reads]
           ,[granted_query_memory]
           ,[HOST_NAME]
           ,[login_name]
           ,[program_name])

		   SELECT
st.dbid AS QueryExecutionContextDBID,
DB_NAME(st.dbid) AS QueryExecContextDBNAME,
st.objectid AS ModuleObjectId,
SUBSTRING(st.TEXT,
dmv_er.statement_start_offset/2 + 1,
(CASE WHEN dmv_er.statement_end_offset = -1
THEN LEN(CONVERT(NVARCHAR(MAX),st.TEXT)) * 2
ELSE dmv_er.statement_end_offset
END - dmv_er.statement_start_offset)/2) AS Query_Text,
dmv_tsu.session_id ,
dmv_tsu.request_id,
dmv_tsu.exec_context_id,
(dmv_tsu.user_objects_alloc_page_count - dmv_tsu.user_objects_dealloc_page_count) AS OutStanding_user_objects_page_counts,
(dmv_tsu.internal_objects_alloc_page_count - dmv_tsu.internal_objects_dealloc_page_count) AS OutStanding_internal_objects_page_counts,
dmv_er.start_time,
dmv_er.command,
dmv_er.open_transaction_count,
dmv_er.percent_complete,
dmv_er.estimated_completion_time,
dmv_er.cpu_time,
dmv_er.total_elapsed_time,
dmv_er.reads,dmv_er.writes,
dmv_er.logical_reads,
dmv_er.granted_query_memory,
dmv_es.HOST_NAME,
dmv_es.login_name,
dmv_es.program_name


FROM sys.dm_db_task_space_usage dmv_tsu
INNER JOIN sys.dm_exec_requests dmv_er
ON (dmv_tsu.session_id = dmv_er.session_id AND dmv_tsu.request_id = dmv_er.request_id)
INNER JOIN sys.dm_exec_sessions dmv_es
ON (dmv_tsu.session_id = dmv_es.session_id)
CROSS APPLY sys.dm_exec_sql_text(dmv_er.sql_handle) st
WHERE (dmv_tsu.internal_objects_alloc_page_count + dmv_tsu.user_objects_alloc_page_count) > 0
 AND dmv_es.login_name <> 'WALSALL-1\SleighA_dbadmin'

   SET  @i = @i + 1;
END 
print 'completed'

    