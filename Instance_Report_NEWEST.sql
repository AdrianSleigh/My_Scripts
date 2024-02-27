
SET NOCOUNT ON
--SQL Instance Report
--Written By Adrian Sleigh 20/8/18 to be used post installation
--save to text and add to server build change in CMDB
--version 2.0 amended 05/01/21 added tempdb properties
--version 3.0 added report on user tables present in Master DB
--version 4.0 added suggested best maxdop setting
--version 5.0 added SQL version and catch for old sql
--version 6.0 added service account info and offline databases
--version 7.0 added drive space
--version 8.0 added backup info 16/04/21
--version 9.0 added high availabilty check for clustering,mirroring,logshipping 
--additionally look for encryption keys usage
--version 10.0 added CPU and memory information 19/04/21
--version 11.0 added last SQL server restart
--version 12.0 added port info
--version 13.00 added tables in MSDB database

----------------------------------
SELECT convert(VARCHAR,getdate(),3) + ' ' + ' SQL SERVER INSTANCE REPORT - INSTANCE' + '   '  + @@servername + '  ' + @@Version

SELECT sqlserver_start_time FROM sys.dm_os_sys_info

SELECT  
   CONNECTIONPROPERTY('local_net_address') AS Server_net_address,
   CONNECTIONPROPERTY('local_tcp_port') AS local_tcp_port,
   CONNECTIONPROPERTY('client_net_address') AS myclient_net_address 

Select servicename,service_account FROM sys.dm_server_services

Declare 
@service_account Varchar (20)
SELECT 
  SUBSTRING(SUSER_SNAME(),1,20)AS RanBy, 
  SUBSTRING(HOST_NAME(),1,20) AS RanFrom,
  GETDATE() AS ExecutionTime,
  SUBSTRING(@service_account,1,30) AS Service_account,
  SUBSTRING(CAST(SERVERPROPERTY('MachineName')AS varchar(30)),1,20) AS ComputerName,
  SUBSTRING(CAST(SERVERPROPERTY('ServerName') AS varchar(30)),1,20) AS InstanceName 
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
  SELECT
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultDataPath')AS varchar(50)),1,2) AS DefaultDatadrive, 
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS varchar(50)),1,2)AS DefaultLogdrive, 
  SUBSTRING(CAST(SERVERPROPERTY('IsHadrEnabled') AS varchar(10)),1,20)AS IsHadrEnabled, 
  SUBSTRING(CAST(SERVERPROPERTY('HadrManagerStatus') AS varchar(10)),1,20)AS AlwaysOnStatus,
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSet') AS varchar(3)),1,5) AS SqlCharSet,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrder') AS VARCHAR(10)),1,10) AS SqlSortOrder,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSetName')AS varchar(10)),1,5) AS SqlCharSetName,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrderName')AS varchar(10)),1,20) AS SqlSortOrderName,  
  SUBSTRING(CAST(SERVERPROPERTY('IsIntegratedSecurityOnly')AS varchar(10)),1,20) AS IsIntegratedSecurityOnly  
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
  SELECT
  SUBSTRING(CAST(SERVERPROPERTY('Edition') AS varchar(50)),1,50)AS 'SQL Server Edition',
  SUBSTRING(CAST(SERVERPROPERTY('Collation') AS varchar(10)),1,20)AS Collation,
  SUBSTRING(CAST(SERVERPROPERTY('ProductVersion') AS varchar(10)),1,30)AS ProductVersion,  
  SUBSTRING(CAST(SERVERPROPERTY('ProductLevel') AS varchar(10)),1,20)AS ProductLevel,
  SUBSTRING(CAST(SERVERPROPERTY('IsClustered') AS varchar(10)),1,10)AS IsClustered, 
  SUBSTRING(CAST(SERVERPROPERTY('IsFullTextInstalled')AS varchar(10)),1,10) AS IsFullTextInstalled 
 
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
  SELECT 
  SUBSTRING(CAST(SERVERPROPERTY('FilestreamShareName') AS varchar(20)),1,20)AS filestreamShareName,  
  SUBSTRING(CAST(SERVERPROPERTY('FilestreamConfiguredLevel') AS varchar(10)),1,20) AS filestreamConfigLevel, 
  SUBSTRING (LOCAL_NET_ADDRESS, 1,12) AS IPAddressOfSQLServer, 
  SUBSTRING (CLIENT_NET_ADDRESS,1,12) AS 'ClientIPAddress' 
 --   [MAXDOP] =  (SELECT CAST(VALUE_IN_USE AS varchar(6) ) FROM SYS.CONFIGURATIONS WHERE NAME='MAX DEGREE OF PARALLELISM'),	
 --   SQLMEMORY = (SELECT CAST( VALUE_IN_USE AS varchar (12) ) FROM SYS.CONFIGURATIONS WHERE NAME='MAX SERVER MEMORY (MB)') 
   FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID

