-----------------------------------------------------------------
---Add to Primary Always on Server
---Adrian Sleigh 05/04/23  V1.0
---Forces deployed instance to revert to any primary after any patching
-----------------------------------------------------------------

USE [msdb]
GO

/****** Object:  Job [ALWAYS ON MAKE PRIMARYAvailability Group]    Script Date: 4/5/2023 12:07:09 PM ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 4/5/2023 12:07:09 PM ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'ALWAYS ON MAKE PRIMARY [Availability Group]', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Runs 5mins checks this node is still Primary if not it will fail back to this node .', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'sa', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check for Primary local if not failover]    Script Date: 4/5/2023 12:07:09 PM ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check for Primary local if not failover', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'----Move Availability group to a preferred node.
---Create job to run this every few mins
---Adrian Sleigh 05/04/23
---Change <dbTesting> to name of availability group
---------------------------------------------------
---------------------------------------------------
DECLARE @localReplicaRole int

SELECT @localReplicaRole = ROLE FROM [MASTER].sys.dm_hadr_availability_replica_states WHERE is_local = 1;
-- Role = 1 => primary
-- Role = 2 => secondary

PRINT @localReplicaRole

IF (@localReplicaRole =2 )

BEGIN
-- FAILOVER TO PREFERRED PRIMARY NODE.  
USE MASTER ;  
       PRINT  ''PRIMARY IS ON WRONG PREFERRED NODE - MOVING BACK TO PRIMARY''
	   --------------------------------------------------------
               ------Change <dbTesting> to name of availability group
    ALTER AVAILABILITY GROUP CONFAG FAILOVER;   

END
     ELSE 
           BEGIN
                PRINT ''SECONDARY NODE ALL GOOD....''
 
 END
 --------------------------------------------------', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 5 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=5, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20230405, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'08b88c35-b3b1-4483-8309-69938dfa1523'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO
