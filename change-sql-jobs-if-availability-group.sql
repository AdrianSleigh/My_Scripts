
--TEST FOR AVAILABILITY GROUP PRESENT
--AND IF FOUND ALTER BACKUP JOBS TO USE AVAILABILITY GROUP INSTEAD
--Adrian Sleigh 07/01/19
-------------------------------------------------------------------------- 
DECLARE @Availability INT
SET @Availability =(SELECT COUNT (*)FROM master.sys.availability_groups)
PRINT 'number of availability groups ' PRINT @availability
--SET @Availability = 1

IF @Availability <> 0


BEGIN

PRINT 'Amended backup jobs to use @AvailabilityGroup backup option'
USE [msdb]

EXEC msdb.dbo.sp_update_jobstep @job_Name=N'DatabaseBackup - USER_DATABASES - FULL', 
@step_id=1 ,@command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "EXECUTE [dbo].[DatabaseBackup] @AvailabilityGroups = ''ALL_AVAILABILITY_GROUPS'', @Directory = N''\\S0181BKPSSQLNAT\Backups2'', @BackupType = ''FULL'', @Verify = ''Y'', @CleanupTime = NULL, @CheckSum = ''Y'', @LogToTable = ''Y''" -b'

EXEC msdb.dbo.sp_update_jobstep @job_Name=N'DatabaseBackup - USER_DATABASES - DIFF', 
@step_id=1 , 
              @command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "EXECUTE [dbo].[DatabaseBackup] @AvailabilityGroups = ''ALL_AVAILABILITY_GROUPS'', @Directory = N''\\S0181BKPSSQLNAT\Backups2'', @BackupType = ''DIFF'', @Verify = ''Y'', @CleanupTime = NULL, @CheckSum = ''Y'', @LogToTable = ''Y''" -b'

EXEC msdb.dbo.sp_update_jobstep @job_Name=N'DatabaseBackup - USER_DATABASES - LOG', 
@step_id=1 , 
              @command=N'sqlcmd -E -S $(ESCAPE_SQUOTE(SRVR)) -d master -Q "EXECUTE [dbo].[DatabaseBackup] @AvailabilityGroups = ''ALL_AVAILABILITY_GROUPS'', @Directory = N''\\S0181BKPSSQLNAT\Backups2'', @BackupType = ''LOG'', @Verify = ''Y'', @CleanupTime = NULL, @CheckSum = ''Y'', @LogToTable = ''Y''" -b'
              
END
     ELSE

BEGIN

PRINT 'No availability group on this instance'
USE [msdb]

END
------------------------------------------------------------------------