-------------------------------------------------------------------------
--GET SERVER CPU AND MEMORY INFO

SET NOCOUNT ON
--GET CPU SPEED
PRINT 'CPU TYPE/SPEED'
 
CREATE TABLE #Temp_cpu
(
Col1 VARCHAR(20),
Col2 VARCHAR(60)
)

INSERT INTO #Temp_cpu
EXEC sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString';

select col2 AS PROCESSOR from #temp_cpu

DROP TABLE #temp_cpu

--GET SERVER MEMORY
PRINT 'SERVER MEMORY ALLOCATED'
SELECT 
      cpu_count,
	  hyperthread_ratio,
	  [physical_memory_kb]/1024 AS 'Server_Memory_MB',
	  [committed_kb]/1024 AS 'Used_for_SQL_MB',
	  [committed_target_kb]/1024 AS 'Allocated_Max_Memory_SQL_MB'
	  FROM sys.dm_os_sys_info
 ------------------------------------------------------------------------
  ---GET SERVICE ACCOUNT INFO V6.0 10/03/21
 PRINT 'SERVICE ACCOUNTS'
 PRINT '----------------' 
SELECT
SUBSTRING(DSS.servicename,1,40),
SUBSTRING(DSS.startup_type_desc,1,20),
SUBSTRING(DSS.status_desc,1,20),
SUBSTRING(CAST(DSS.last_startup_time AS VARCHAR(20)),1,20),
SUBSTRING(DSS.service_account,1,40),
DSS.is_clustered,
SUBSTRING(DSS.cluster_nodename,1,20),
DSS.process_id
   FROM sys.dm_server_services AS DSS;
----------------------------------------------------------------------------
----GET PROXY ACCOUNTS v6.0 10/03/21
PRINT 'PROXY ACCOUNTS'
PRINT '--------------'
USE MSDB
GO

CREATE TABLE #proxytable
(
[proxy_id] INT,
[name] VARCHAR (100),
[credential_identity] VARCHAR (40),
[enabled] BINARY,
[description] VARCHAR (200),
[user_id] VARCHAR (50),
[credential_id] INT,
[credential_identity_exists] BINARY

)
INSERT INTO	#proxytable
EXEC dbo.sp_help_proxy ;  
GO  
SELECT
[proxy_id],[name],[credential_id],[enabled],[description],[credential_id]
FROM #proxytable

DROP TABLE #proxytable
-----------------------------------------
---GET linked server info
-------------------------------------------------------------------------
------------------------------------------------------------------------------
--LINKED SERVER INFO
PRINT 'LINKED SERVER CONNECTIONS'
PRINT '-------------------------'
SELECT 
 a.[server_id],
SUBSTRING (a.[name],1,50)AS 'LinkName',
Substring (c.[name],1,50)AS 'AccountName',
SUBSTRING (a.[product],1,30)AS 'Product',
SUBSTRING (a.[provider],1,30)AS 'Provider',
SUBSTRING (a.[data_source],1,30)AS 'DataSource',
SUBSTRING (a.[provider_string],1,30)AS 'Provider_String',
SUBSTRING  (b.[remote_name],1,40)AS 'Remote_Name',
a.[is_remote_login_enabled],
a.[is_data_access_enabled],
c.[type],
c.[type_desc]

FROM sys.Servers a
LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id
ORDER BY a.[name] ASC
--------------------------------------------------------------------------

