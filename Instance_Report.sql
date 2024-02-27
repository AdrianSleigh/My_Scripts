
SET NOCOUNT ON
--SQL properties
--Written By Adrian Sleigh 20/8/18 to be used post installation
--save to text and add to server build change in CMDB
--version 2.0 amended 05/01/21
--This has been tested SQL2012 upwards only
--------------------------------------------------------------- 

DECLARE @service_account VARCHAR(50) = ''

SELECT convert(VARCHAR,getdate(),3) + ' ' + ' SQL SERVER INSTANCE REPORT - INSTANCE' + '   '  + @@servername

SET @service_account =  
 (Select servicename FROM sys.dm_server_services
 WHERE servicename LIKE 'SQL Server (%')
  PRINT @service_account
    PRINT '-----------------------------------------'

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
  SUBSTRING(CAST(SERVERPROPERTY('FilestreamShareName') AS varchar(10)),1,20)AS filestreamShareName,  
  SUBSTRING(CAST(SERVERPROPERTY('FilestreamConfiguredLevel') AS varchar(10)),1,20) AS filestreamConfigLevel, 
  SUBSTRING (LOCAL_NET_ADDRESS, 1,12) AS IPAddressOfSQLServer, 
  SUBSTRING (CLIENT_NET_ADDRESS,1,12) AS 'ClientIPAddress' 
 --   [MAXDOP] =  (SELECT CAST(VALUE_IN_USE AS varchar(6) ) FROM SYS.CONFIGURATIONS WHERE NAME='MAX DEGREE OF PARALLELISM'),	
 --   SQLMEMORY = (SELECT CAST( VALUE_IN_USE AS varchar (12) ) FROM SYS.CONFIGURATIONS WHERE NAME='MAX SERVER MEMORY (MB)') 
   FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID

----------------------------------------------------------------------------
--configurations

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

----------------------------------------------------------------------------
PRINT 'DATABASE INFORMATION' 
PRINT '--------------------'

SELECT 
GETDATE() AS executiontime,
SUBSTRING([name],1,30)As databasename,create_date,
compatibility_level AS comp_level,
SUBSTRING(collation_name,1,30)AS collation,
SUBSTRING(recovery_model_desc,1,10)AS recovery_model,
SUBSTRING(page_verify_option_desc,1,10) AS page_verify_option,
is_encrypted
--,
--SUBSTRING(default_language_name,1,10)AS default_lang,
--containment
  FROM sys.databases
----------------------------------------------------------------------------
---FILE INFO
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

--BACKUP DEFAULT
PRINT 'DEFAULT BACKUP LOCATION'
SELECT SUBSTRING(@backupdir,1,100)

----CONFIGURED PBM POLICIES
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
----LIST ALL JOBS
PRINT'SQL AGENT JOB LIST'
PRINT'------------------'
SELECT 
SUBSTRING([name],1,50)AS jobname,
SUBSTRING([description],1,80) AS 'job description', 
[enabled], [date_created], [date_modified] 
FROM    msdb..sysjobs ORDER BY [name]

--LIST ALL SSIS PACKAGES
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
DECLARE @fillfactor VARCHAR (2)= 80
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

   IF @fillfactor <> 80
     BEGIN
   PRINT 'FILL FACTOR IS NOT SET TO VALUE(80%)' SELECT @fillfactor
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
  PRINT '---------END----------'

