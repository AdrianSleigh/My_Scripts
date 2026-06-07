USE [msdb]
GO

/****** Object:  Job [Auto_Enable_Availability_Releated_Jobs]    Script Date: 31/10/2018 10:25:13 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [Database Maintenance]    Script Date: 31/10/2018 10:25:13 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'Database Maintenance' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'Database Maintenance'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'Auto_Enable_Availability_Releated_Jobs', 
		@enabled=1, 
		@notify_level_eventlog=0, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'Adrian Sleigh---Checks for failover and automatically sets job status 
enable\disable on key backup and index jobs', 
		@category_name=N'Database Maintenance', 
		@owner_login_name=N'topdog', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Set_availability_job_status]    Script Date: 31/10/2018 10:25:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Set_availability_job_status', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'---select * from sys.dm_hadr_availability_replica_states
---Adrian Sleigh 26/02/18 Auto enable availability jobs in the event of failover
------------------------------------------------------------------------------------------------------------------------

DECLARE @localReplicaRole int

select @localReplicaRole = Role from [master].sys.dm_hadr_availability_replica_states where is_local = 1;
-- Role = 1 => primary
-- Role = 2 => secondary

IF (@localReplicaRole =1 )

BEGIN

UPDATE J
 SET J.Enabled = 1
  FROM MSDB.dbo.sysjobs J
  INNER JOIN MSDB.dbo.syscategories C
   ON J.category_id = C.category_id
    WHERE C.[Name] = ''Db_Available'';
END

ELSE 

BEGIN

UPDATE J
 SET J.Enabled = 0
  FROM MSDB.dbo.sysjobs J
  INNER JOIN MSDB.dbo.syscategories C
   ON J.category_id = C.category_id
    WHERE C.[Name] = ''Db_Available'';
END', 
		@database_name=N'msdb', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Check if Principal]    Script Date: 31/10/2018 10:25:13 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Check if Principal', 
		@step_id=2, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'DECLARE @localReplicaRole int

select @localReplicaRole = Role from [master].sys.dm_hadr_availability_replica_states where is_local = 1;
-- Role = 1 => primary
-- Role = 2 => secondary

IF (@localReplicaRole =1 )

BEGIN

-- Enables status of the job NightlyBackups.  
USE msdb ;  

EXEC dbo.sp_update_job  
 @job_name = N''DatabaseBackup - USER_DATABASES - FULL'',  
 @enabled = 1 ;  

 EXEC dbo.sp_update_job  
 @job_name = N''DatabaseBackup - USER_DATABASES - DIFF'',  
 @enabled = 1 ;  

EXEC dbo.sp_update_job  
 @job_name = N''DatabaseBackup - USER_DATABASES - LOG'',  
 @enabled = 1 ;  

EXEC dbo.sp_update_job  
 @job_name = N''DatabaseIntegrityCheck - USER_DATABASES'',  
 @enabled = 1 ;  

EXEC dbo.sp_update_job  
 @job_name = N''IndexOptimize - USER_DATABASES'',  
 @enabled = 1 ;  

 END
 --------------------------------------------------', 
		@database_name=N'master', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 2
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Every 15 mins', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=4, 
		@freq_subday_interval=1, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20180226, 
		@active_end_date=99991231, 
		@active_start_time=0, 
		@active_end_time=235959, 
		@schedule_uid=N'6a76381d-c6b4-4853-88ae-4bdff2e8e1ef'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:
GO