----DRIVE SPACE IONFO ADDED 12/04/21
---------GET DRIVE FREE DISK SPACE
------------------------------------------------------------
PRINT 'DRIVES ALLOCATED FOR SQL INSTANCE'
SELECT DISTINCT
    SUBSTRING(volume_mount_point, 1, 1) AS Drive_Mount_Point
    ,total_bytes/1024/1024 AS Total_MB
    ,available_bytes/1024/1024 AS Available_MB
    ,ISNULL(ROUND(available_bytes / CAST(NULLIF(total_bytes, 0) AS FLOAT) * 100, 2), 0) as Percent_Available
FROM
    sys.master_files AS f
CROSS APPLY
    sys.dm_os_volume_stats(f.database_id, f.file_id);
-----------------------------------------------------------------------------
--GET CONFIGURATION SETTINGS
PRINT 'CONFIGURATION SETTINGS' 
PRINT '----------------------'

--CHECK INSTANT FILE INITIALISE
CREATE TABLE #TempErrorLogs
(
	[LogDate] DATETIME 
	,[ProcessInfo] VARCHAR(50)
	,[Description] VARCHAR(MAX)
) 
GO
 
INSERT INTO #TempErrorLogs 
([LogDate], [ProcessInfo], [Description])
EXEC [master].[dbo].[xp_readerrorlog] 0 
GO

select SUBSTRING([Description],1,47) from #TempErrorLogs 
where
   [Description] like 'Database Instant File Initialization: enabled%'
DROP table #TempErrorLogs
---------------------------------------------------------------------
SELECT 
 GETDATE() AS executiontime,
[name]AS property, SUBSTRING(CONVERT(NVARCHAR(30),value_in_use),1,18)AS config_value
FROM sys.configurations
WHERE configuration_id IN (109,117,505,518,1126,1519,1520,1538,1539,1540,1541,1543,1544,1545,1562,1576,1579,1580,16390,16391,16393)
 ;
GO
----------------------------------------------------------------------
---MAXDOP OPTIMAL SETTINGS
--------------------------------------------------

		SET NOCOUNT ON;
		USE MASTER;

		-- Dropping tem table in case it exists
		IF EXISTS (SELECT  * FROM tempdb.dbo.sysobjects o WHERE o.XTYPE IN ('U') and o.id = object_id(N'tempdb..#MaxDOPDB') ) DROP TABLE #MaxDOPDB;

		DECLARE
			@SQLVersion			INT
			,@NumaNodes 		INT
			,@NumCPUs			INT
			,@MaxDop			SQL_VARIANT
			,@RecommendedMaxDop	INT

		-- Getting SQL Server version
		SELECT @SQLVersion = SUBSTRING(CONVERT(VARCHAR,SERVERPROPERTY('ProductVersion')),1,2);

		-- Getting number of NUMA nodes
		SELECT @NumaNodes = COUNT(DISTINCT memory_node_id) FROM sys.dm_os_memory_clerks WHERE memory_node_id!=64

		-- Getting number of CPUs (cores)
		SELECT @NumCPUs = COUNT(scheduler_id) FROM sys.dm_os_schedulers WHERE status = 'VISIBLE ONLINE'

		-- Getting current MAXDOP at instance level
		SELECT @MaxDop = value_in_use from sys.configurations where name ='max degree of parallelism'

		-- MAXDOP calculation (Instance level)
		-- If SQL Server has single NUMA node

		IF @NumaNodes = 1
			IF @NumCPUs < 8 
				-- If number of logical processors is less than 8, MAXDOP equals number of logical processors
				SET @RecommendedMaxDop = @NumCPUs; 
			ELSE
				-- Keep MAXDOP at 8
				SET @RecommendedMaxDop = 8;
		ELSE

		-- If SQL Server has multiple NUMA nodes
			IF (@NumCPUs / @NumaNodes) < 8
				-- IF number of logical processors per NUMA node is less than 8, MAXDOP equals or below logical processors per NUMA node
				SET @RecommendedMaxDop = (@NumCPUs / @NumaNodes);
			ELSE
				--If greater than 8 logical processors per NUMA node - Keep MAXDOP at 8
				SET @RecommendedMaxDop = 8;

		-- If SQL Server is > 2016
		IF CONVERT(INT,@SQLVersion) > 12
			BEGIN
				-- Getting current MAXDOP at database level

				-- Creating temp table
				CREATE TABLE #MaxDOPDB
				(DBName	sysname, configuration_id int, name nvarchar (120), value_for_primary sql_variant, value_for_secondary sql_variant)

				INSERT INTO #MaxDOPDB
				EXEC sp_msforeachdb 'USE [?]; SELECT DB_NAME(), configuration_id, name, value, value_for_secondary FROM sys.database_scoped_configurations WHERE name =''MAXDOP'''
		
				-- Displaying database MAXDOP configuration
				PRINT '------------------------------------------------------------------------';
				PRINT 'MAXDOP at Database level:';
				PRINT '------------------------------------------------------------------------';
				SELECT CONVERT(VARCHAR(30),dbname) as DatabaseName, CONVERT(VARCHAR(10),name) as ConfigurationName, CONVERT(INT,value_for_primary) as "MAXDOP Configured Value" FROM #MaxDOPDB
				WHERE dbname NOT IN ('master','msdb','tempdb','model');
				PRINT '';

				-- Displaying current and recommeded MAXDOP
				PRINT '--------------------------------------------------------------';
				PRINT 'MAXDOP at Instance level:';
				PRINT '--------------------------------------------------------------';
				PRINT 'MAXDOP configured value: ' + CHAR(9) + CAST(@MaxDop AS CHAR);
				PRINT 'MAXDOP recommended value: ' + CHAR(9) + CAST(@RecommendedMaxDop AS CHAR);
				PRINT '--------------------------------------------------------------';
				PRINT '';

				IF (@MaxDop <> @RecommendedMaxDop)
					BEGIN
						PRINT 'In case you want to change MAXDOP to the recommeded value, please use this script:';
						PRINT '';
						PRINT 'EXEC sp_configure ''max degree of parallelism'',' + CAST(@RecommendedMaxDop AS CHAR);
						PRINT 'GO';
						PRINT 'RECONFIGURE WITH OVERRIDE;';
					END
			END;
		ELSE
			BEGIN
				-- Displaying current and recommeded MAXDOP
				PRINT '--------------------------------------------------------------';
				PRINT 'MAXDOP at Instance level:';
				PRINT '--------------------------------------------------------------';
				PRINT 'MAXDOP configured value: ' + CHAR(9) + CAST(@MaxDop AS CHAR);
				PRINT 'MAXDOP recommended value: ' + CHAR(9) + CAST(@RecommendedMaxDop AS CHAR);
				PRINT '--------------------------------------------------------------';
				PRINT '';

				IF (@MaxDop <> @RecommendedMaxDop)
					BEGIN
						PRINT 'In case you want to change MAXDOP to the recommeded value, please use this script:';
						PRINT '';
						PRINT 'EXEC sp_configure ''max degree of parallelism'',' + CAST(@RecommendedMaxDop AS CHAR);
						PRINT 'GO';
						PRINT 'RECONFIGURE WITH OVERRIDE;';
					END
			END;
	

----------------------------------------------------------------------------
--GET DATABASE INFO
PRINT '                                            '
PRINT 'DATABASE INFORMATION' 
PRINT '--------------------'

SELECT 
GETDATE() AS executiontime,
SUBSTRING([name],1,50)As databasename,create_date,
compatibility_level AS comp_level,
SUBSTRING(collation_name,1,30)AS collation,
SUBSTRING(recovery_model_desc,1,10)AS recovery_model,
SUBSTRING(page_verify_option_desc,1,10) AS page_verify_option,
is_encrypted
--,
--SUBSTRING(default_language_name,1,10)AS default_lang,
  FROM sys.databases
 
---------------------------------------------------------------------------
--GET OFFLINE DATABASES
PRINT 'OFFLINE DATABASE LIST'
SELECT
db.name AS Offline_databases,
mf.name AS dbFilename,
mf.type_desc,
mf.physical_name AS filelocation
FROM
sys.databases db
INNER JOIN sys.master_files mf
ON db.database_id = mf.database_id
WHERE
db.state = 6 -- OFFLINE
----------------------------------------------------------------------------
--GET CLUSTER INFO
PRINT 'CLUSTERED INSTANCE'
SELECT NodeName, status, status_description, is_current_owner   
FROM sys.dm_os_cluster_nodes;  
---------------------------------------------------
--GET AVAILABILITY GROUP INFO
PRINT 'ALWAYS ON AVAILABILITY GROUP'
SELECT
AG.name AS [AvailabilityGroupName],
ISNULL(agstates.primary_replica, '') AS [PrimaryReplicaServerName],
ISNULL(arstates.role, 3) AS [LocalReplicaRole],
dbcs.database_name AS [DatabaseName],
ISNULL(dbrs.synchronization_state, 0) AS [SynchronizationState],
ISNULL(dbrs.is_suspended, 0) AS [IsSuspended],
ISNULL(dbcs.is_database_joined, 0) AS [IsJoined]
FROM master.sys.availability_groups AS AG
LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states as agstates
   ON AG.group_id = agstates.group_id
INNER JOIN master.sys.availability_replicas AS AR
   ON AG.group_id = AR.group_id
INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
   ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
   ON arstates.replica_id = dbcs.replica_id
LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
   ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
ORDER BY AG.name ASC, dbcs.database_name
----------------------------------------------------
---GET MIRRORED DATABASES
PRINT 'MIRRORED DATABASES'
SELECT d.name AS Database_Name
,CASE
WHEN dm.mirroring_state is NULL THEN 'Not Mirrored'
ELSE 'Mirrored'
END AS Mirroring_Status
FROM sys.databases d JOIN sys.database_mirroring dm
ON d.database_id=dm.database_id
WHERE dm.mirroring_state IS NOT NULL
ORDER BY d.name
--------------------------------------------------
--GET LOGSHIPPED DATABASES
PRINT 'LOG SHIPPED DATABASE JOBS'
SELECT * 
FROM msdb.dbo.sysjobs 
WHERE category_id = 6
--------------------------------------------------
--GET ENCRYPTION KEY DATES
PRINT 'ENCRYPTION KEYS'
SELECT name, key_length, algorithm_desc, create_date, modify_date
FROM sys.symmetric_keys;

SELECT name, algorithm_desc 
FROM sys.asymmetric_keys;

SELECT name, subject, start_date, expiry_date 
FROM sys.certificates
--------------------------------------------------
---GET FILE INFO
PRINT 'FILE INFORMATION' 
PRINT '----------------'
SELECT
    SUBSTRING(D.name,1,50)AS databasename,
	file_id, 
	F.size AS KB,
	F.size*8/1024 AS MB,
	SUBSTRING(F.physical_name,1,130) AS physicalfile,
    SUBSTRING(F.state_desc,1,10) AS OnlineStatus
    
FROM 
    sys.master_files F
    INNER JOIN sys.databases D ON D.database_id = F.database_id
	WHERE D.name NOT IN('model','msdb','master','tempdb')
ORDER BY
    D.name

	DECLARE @backupdir nvarchar(4000);
EXEC master.dbo.xp_instance_regread 
 N'HKEY_LOCAL_MACHINE'
 , N'Software\Microsoft\MSSQLServer\MSSQLServer'
 , N'BackupDirectory'
 , @backupdir output;

--GET BACKUP DEFAULT LOCATION
PRINT 'DEFAULT BACKUP LOCATION'
SELECT SUBSTRING(@backupdir,1,100)

---GET TEMPDB INFO
PRINT 'TEMPDB PROPERTIES'
PRINT '-------------------'
SELECT 
 SUBSTRING (name, 1,80)AS FileName
,SUBSTRING(type_desc,1,10)
,CONVERT(INT,size * 1.0 / 128) AS 'InitialSize(MB)'
,SUBSTRING(physical_name,1,100)
,CASE max_size 
  WHEN 0
     THEN 'Autogrowth is off.'
  WHEN - 1
     THEN 'Autogrowth is on.'
       ELSE 'Log file grows to a maximum size of 2 TB.'
  END
,CONVERT(INT,ROUND((growth *7.82)/1000,0)) AS 'AutoGrowth(MB)'
,'GrowthIncrement' = CASE
   WHEN growth = 0
      THEN 'Size is fixed.'
      WHEN growth > 0
       AND is_percent_growth = 0
       THEN 'Growth value is in 8-KB pages.'
    ELSE 'Growth value is a percentage.'
   END
FROM tempdb.sys.database_files;
GO

----CHECK CONFIGURED PBM POLICIES
PRINT 'PBM CONFIGURED POLICIES'
PRINT '-------------------'
USE msdb;  
GO  
SELECT
SUBSTRING([name],1,40) as PBM_policy,description
FROM syspolicy_policies
WHERE is_enabled =1  
GO  
-----------------------------------
----GET LIST ALL JOBS
PRINT'SQL AGENT JOB LIST'
PRINT'------------------'
SELECT 
SUBSTRING([name],1,50)AS jobname,
SUBSTRING([description],1,80) AS 'job description', 
[enabled], [date_created], [date_modified] 
FROM    msdb..sysjobs ORDER BY [name]

--GET LIST ALL SSIS PACKAGES
PRINT 'SSIS PACKAGES IN MSDB '
PRINT '----------------------'

-- List all SSIS packages stored in msdb database. 
SELECT

 SUBSTRING(PCK.name,1,70) AS packagename ,
 SUBSTRING(PCK.[description],1,100) AS [description] ,
 SUBSTRING(FLD.foldername,1,50) AS foldername ,
      CASE PCK.packagetype 
            WHEN 0 THEN 'Default client' 
            WHEN 1 THEN 'I/O Wizard' 
            WHEN 2 THEN 'DTS Designer' 
            WHEN 3 THEN 'Replication' 
            WHEN 5 THEN 'SSIS Designer' 
            WHEN 6 THEN 'Maintenance Plan' 
            ELSE 'Unknown' END AS packagetype ,
    SUBSTRING(LG.name,1,20) AS ownername ,
      PCK.isencrypted AS IsEncrypted, 
      PCK.createdate AS CreateDate ,
      CONVERT(varchar(10), vermajor) 
       + '.' + CONVERT(varchar(10), verminor) 
       + '.' + CONVERT(varchar(10), verbuild) AS version ,
      SUBSTRING(PCK.vercomments,1,100) AS versioncomment ,
      DATALENGTH(PCK.packagedata) AS packagesize 
 FROM msdb.dbo.sysssispackages
  AS PCK 
     INNER JOIN msdb.dbo.sysssispackagefolders AS FLD 
         ON PCK.folderid = FLD.folderid 
     INNER JOIN sys.syslogins AS LG 
	          ON PCK.ownersid = LG.sid 
		WHERE	  FLD.foldername  NOT like'Data Collector%'
ORDER BY PCK.name;
------------------------------------------------------------
PRINT 'SSIS PACKAGES IN SSISDB '
PRINT '-----------------------'

IF EXISTS
(SELECT [name]
   FROM master.dbo.sysdatabases where [name] like 'SSISDB') 

   BEGIN   
   SELECT 
	pk.project_id, 
	SUBSTRING(pj.name,1,50) AS 'folder', 
	SUBSTRING(pk.name,1,70) AS packagename, 
	SUBSTRING(pj.deployed_by_name,1,30)AS 'deployed_by' 
       FROM
	SSISDB.catalog.packages pk JOIN SSISDB.catalog.projects pj 
	ON (pk.project_id = pj.project_id)
	
      ORDER BY	folder,	pk.name
    END
	
	ELSE 

	PRINT''

PRINT '----------------------'

PRINT 'POTENTIAL ISSUES FOUND'
PRINT '----------------------'
DECLARE @service_account VARCHAR(50) = ''
DECLARE @fillfactor VARCHAR (2)= 0
DECLARE @maxdop VARCHAR(2)= 0
DECLARE @costthreshhold VARCHAR(2)=50
DECLARE @DAC VARCHAR(1)= 1
DECLARE @advanced VARCHAR(1)=1

SET @fillfactor =
  (SELECT 
    CAST(value_in_use AS varchar(2) ) FROM sys.configurations
     WHERE (configuration_id = 109)
	 )
   --PRINT @fillfactor
SET @maxdop =
  (SELECT 
    CAST(value_in_use AS varchar(2) ) FROM sys.configurations
     WHERE (configuration_id = 1539)
	 )
  -- PRINT @maxdop
SET @costthreshhold =
  (SELECT 
    CAST(value_in_use AS varchar(2) ) FROM sys.configurations
     WHERE (configuration_id = 1538)
	 )
  -- PRINT @costthreshhold
SET @DAC =
  (SELECT 
    CAST(value_in_use AS varchar(2) ) FROM sys.configurations
     WHERE (configuration_id = 1576)
	 )
  -- PRINT @DAC
SET @advanced =
  (SELECT 
    CAST(value_in_use AS varchar(2) ) FROM sys.configurations
     WHERE (configuration_id = 1576)
	 )
  -- PRINT @advanced

   IF @fillfactor <> 100 
   OR @fillfactor <> 0
     BEGIN
   PRINT 'FILL FACTOR IS NOT SET TO VALUE(100%)' SELECT @fillfactor
   END
     ELSE  
      PRINT ''
    
	 IF @maxdop <> 0
     BEGIN
   PRINT 'MAXDOP HAS NOT BEEN SET TO VALUE(0)' SELECT @maxdop
   END
     ELSE  
       PRINT  ''
      
	   IF  @costthreshhold <> 50
     BEGIN 
   PRINT 'COST THRESHHOLD FOR PARALLELISM HAS NOT BEEN SET TO VALUE(50)' SELECT @costthreshhold
   END
      ELSE  
        PRINT ''
      
	    IF  @DAC <> 1
   BEGIN
   PRINT 'REMOTE ADMIN CONNECTION NOT ENABLED (DAC)' SELECT @DAC
   END
      ELSE  
        PRINT ''

          IF  @advanced <> 1
   BEGIN
   PRINT 'SHOW ADVANCED OPTIONS NOT ENABLED (1)' SELECT @advanced 
   END
     ELSE  
       PRINT ''
  ----------------------------------------------------------------
--FIND NON SYSTEM TABLES IN MASTER DB ALONG WITH LAST USED INFO
--Adrian Sleigh 13/01/21
--------------------------------------------------------------

PRINT 'USER TABLES PRESENT IN SYSTEM DATABASES' 
PRINT '----------------------'

USE MASTER;
SELECT SUBSTRING(name,1,50) AS Tables_in_MASTER, 
       SUBSTRING(type_desc,1,20), create_date, is_ms_shipped 
FROM sys.objects 
WHERE type = 'U'
    AND is_ms_shipped = 0;
GO

USE MSDB;
SELECT SUBSTRING(name,1,50)AS Tables_in_MSDB, 
       SUBSTRING(type_desc,1,20), create_date, is_ms_shipped 
FROM sys.objects 
WHERE type = 'U'
    AND is_ms_shipped = 0;
GO


--  PRINT '---------END----------'
--------------------BACKUP INFORMATION FOR 1 WEEK
		USE MSDB
		 SELECT 
               SUBSTRING ([database_name],1,50) as 'DB',
			   [backup_start_date] as 'backup start',
			   [backup_finish_date] as 'backup finish',
               SUBSTRING([physical_device_name],1,90) as BackupLocation,
				[type],[backup_size] as 'Size in KB' ,
				SUBSTRING([recovery_model],1,10) as 'Model',
                [is_snapshot]as 'Snapshot',
				[is_copy_only],
                SUBSTRING([name],1,40)as 'backup utility',
				SUBSTRING([user_name],1,26) as 'utility account'
           FROM backupset 
		   JOIN msdb.dbo.backupmediafamily
             ON(backupset.media_set_id=backupmediafamily.media_set_id)
		WHERE backup_finish_date >= DATEADD(week, -1, GETDATE())
		AND type like 'D'
	    ORDER BY database_name ,backup_start_date DESC
--------------------------------------------------------------------------------------------