SET NOCOUNT ON
--SQL Instance Report
--Written By Adrian Sleigh V1.00 20/8/18
--Version 23.10 revised code and tidy 26/08/25 remove stats check
----------------------------------------------------
PRINT N'📊 Generating Report...';

SELECT
    CONVERT(VARCHAR, GETDATE(), 3) + 
    ' MSSQL SQL SERVER REPORT - INSTANCE NAME IS ' + 
    @@SERVERNAME + 
    ' | Last SQL Restart: ' + 
    CONVERT(VARCHAR, sqlserver_start_time, 120) --AS [Report Header]
FROM 
    sys.dm_os_sys_info;

--CHECK SQL VERSION---------------------------------
DECLARE @CurrentVersion VARCHAR(20) = CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR);
DECLARE @MajorVersion INT = CAST(LEFT(@CurrentVersion, CHARINDEX('.', @CurrentVersion) - 1) AS INT);
DECLARE @LatestVersion VARCHAR(20);
DECLARE @VersionName VARCHAR(50);

-- Set latest version based on major version

IF @MajorVersion = 16
BEGIN
    SET @LatestVersion = '16.0.4205.1'; -- SQL Server 2022 CU20 July 2025
    SET @VersionName = 'SQL Server 2022';
END

ELSE IF @MajorVersion = 15
BEGIN
    SET @LatestVersion = '15.0.4435.7'; -- SQL Server 2019 CU32 July 2025
    SET @VersionName = 'SQL Server 2019';
END

ELSE IF @MajorVersion = 14
BEGIN
    SET @LatestVersion = '14.0.3456.2'; -- SQL Server 2017 CU31
    SET @VersionName = 'SQL Server 2017';
END
ELSE IF @MajorVersion = 13
BEGIN
    SET @LatestVersion = '13.0.6460.7'; -- SQL Server 2016 SP3 CU9
    SET @VersionName = 'SQL Server 2016';
END
ELSE IF @MajorVersion = 12
BEGIN
    SET @LatestVersion = '12.0.6329.1'; -- SQL Server 2014 SP3 CU4
    SET @VersionName = 'SQL Server 2014';
END
ELSE IF @MajorVersion = 11
BEGIN
    SET @LatestVersion = '11.0.7462.6'; -- SQL Server 2012 SP4 CU4
    SET @VersionName = 'SQL Server 2012';
END
ELSE IF @MajorVersion = 10
BEGIN
    SET @LatestVersion = '10.50.6560.0'; -- SQL Server 2008 R2 SP3 GDR
    SET @VersionName = 'SQL Server 2008 R2';
END
ELSE
BEGIN
    PRINT N'⚠️ POSSIBLE UNSUPPORTED VERSION: ' + @CurrentVersion;
    RETURN;
END

PRINT 'Detected Version: ' + @VersionName;
PRINT 'Current SQL Server Version: ' + @CurrentVersion;
PRINT 'Latest Known Version August 2025: ' + @LatestVersion;

IF @CurrentVersion < @LatestVersion
    PRINT N'⚠️ Update Required: Your ' + @VersionName + ' instance is not fully patched !';
ELSE
    PRINT N'✅ Up to Date: Your ' + @VersionName + ' instance is likely running the latest patch.';
-----------------------------------------------------------------
--GET INSTANCE PROPERTIES
SELECT 
  SUBSTRING(SUSER_SNAME(),1,20)AS RanBy, 
  SUBSTRING(HOST_NAME(),1,20) AS RanFrom,
  SUBSTRING(CAST(SERVERPROPERTY('MachineName')AS varchar(20)),1,20) AS ComputerName,
  SUBSTRING(CAST(SERVERPROPERTY('Edition') AS varchar(30)),1,30)AS 'SQL Server Edition',
  SUBSTRING(CAST(SERVERPROPERTY('Collation') AS varchar(25)),1,25)AS Collation,
  SUBSTRING(CAST(SERVERPROPERTY('IsClustered') AS varchar(10)),1,10)AS IsClustered, 
  SUBSTRING(CAST(SERVERPROPERTY('IsFullTextInstalled')AS varchar(10)),1,10) AS IsFullTextInstalled 
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
SELECT 
    SUBSTRING (CAST(SERVERPROPERTY('ProductLevel' ) AS VARCHAR),1,10) AS [Product Level],               
    SUBSTRING(CAST(SERVERPROPERTY('EngineEdition') AS VARCHAR),1,10) AS [Engine Edition],        
    SUBSTRING(CAST(SERVERPROPERTY('ProductUpdateLevel') AS VARCHAR),1,16) AS [Update Level],     
    SUBSTRING(CAST(SERVERPROPERTY('ProductUpdateReference') AS VARCHAR),1,16) AS [Update Ref],    
    SUBSTRING(CAST(SERVERPROPERTY('BuildClrVersion')  AS VARCHAR),1,16) AS[CLR Version],
    SUBSTRING(CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(16)),1,16) AS Server_net_address,
    SUBSTRING(CAST(CONNECTIONPROPERTY('local_tcp_port')AS VARCHAR (10)),1,10) AS local_tcp_port,
    SUBSTRING(CAST(CONNECTIONPROPERTY('client_net_address') AS VARCHAR(16)),1,16) AS myclient_net_address

  SELECT
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultDataPath')AS varchar(50)),1,2) AS DefaultDatadrive, 
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS varchar(50)),1,2)AS DefaultLogdrive, 
  SUBSTRING(CAST(SERVERPROPERTY('IsHadrEnabled') AS varchar(10)),1,20)AS IsHadrEnabled, 
  SUBSTRING(CAST(SERVERPROPERTY('HadrManagerStatus') AS varchar(10)),1,20)AS AlwaysOnStatus,
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSet') AS varchar(10)),1,10) AS SqlCharSet,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrder') AS VARCHAR(10)),1,10) AS SqlSortOrder,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSetName')AS varchar(10)),1,10) AS SqlCharSetName,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrderName')AS varchar(20)),1,20) AS SqlSortOrderName,  
  SUBSTRING(CAST(SERVERPROPERTY('IsIntegratedSecurityOnly')AS varchar(10)),1,20) AS IsIntegratedSecurityOnly  
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

------------------------------------
---CHECK MEMORY SETTINGS 14/08/25
------------------------------------
-- Declare variables
DECLARE @TotalMemoryMB INT, @AvailableMemoryMB INT;
DECLARE @AvailablePercent DECIMAL(18,2);
DECLARE @CurrentMaxMemoryMB INT, @SuggestedMaxMemoryMB INT;
DECLARE @WorkloadRole VARCHAR(30);
DECLARE @SSISPresent BIT = 0;
DECLARE @SSRSPresent BIT = 0;
DECLARE @UserDBCount INT;
DECLARE @MemoryDiffPercent DECIMAL(18,2);

-- Detect SSIS
IF EXISTS (
    SELECT 1
    FROM sysdatabases
    WHERE name LIKE '%SSISDB%'
)
    SET @SSISPresent = 1;

-- Detect SSRS
IF EXISTS (
    SELECT 1
    FROM sysdatabases
    WHERE name LIKE '%ReportServer%'
)
    SET @SSRSPresent = 1;

-- Count user databases (excluding system databases)
SELECT @UserDBCount = COUNT(*)
FROM sys.databases
WHERE database_id > 4 AND state_desc = 'ONLINE';

-- Determine workload role
IF @SSISPresent = 1 AND @SSRSPresent = 1 AND @UserDBCount > 1
    SET @WorkloadRole = 'SSRS/SSIS-Mixed';
ELSE IF @SSISPresent = 1 AND @UserDBCount > 1
    SET @WorkloadRole = 'SSIS-Mixed';
ELSE IF @SSRSPresent = 1 AND @UserDBCount > 1
    SET @WorkloadRole = 'SSRS-Mixed';
ELSE IF @SSISPresent = 1
    SET @WorkloadRole = 'SSIS';
ELSE IF @SSRSPresent = 1
    SET @WorkloadRole = 'SSRS';
ELSE
    SET @WorkloadRole = 'SQL';

-- Get total and available memory
SELECT 
    @TotalMemoryMB = total_physical_memory_kb / 1024,
    @AvailableMemoryMB = available_physical_memory_kb / 1024
FROM sys.dm_os_sys_memory;

-- Get current SQL Server max memory setting
SELECT @CurrentMaxMemoryMB = CONVERT(INT, value_in_use)
FROM sys.configurations
WHERE name = 'max server memory (MB)';

-- Calculate available memory percentage
SET @AvailablePercent = 
    (CAST(@AvailableMemoryMB AS DECIMAL(18,2)) / CAST(@TotalMemoryMB AS DECIMAL(18,2))) * 100;

-- Determine suggested max memory based on workload
IF @WorkloadRole = 'SQL'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.80 AS INT);
ELSE IF @WorkloadRole = 'SSIS'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.50 AS INT);
ELSE IF @WorkloadRole = 'SSRS'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.65 AS INT);
ELSE IF @WorkloadRole = 'SSIS-Mixed'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.45 AS INT);
ELSE IF @WorkloadRole = 'SSRS-Mixed'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.60 AS INT);
ELSE IF @WorkloadRole = 'SSRS/SSIS-Mixed'
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.40 AS INT);
ELSE
    SET @SuggestedMaxMemoryMB = CAST(@TotalMemoryMB * 0.75 AS INT); -- fallback

-- Calculate percentage difference with safe precision
SET @MemoryDiffPercent = 
    ((CAST(@CurrentMaxMemoryMB AS DECIMAL(18,2)) - CAST(@SuggestedMaxMemoryMB AS DECIMAL(18,2))) * 100.0)
    / CAST(@SuggestedMaxMemoryMB AS DECIMAL(18,2));

-- Output memory status
PRINT '--- Memory Health Check ---------';
PRINT '---------------------------------'
PRINT 'Workload Role Detected: ' + @WorkloadRole;
PRINT 'User Databases Online: ' + CAST(@UserDBCount AS VARCHAR);
PRINT 'Total Physical Memory (MB): ' + CAST(@TotalMemoryMB AS VARCHAR);
PRINT 'Available Physical Memory (MB): ' + CAST(@AvailableMemoryMB AS VARCHAR);
PRINT 'Available Memory Percentage: ' + CAST(@AvailablePercent AS VARCHAR) + '%';
PRINT 'Current SQL Server Max Memory (MB): ' + CAST(@CurrentMaxMemoryMB AS VARCHAR);
PRINT 'Suggested Max Server Memory (MB): ' + CAST(@SuggestedMaxMemoryMB AS VARCHAR);
PRINT '----------------------------------------------'

-- Recommendation with tolerance
IF @MemoryDiffPercent > 10
BEGIN
    PRINT N'⚠️ SQL Server is using more memory than recommended for this workload.';
    PRINT N'💡 Consider reducing max server memory to ' + CAST(@SuggestedMaxMemoryMB AS VARCHAR) + ' MB.';
END
ELSE IF @MemoryDiffPercent < -10
BEGIN
    PRINT N'⚠️ SQL Server is using significantly less memory than recommended.';
    PRINT N'💡 Consider increasing max server memory to ' + CAST(@SuggestedMaxMemoryMB AS VARCHAR) + ' MB.';
END
ELSE
BEGIN
    PRINT N'✅ SQL Server memory configuration appears appropriate for this workload.';
END
PRINT 'Always leave at least 2GB for operating system. If SSRS or SSIS is installed leave additional memory for those external services'
PRINT 'SQL only          - leave 2GB for OS 6144MB 8GB-2G'
PRINT 'SQL + SSRS        - leave 2GB for OS 5120MB +1 GB for SSRS'
PRINT 'SQL + SSIS        - leave 2GB for OS 4096MB +2 GB for SSIS'
PRINT 'SQL + SSRS + SSIS - leave 2GB for OS 3072MB +3GB for SSRS/SSIS'
PRINT '--------------------------------------------------------------'
-------------------------------------------------------------------------
--GET SERVICE ACCOUNT INFO V6.0 10/03/21
PRINT 'SERVICE ACCOUNTS'

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
--GET PROXY ACCOUNTS v6.0 10/03/21

USE msdb;
GO
-- Create temp table
CREATE TABLE #proxytable
(
    [proxy_id] INT,
    [name] VARCHAR(100),
    [credential_identity] VARCHAR(40),
    [enabled] BINARY(1),
    [description] VARCHAR(200),
    [user_id] VARCHAR(50),
    [credential_id] INT,
    [credential_identity_exists] BINARY(1)
);

-- Insert proxy data
INSERT INTO #proxytable
EXEC dbo.sp_help_proxy;

-- Check if any rows exist
IF EXISTS (SELECT 1 FROM #proxytable)
BEGIN
    SELECT
        SUBSTRING(name, 1, 40) AS Proxy_Name,
        [credential_id],
        [enabled],
        SUBSTRING(description, 1, 50) AS Description,
        [credential_id]
    FROM #proxytable;
END
ELSE
BEGIN
    PRINT 'NO PROXY ACCOUNTS PRESENT';
              PRINT '-------------------------'
END

-- Clean up
DROP TABLE #proxytable;
-----------------------------------------
---GET DISABLED LOGINS
------------------------------------------------
-- CHECK DISABLED LOGINS and show details including last login (if trace data is available)
SET NOCOUNT ON
IF EXISTS (
    SELECT 1 
    FROM sys.server_principals 
    WHERE is_disabled = 1 AND type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP')
)
BEGIN
    PRINT N'⚠️ DISABLED LOGINS FOUND';

    -- Temp table to hold last login info
    IF OBJECT_ID('tempdb..#LastLogins') IS NOT NULL DROP TABLE #LastLogins;
    CREATE TABLE #LastLogins (
        LoginName NVARCHAR(256),
        LastLoginTime DATETIME
    );

    -- Try to extract last login info from default trace
    DECLARE @TraceFile NVARCHAR(500);
    SELECT TOP 1 @TraceFile = path FROM sys.traces WHERE is_default = 1;

    IF @TraceFile IS NOT NULL
    BEGIN
        INSERT INTO #LastLogins (LoginName, LastLoginTime)
        SELECT 
            -- Extract login name from TextData using CHARINDEX
            SUBSTRING(TextData, CHARINDEX('Login succeeded for user ''', TextData) + 25, 
                      CHARINDEX('''', TextData, CHARINDEX('Login succeeded for user ''', TextData) + 25) - 
                      CHARINDEX('Login succeeded for user ''', TextData) - 25) AS LoginName,
            MAX(StartTime) AS LastLoginTime
        FROM 
            fn_trace_gettable(@TraceFile, DEFAULT)
        WHERE 
            EventClass = 14 -- Audit Login
            AND TextData LIKE 'Login succeeded for user%'
        GROUP BY 
            SUBSTRING(TextData, CHARINDEX('Login succeeded for user ''', TextData) + 25, 
                      CHARINDEX('''', TextData, CHARINDEX('Login succeeded for user ''', TextData) + 25) - 
                      CHARINDEX('Login succeeded for user ''', TextData) - 25);
    END

    -- Final output
    SELECT 
        SUBSTRING(sp.name,1,40) AS Login,
        SUBSTRING(sp.type_desc,1,40) AS PrincipalType,
        sp.create_date AS CreatedOn,
        ll.LastLoginTime
    FROM 
        sys.server_principals sp
    LEFT JOIN 
        #LastLogins ll ON sp.name = ll.LoginName
    WHERE 
        sp.is_disabled = 1 
        AND sp.type_desc IN ('SQL_LOGIN', 'WINDOWS_LOGIN', 'WINDOWS_GROUP');
END
ELSE
BEGIN
    PRINT N'✅ No disabled logins found.';
END
----------------------------------------------------------------------
-----------------------------------------------------

---GET EXTENDED EVENT LIST
----------------------------------
SELECT SUBSTRING(name,1,60) AS ExtendedEventName, 
       event_session_id, 
       startup_state 
FROM sys.server_event_sessions;
----------------------------------
--GET LINKED SERVER INFO
PRINT 'LINKED SERVER CONNECTIONS'
PRINT '-------------------------'
SELECT 
 a.[server_id],
SUBSTRING (a.[name],1,50)AS 'LinkName',
SUBSTRING (c.[name],1,50)AS 'AccountName',
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

--GET MAIL CONFIGURATION
--List all Database Mail profiles
PRINT 'MAIL CONFIG'
PRINT '------------'
SELECT 
SUBSTRING (Name,1,20)AS Name,
SUBSTRING(description,1,50)AS Description,last_mod_datetime, 
SUBSTRING(last_mod_user,1,30)AS LastModUser
FROM msdb.dbo.sysmail_profile;

--List all Database Mail accounts
PRINT 'MAIL ACCOUNT'
PRINT'-------------'
SELECT 
SUBSTRING (Name,1,30)AS Name,
SUBSTRING(description,1,50)AS Description,
SUBSTRING(email_address,1,60)AS Email_Address,
SUBSTRING(display_name,1,50)AS Display_Name,
SUBSTRING(replyto_address,1,60)AS ReplyTo,last_mod_datetime, 
SUBSTRING(last_mod_user,1,30) AS LastModUser
FROM msdb.dbo.sysmail_account;

--Show all mail items in the queue
PRINT 'LAST 20 MAIL ITEMS LOGGED'
PRINT '-------------------------'
SELECT TOP 20
mailitem_id,profile_id,send_request_date,
CAST(SUBSTRING(recipients,1,55)AS VARCHAR (55)) AS Recipients,
SUBSTRING(subject,1,80)AS Subject,
CAST(SUBSTRING(body,1,140)AS VARCHAR (140)) AS Body,
sensitivity,
SUBSTRING(send_request_user,1,30)AS SendRequestUser,
sent_status
FROM msdb.dbo.sysmail_allitems
ORDER BY mailitem_id DESC
-----------------------------------------------------------------------
--GET DRIVE FREE DISK SPACE
----------------------------------------------------------------------------
PRINT 'DRIVES ALLOCATED FOR SQL INSTANCE'

SELECT DISTINCT
    CAST(SUBSTRING(ISNULL(volume_mount_point,''),1,80) AS NVARCHAR(80)) AS Mount_Point,
    CAST(total_bytes / 1024.0 / 1024 /1024 AS DECIMAL(18,2)) AS Total_GB,
    CAST(available_bytes / 1024.0 / 1024 /1024 AS DECIMAL(18,2)) AS Available_GB,
    CAST(
        ISNULL(
            ROUND(available_bytes * 100.0 / NULLIF(total_bytes, 0), 2),
            0
        ) AS DECIMAL(5,2)
    ) AS Percent_Available
FROM
    sys.master_files AS f
CROSS APPLY
    sys.dm_os_volume_stats(f.database_id, f.file_id)
ORDER BY
    mount_point;

-----------------------------------------------------------------------------
--GET CONFIGURATION SETTINGS
PRINT 'CONFIGURATION SETTINGS' 
SELECT 
 GETDATE() AS executiontime,
[name]AS property, SUBSTRING(CONVERT(NVARCHAR(30),value_in_use),1,18)AS config_value
FROM sys.configurations
--WHERE configuration_id IN (109,117,505,518,1126,1519,1520,1538,1539,1540,1541,1543,1544,1545,1562,1576,1579,1580,16390,16391,16393)
;
GO

-- CHECK INSTANT FILE INITIALIZATION
CREATE TABLE #TempErrorLogs
(
    [LogDate] DATETIME,
    [ProcessInfo] VARCHAR(50),
    [Description] VARCHAR(MAX)
);
GO

-- Insert error log entries
INSERT INTO #TempErrorLogs ([LogDate], [ProcessInfo], [Description])
EXEC [master].[dbo].[xp_readerrorlog] 0;
GO

-- Check if IFI message exists
IF EXISTS (
    SELECT 1
    FROM #TempErrorLogs
    WHERE [Description] LIKE 'Database Instant File Initialization: Enabled%'
)
BEGIN
    SELECT SUBSTRING([Description], 1, 47) AS [IFI Status]
    FROM #TempErrorLogs
    WHERE [Description] LIKE 'Database Instant File Initialization: Enabled%';
END
ELSE
BEGIN
    PRINT N'⚠️ INSTANT FILE INITIALISATION NOT SETUP';
END

-- Clean up
DROP TABLE #TempErrorLogs;

----------------------------------------------------------------------
---MAXDOP OPTIMAL SETTINGS
--------------------------------------------------

                             SET NOCOUNT ON;
                             USE MASTER;

                             -- Dropping tem table in case it exists
                             IF EXISTS (SELECT  * FROM tempdb.dbo.sysobjects o WHERE o.XTYPE IN ('U') and o.id = object_id(N'tempdb..#MaxDOPDB') ) DROP TABLE #MaxDOPDB;

                             DECLARE
                                           @SQLVersion                                  INT
                                           ,@NumaNodes                INT
                                           ,@NumCPUs                                   INT
                                           ,@MaxDop                                     SQL_VARIANT
                                           ,@RecommendedMaxDop          INT

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
                                                          (DBName           sysname, configuration_id int, name nvarchar (120), value_for_primary sql_variant, value_for_secondary sql_variant)

                                                          INSERT INTO #MaxDOPDB
                                                          EXEC sp_msforeachdb 'USE [?]; SELECT DB_NAME(), configuration_id, name, value, value_for_secondary FROM sys.database_scoped_configurations WHERE name =''MAXDOP'''
                             
                                                          -- Displaying database MAXDOP configuration
                                                          PRINT '------------------------------------------------------------------------';
                                                          PRINT 'MAXDOP at Database level:';
                                              SELECT CONVERT(VARCHAR(30),dbname) as DatabaseName, CONVERT(VARCHAR(10),name) as ConfigurationName, CONVERT(INT,value_for_primary) as "MAXDOP Configured Value" FROM #MaxDOPDB
                                                          WHERE dbname NOT IN ('master','msdb','tempdb','model');
                                                          PRINT '';

                                                          -- Displaying current and recommeded MAXDOP
                                                          PRINT '--------------------------------------------------------------';
                                                          PRINT 'MAXDOP at Instance level:';
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
                                                                                      PRINT N' 💡 In case you want to change MAXDOP to the recommeded value, please use this script:';
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
  FROM sys.databases
  GO
  ------------------------------------------------------------------------
  --BUSIEST DATABASES%
  PRINT 'BUSIEST DATABASES'
  PRINT '-----------------'
  GO
WITH db_stats AS (
    SELECT 
        DB_NAME(CAST(pa.value AS INT)) AS database_name,
        SUM(qs.execution_count) AS total_executions,
        SUM(qs.total_elapsed_time) AS total_elapsed_time,
        SUM(qs.total_worker_time) AS total_worker_time,
        SUM(qs.total_logical_reads) AS total_logical_reads,
        SUM(qs.total_logical_writes) AS total_logical_writes
    FROM 
        sys.dm_exec_query_stats AS qs
    CROSS APPLY 
        sys.dm_exec_plan_attributes(qs.plan_handle) AS pa
    WHERE 
        pa.attribute = 'dbid'
        AND DB_NAME(CAST(pa.value AS INT)) NOT IN ('master', 'msdb', 'model', 'tempdb')
    GROUP BY 
        pa.value
)
SELECT 
    SUBSTRING(database_name,1,60) AS DatabaseName,
              CAST(100.0 * total_elapsed_time / SUM(total_elapsed_time) OVER () AS DECIMAL(5,2)) AS PercentBusy,
    total_executions,
    total_elapsed_time,
    total_worker_time,
    total_logical_reads,
    total_logical_writes

FROM 
    db_stats
ORDER BY 
    PercentBusy DESC;

---------------------------------------------------------------------------
-- Get current SQL Server version
PRINT 'DB COMPATIBILITY'
PRINT '----------------'
DECLARE @RecommendedLevel INT;
-- Determine recommended compatibility level based on version
IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '16.%' -- SQL Server 2022
    SET @RecommendedLevel = 160;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '15.%' -- SQL Server 2019
    SET @RecommendedLevel = 150;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '14.%' -- SQL Server 2017
    SET @RecommendedLevel = 140;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '13.%' -- SQL Server 2016
    SET @RecommendedLevel = 130;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '12.%' -- SQL Server 2014
    SET @RecommendedLevel = 120;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '11.%' -- SQL Server 2012
    SET @RecommendedLevel = 110;
ELSE IF (SELECT CAST(SERVERPROPERTY('ProductVersion') AS VARCHAR)) LIKE '10.%' -- SQL Server 2008
    SET @RecommendedLevel = 100;
ELSE
    SET @RecommendedLevel = 0; -- Unknown or unsupported version

-- Check if any databases are below recommended level
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE state_desc = 'ONLINE'
      AND compatibility_level < @RecommendedLevel
)
BEGIN
    SELECT 
        SUBSTRING(name, 1, 70) AS [Database Name],
        compatibility_level,
        @RecommendedLevel AS [Recommended Level],
        'Yes' AS [Requires Attention]
    FROM sys.databases
    WHERE state_desc = 'ONLINE'
      AND compatibility_level < @RecommendedLevel
    ORDER BY compatibility_level;
END
ELSE
BEGIN
    PRINT N'✅ All DATABASES ARE AT RECOMMENDED COMPATIBILITY LEVEL';
END
----------------------------------------------------------------------------------

--GET OFFLINE DATABASES

IF EXISTS ( SELECT 1 FROM sys.databases WHERE state_desc = 'OFFLINE'

)
BEGIN
  PRINT 'OFFLINE DATABASE LIST'
  PRINT '---------------------'
SELECT
SUBSTRING(db.name,1,50) AS Offline_databases,
SUBSTRING(mf.name,1, 60) AS dbFilename,
SUBSTRING(mf.type_desc,1,50)AS type_description,
SUBSTRING(mf.physical_name,1,50) AS filelocation
FROM
sys.databases db
INNER JOIN sys.master_files mf
ON db.database_id = mf.database_id
WHERE
db.state = 6 -- OFFLINE
END
  ELSE 
  BEGIN PRINT N' ✅ NO OFFLINE DATABASES PRESENT';
        PRINT '----------------------------'
  END
----------------------------------------------------------------------------
--CHECK FOR HALLENGREN DEPLOYED SCRIPTS -VERSION
-- Multi-Database Ola Hallengren Feature Detection and Version Estimator

PRINT N'⏳ Scanning all user databases for Ola Hallengren procedures...';
SET NOCOUNT ON
-- Temp tables
IF OBJECT_ID('tempdb..##FeatureCheck') IS NOT NULL DROP TABLE ##FeatureCheck;
CREATE TABLE ##FeatureCheck (
    DatabaseName NVARCHAR(128),
    Feature NVARCHAR(200),
    Year INT,
    Found BIT
);

DECLARE @DatabaseName3 NVARCHAR(128);
DECLARE @HasAnyOla BIT = 0;

-- Cursor to loop through user databases (excluding system and secondaries)
DECLARE db_cursor CURSOR FOR
SELECT d.name
FROM sys.databases d
LEFT JOIN sys.dm_hadr_availability_replica_states rs
    ON d.replica_id = rs.replica_id
WHERE d.state_desc = 'ONLINE'
  AND d.name NOT IN ('master', 'model', 'msdb', 'tempdb')
  AND (d.replica_id IS NULL OR rs.role_desc = 'PRIMARY');

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DatabaseName3;

WHILE @@FETCH_STATUS = 0
BEGIN
    DECLARE @CheckSQL NVARCHAR(MAX);
    DECLARE @HasOla BIT = 0;

    -- Check for Ola procedures in this database
    SET @CheckSQL = '
    USE ' + QUOTENAME(@DatabaseName3) + ';
    IF EXISTS (
        SELECT 1 FROM sys.objects 
        WHERE name IN (''DatabaseBackup'', ''IndexOptimize'', ''CommandExecute'')
        AND type = ''P''
    )
    BEGIN
        SELECT @HasOlaOut = 1;
    END
    ELSE
    BEGIN
        SELECT @HasOlaOut = 0;
    END
    ';

    EXEC sp_executesql @CheckSQL, N'@HasOlaOut BIT OUTPUT', @HasOlaOut = @HasOla OUTPUT;

    IF @HasOla = 1
    BEGIN
        SET @HasAnyOla = 1;

        DECLARE @Feature NVARCHAR(200), @Year INT, @Pattern NVARCHAR(MAX);
        DECLARE @SQL3 NVARCHAR(MAX), @Found BIT;

        DECLARE FeatureCursor CURSOR FOR
        SELECT * FROM (
            VALUES
            ('@CleanupTime', 2019, '%@CleanupTime%'),
            ('@DirectoryStructure', 2020, '%@DirectoryStructure%'),
            ('@LogToTable with CommandType', 2021, '%@LogToTable%CommandType%'),
            ('@Credential for Azure/S3', 2022, '%@Credential%TO URL%'),
            ('@CompressionLevelNumeric', 2022, '%@CompressionLevelNumeric%'),
            ('COPY_ONLY with AG awareness', 2022, '%COPY_ONLY%AvailabilityGroup%'),
            ('@AvailabilityGroupReplicas = ALL', 2023, '%@AvailabilityGroupReplicas%ALL%'),
            ('@URL and @MirrorURL for S3', 2023, '%@URL%@MirrorURL%'),
            ('@Resumable = Y', 2024, '%@Resumable%RESUMABLE = ON%'),
            ('Filtered index support with @Resumable', 2024, '%filtered%@Resumable%'),
            ('Always On awareness in CommandExecute', 2024, '%dm_hadr_availability_replica_states%'),
            ('@CompressionLevel and ZSTD', 2025, '%@CompressionLevel%ZSTD%'),
            ('sys.dm_os_file_exists usage', 2025, '%sys.dm_os_file_exists%'),
            ('EXPIREDATE and RETAINDAYS', 2025, '%EXPIREDATE%RETAINDAYS%')
        ) AS Features(Feature, Year, Pattern);

        OPEN FeatureCursor;
        FETCH NEXT FROM FeatureCursor INTO @Feature, @Year, @Pattern;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            SET @SQL3 = '
            USE ' + QUOTENAME(@DatabaseName3) + ';
            SELECT @FoundOut = CASE WHEN EXISTS (
                SELECT 1 FROM sys.sql_modules 
                WHERE definition LIKE @Pattern
            ) THEN 1 ELSE 0 END';

            EXEC sp_executesql @SQL3, 
                N'@Pattern NVARCHAR(MAX), @FoundOut BIT OUTPUT', 
                @Pattern = @Pattern, @FoundOut = @Found OUTPUT;

            INSERT INTO ##FeatureCheck (DatabaseName, Feature, Year, Found)
            VALUES (@DatabaseName3, @Feature, @Year, @Found);

            FETCH NEXT FROM FeatureCursor INTO @Feature, @Year, @Pattern;
        END

        CLOSE FeatureCursor;
        DEALLOCATE FeatureCursor;
    END

    FETCH NEXT FROM db_cursor INTO @DatabaseName3;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Output results
IF EXISTS (SELECT 1 FROM ##FeatureCheck)
BEGIN
    PRINT 'Feature Detection Results:';
    SELECT 
        SUBSTRING(DatabaseName,1,50)AS DatabaseName,
        Year,
        SUBSTRING(Feature,1,30)AS Feature,
        CASE WHEN Found = 1 THEN 'Present' ELSE 'Not Found' END AS Status
    FROM ##FeatureCheck
    ORDER BY DatabaseName, Year, Feature;

    PRINT 'Estimated Ola Hallengren version per database:';
    SELECT 
        SUBSTRING(DatabaseName,1,50)AS DatabaseName,
        MAX(Year) AS EstimatedVersionYear
    FROM ##FeatureCheck
    WHERE Found = 1
    GROUP BY DatabaseName
    ORDER BY DatabaseName;
END
ELSE
BEGIN
    PRINT 'NO OLA HALLENGREN SCRIPTS PRESENT IN ANY DATABASE.';
END
--------------------------------------------------------------------------
--GET REPLICATION ROLE
------------------------------------------
BEGIN TRY
    DECLARE @isPublisher BIT = 0;
    DECLARE @isDistributor BIT = 0;
    DECLARE @isSubscriber BIT = 0;

    DECLARE @pubStatus NVARCHAR(10) = 'No';
    DECLARE @distStatus NVARCHAR(10) = 'No';
    DECLARE @subStatus NVARCHAR(10) = 'No';

    -- Check Publisher
    IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'syspublications')
    BEGIN
        IF EXISTS (SELECT 1 FROM syspublications)
            SET @isPublisher = 1;
    END

    -- Check Distributor
    IF EXISTS (SELECT 1 FROM msdb.sys.objects WHERE name = 'MSdistributiondbs')
    BEGIN
        IF EXISTS (SELECT 1 FROM msdb.dbo.MSdistributiondbs)
            SET @isDistributor = 1;
    END

    -- Check Subscriber
    IF EXISTS (SELECT 1 FROM sysobjects WHERE name = 'syssubscriptions')
    BEGIN
        IF EXISTS (SELECT 1 FROM syssubscriptions)
            SET @isSubscriber = 1;
    END

    -- Set status text
    SET @pubStatus = CASE WHEN @isPublisher = 1 THEN 'Yes' ELSE 'No' END;
    SET @distStatus = CASE WHEN @isDistributor = 1 THEN 'Yes' ELSE 'No' END;
    SET @subStatus = CASE WHEN @isSubscriber = 1 THEN 'Yes' ELSE 'No' END;

    PRINT N'📊 Replication Role Summary:';
    PRINT  '----------------------------';
    PRINT 'Publisher: ' + @pubStatus;
    PRINT 'Distributor: ' + @distStatus;
    PRINT 'Subscriber: ' + @subStatus;
END TRY
BEGIN CATCH
    PRINT 'Error checking replication roles: ' + ERROR_MESSAGE();
END CATCH;
-------------------------------------------------------------------
-----------------------------------------------------------         
--GET CLUSTER INFO
IF SERVERPROPERTY('IsClustered') = 1
BEGIN
    PRINT 'CLUSTERED INSTANCE';
    SELECT 
      SUBSTRING(NodeName, 1, 60) AS NodeName,
      status,
      status_description,
      is_current_owner
    FROM sys.dm_os_cluster_nodes;
END
ELSE
BEGIN
    PRINT 'NOT A CLUSTERED INSTANCE';
END
---------------------------------------------------
--GET AVAILABILITY GROUP INFO

IF EXISTS (
    SELECT 1 FROM master.sys.availability_groups
)
BEGIN
    PRINT 'ALWAYS ON AVAILABILITY GROUP PRESENT';

    SELECT
        SUBSTRING(AG.name,1,30) AS [AvailabilityGroupName],
        ISNULL(arstates.role, 3) AS [LocalReplicaRole],
        SUBSTRING(dbcs.database_name,1,50) AS [DatabaseName],
        ISNULL(dbrs.synchronization_state, 0) AS [SynchronizationState],
        ISNULL(dbrs.is_suspended, 0) AS [IsSuspended],
        ISNULL(dbcs.is_database_joined, 0) AS [IsJoined]
    FROM master.sys.availability_groups AS AG
    LEFT OUTER JOIN master.sys.dm_hadr_availability_group_states AS agstates
        ON AG.group_id = agstates.group_id
    INNER JOIN master.sys.availability_replicas AS AR
        ON AG.group_id = AR.group_id
    INNER JOIN master.sys.dm_hadr_availability_replica_states AS arstates
        ON AR.replica_id = arstates.replica_id AND arstates.is_local = 1
    INNER JOIN master.sys.dm_hadr_database_replica_cluster_states AS dbcs
        ON arstates.replica_id = dbcs.replica_id
    LEFT OUTER JOIN master.sys.dm_hadr_database_replica_states AS dbrs
        ON dbcs.replica_id = dbrs.replica_id AND dbcs.group_database_id = dbrs.group_database_id
    ORDER BY AG.name ASC, dbcs.database_name;
END
ELSE
BEGIN
    PRINT 'NO ALWAYS ON AVAILABILITY GROUP PRESENT';
END
----------------------------------------------------
---GET MIRRORED DATABASES
-- Check for mirrored databases
IF EXISTS (
    SELECT 1
    FROM sys.database_mirroring
    WHERE mirroring_state IS NOT NULL
)
BEGIN
    PRINT 'MIRRORED DATABASES';
    PRINT '-------------------';

    SELECT 
        SUBSTRING(d.name, 1, 60) AS Database_Name,
        CASE
            WHEN dm.mirroring_state IS NULL THEN 'Not Mirrored'
            ELSE 'Mirrored'
        END AS Mirroring_Status
    FROM sys.databases d
    JOIN sys.database_mirroring dm ON d.database_id = dm.database_id
    WHERE dm.mirroring_state IS NOT NULL
    ORDER BY d.name;
END
ELSE
BEGIN
    PRINT 'NO MIRRORED DATABASES PRESENT';
END
--------------------------------------------------
--GET LOGSHIPPED DATABASES
IF EXISTS (
    SELECT 1 
    FROM msdb.dbo.log_shipping_primary_databases
    UNION
    SELECT 1 
    FROM msdb.dbo.log_shipping_secondary_databases
)
BEGIN
    PRINT 'LOG SHIPPING IS CONFIGURED';

    -- Primary databases
    SELECT 
        'Primary' AS Role,
        primary_database,
        backup_directory,
        backup_retention_period,
        monitor_server
    FROM msdb.dbo.log_shipping_primary_databases

    UNION ALL

    -- Secondary databases
    SELECT 
        'Secondary' AS Role,
        secondary_database,
        NULL AS backup_directory,
        NULL AS backup_retention_period,
        NULL AS monitor_server
    FROM msdb.dbo.log_shipping_secondary_databases;
END
ELSE
BEGIN
    PRINT 'NO LOG SHIPPING CONFIGURED';
END

--------------------------------------------------
-- CHECK RESOURCE GOVERNOR ENABLED 
SELECT 
    CASE 
        WHEN (SELECT is_enabled FROM sys.resource_governor_configuration) = 1 THEN 'Enabled'
        ELSE 'Disabled'
    END AS ResourceGovernorStatus,
    (SELECT COUNT(*) 
     FROM sys.resource_governor_resource_pools 
     WHERE name NOT IN ('internal', 'default')) AS UserDefinedPools,
    (SELECT COUNT(*) 
     FROM sys.resource_governor_workload_groups 
     WHERE name NOT IN ('internal', 'default')) AS UserDefinedGroups;
-------------------------------------------------------------------
-- CHECK POLYBASE INSTALLED
BEGIN
    IF SERVERPROPERTY('IsPolyBaseInstalled') = 1
    BEGIN
        PRINT 'PolyBase is installed.';
        PRINT 'PolyBase service details:';

        -- Show PolyBase-related services and their status
        SELECT 
            servicename, 
            startup_type_desc, 
            status_desc, 
            process_id, 
            last_startup_time
        FROM 
            sys.dm_server_services
        WHERE 
            servicename LIKE '%PolyBase%';
    END
    ELSE
    BEGIN
        PRINT N'POLYBASE IS NOT INSTALLED.';
    END
END
-----------------------------------------------------

---CHECK TEMPDB FILES ARE CORRECT
USE tempdb;
GO

DECLARE @ErrorMessage NVARCHAR(4000) = '';
DECLARE @HasError BIT = 0;

WITH TempdbFiles AS (
    SELECT 
        name,
        type_desc,
        size * 8 / 1024 AS InitialSizeMB,
        growth,
        CAST(is_percent_growth AS INT) AS is_percent_growth_int
    FROM sys.master_files
    WHERE database_id = DB_ID('tempdb') AND type_desc = 'ROWS'
)
SELECT 
    @HasError = CASE 
        WHEN COUNT(DISTINCT InitialSizeMB) > 1 THEN 1
        WHEN COUNT(DISTINCT growth) > 1 THEN 1
        WHEN MAX(is_percent_growth_int) = 1 THEN 1
        ELSE 0
    END,
    @ErrorMessage = 
        CASE 
            WHEN COUNT(DISTINCT InitialSizeMB) > 1 THEN 'Mismatch in initial sizes of tempdb data files. '
            ELSE ''
        END +
        CASE 
            WHEN COUNT(DISTINCT growth) > 1 THEN 'Mismatch in autogrowth settings of tempdb data files. '
            ELSE ''
        END +
        CASE 
            WHEN MAX(is_percent_growth_int) = 1 THEN 'One or more tempdb files use percent-based growth, which is not recommended. '
            ELSE ''
        END
FROM TempdbFiles;

IF @HasError = 1
BEGIN
    RAISERROR(@ErrorMessage, 16, 1);
END
ELSE
BEGIN
    PRINT N'✅ All TEMPDB DATAFILES ARE CONFIGURED CORRECTLY';
END

----CHECK CONFIGURED PBM POLICIES
USE msdb;
GO

IF EXISTS (
    SELECT 1 
    FROM msdb.dbo.syspolicy_policies
    WHERE is_enabled = 1
)
BEGIN
    PRINT N'✅ POLICY-BASED MANAGEMENT IS IN USE';

    SELECT
        SUBSTRING([name], 1, 40) AS PBM_policy,
        description
    FROM msdb.dbo.syspolicy_policies
    WHERE is_enabled = 1;
END
ELSE
BEGIN
    PRINT 'NO POLICY-BASED MANAGEMENT CONFIGURED';
END
GO

--------------------------------------------------
--GET ENCRYPTION KEY DATES
SET NOCOUNT ON
DECLARE @DBName NVARCHAR(128);
DECLARE @SQL NVARCHAR(MAX);

-- Step 1: Create temp table with AG role info
IF OBJECT_ID('tempdb..#db_roles') IS NOT NULL DROP TABLE #db_roles;

SELECT 
    d.name AS DatabaseName,
    CASE 
        WHEN drs.is_primary_replica = 1 THEN 1
        WHEN drs.is_primary_replica = 0 THEN 0
        ELSE -1 -- Not in AG
    END AS is_primary_replica
INTO #db_roles
FROM sys.databases d
LEFT JOIN sys.dm_hadr_database_replica_states drs 
    ON d.database_id = drs.database_id
WHERE d.state_desc = 'ONLINE'
  AND d.name NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB'); -- exclude system DBs

-- Step 2: Cursor to loop through only primary or non-AG databases
DECLARE db_cursor CURSOR FOR
SELECT DatabaseName
FROM #db_roles
WHERE is_primary_replica IN (1, -1); -- primary or not in AG
PRINT 'CHECKING FOR ENCRYPTION KEYS'
OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'⏳ Checking database: ' + QUOTENAME(@DBName);

    SET @SQL = '
    USE ' + QUOTENAME(@DBName) + ';
    DECLARE @HasKeys BIT = 0;

    IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = ''##MS_DatabaseMasterKey##'')
        SET @HasKeys = 1;

    IF EXISTS (SELECT 1 FROM sys.asymmetric_keys)
        SET @HasKeys = 1;

    IF EXISTS (SELECT 1 FROM sys.certificates WHERE name NOT LIKE ''##MS_%'')
        SET @HasKeys = 1;

    IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name NOT LIKE ''##MS_%'')
        SET @HasKeys = 1;

    IF @HasKeys = 1
    BEGIN
        PRINT ''--- Encryption Keys Found in ' + @DBName + ' ---'';

        IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = ''##MS_DatabaseMasterKey##'')
            PRINT ''Database Master Key is present.'';

        IF EXISTS (SELECT 1 FROM sys.asymmetric_keys)
        BEGIN
            PRINT ''Asymmetric Keys:'';
            SELECT name, algorithm_desc, key_length FROM sys.asymmetric_keys;
        END

        IF EXISTS (SELECT 1 FROM sys.certificates WHERE name NOT LIKE ''##MS_%'')
        BEGIN
            PRINT ''Certificates:'';
            SELECT name, subject, expiry_date FROM sys.certificates WHERE name NOT LIKE ''##MS_%'';
        END

        IF EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name NOT LIKE ''##MS_%'')
        BEGIN
            PRINT ''Symmetric Keys:'';
            SELECT name, key_guid, algorithm_desc FROM sys.symmetric_keys WHERE name NOT LIKE ''##MS_%'';
        END
    END
    ELSE
    BEGIN
        PRINT ''NO ENCRYPTION KEYS PRESENT in ' + @DBName + ''';
    END
    ';

    BEGIN TRY
        EXEC sp_executesql @SQL;
    END TRY
    BEGIN CATCH
        PRINT 'Error accessing database [' + @DBName + ']: ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;

-- Cleanup
DROP TABLE #db_roles;

---GET FILE INFO
PRINT 'FILE INFORMATION' 
PRINT '----------------'
SELECT
    SUBSTRING(D.name, 1, 50) AS databasename,
    F.file_id, 
    F.size AS KB,
    CAST(F.size AS BIGINT) * 8 / 1024 AS MB,
    SUBSTRING(F.physical_name, 1, 100) AS physicalfile,
    SUBSTRING(F.state_desc, 1, 10) AS OnlineStatus
FROM 
    sys.master_files F
    INNER JOIN sys.databases D ON D.database_id = F.database_id
WHERE 
    D.name NOT IN ('model', 'msdb', 'master', 'tempdb')
ORDER BY
    D.name;

------GET DEFAULT BACKUP LOCATION

              DECLARE @backupdir nvarchar(4000);
EXEC master.dbo.xp_instance_regread 
 N'HKEY_LOCAL_MACHINE'
, N'Software\Microsoft\MSSQLServer\MSSQLServer'
, N'BackupDirectory'
, @backupdir output;

PRINT 'DEFAULT BACKUP LOCATION'
SELECT SUBSTRING(@backupdir,1,100)

---GET TEMPDB INFO
PRINT 'TEMPDB PROPERTIES'
PRINT '-------------------'
SELECT 
 SUBSTRING (name, 1,30)AS FileName
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
-----------------------------------------------------
-----CHECKS TEMPDB SPEED
PRINT 'TEMP DB SPEEDS'
PRINT '--------------'
SELECT 
  SUBSTRING(files.physical_name,1,60)AS FileName, 
  stats.num_of_writes, (1.0 * stats.io_stall_write_ms / stats.num_of_writes) AS avg_write_stall_ms,
  stats.num_of_reads, (1.0 * stats.io_stall_read_ms / stats.num_of_reads) AS avg_read_stall_ms
FROM sys.dm_io_virtual_file_stats(2, NULL) as stats
INNER JOIN master.sys.master_files AS files 
  ON stats.database_id = files.database_id
  AND stats.file_id = files.file_id
WHERE files.type_desc = 'ROWS'

----------------------------------------------------
----GET LIST ALL JOBS
PRINT'SQL AGENT JOB LIST'
PRINT'------------------'
SELECT 
SUBSTRING([name],1,50)AS jobname,
SUBSTRING([description],1,80) AS 'job description', 
[enabled], [date_created], [date_modified] 
FROM    msdb..sysjobs ORDER BY [name]
----------------------------------------------------
---GET MAINTENANCE PLAN
----------------------------------------------------
USE MSDB;
GO

IF EXISTS (
    SELECT 1
    FROM dbo.sysmaintplan_plans
)
BEGIN
    PRINT 'MAINTENANCE PLAN FOUND'
              PRINT '----------------------'

    SELECT 
       SUBSTRING(p.name,1,50) AS MaintenancePlanName,
        p.create_date AS PlanCreatedDate,
       SUBSTRING(sp.subplan_name,1,40) AS SubPlanName,
       SUBSTRING(j.name,1,40) AS JobName,
       SUBSTRING(js.step_name,1,40) AS JobStepName,
       CAST(SUBSTRING(js.command,1,130)AS VARCHAR (130)) AS JobStepCommand,
       SUBSTRING(s.name,1,40)  AS ScheduleName,
        s.enabled AS ScheduleEnabled,
        s.freq_type,
        s.freq_interval,
        s.active_start_date,
        s.active_start_time
    FROM dbo.sysmaintplan_plans p
    LEFT JOIN dbo.sysmaintplan_subplans sp ON p.id = sp.plan_id
    LEFT JOIN msdb.dbo.sysjobs j ON sp.job_id = j.job_id
    LEFT JOIN msdb.dbo.sysjobsteps js ON j.job_id = js.job_id
    LEFT JOIN msdb.dbo.sysjobschedules jsched ON j.job_id = jsched.job_id
    LEFT JOIN msdb.dbo.sysschedules s ON jsched.schedule_id = s.schedule_id
    ORDER BY p.name, sp.subplan_name, j.name, js.step_id;
END
ELSE
BEGIN
    PRINT 'NO MAINTENANCE PLAN FOUND';
END

--GET LIST ALL SSIS PACKAGES
--GET LIST ALL SSIS PACKAGES

PRINT '----------------------'

-- List all SSIS packages stored in msdb database. 
-- Check for SSIS packages excluding 'Data Collector'
IF EXISTS (
    SELECT 1
    FROM msdb.dbo.sysssispackages AS P
    INNER JOIN msdb.dbo.sysssispackagefolders AS F ON P.folderid = F.folderid
    WHERE F.foldername NOT LIKE 'Data Collector%'
)
BEGIN
    PRINT 'SSIS PACKAGES';
    PRINT '--------------';

    SELECT
        SUBSTRING(PCK.name, 1, 50) AS packagename,
        SUBSTRING(PCK.[description], 1, 80) AS [description],
        SUBSTRING(FLD.foldername, 1, 50) AS foldername,
        CASE PCK.packagetype 
            WHEN 0 THEN 'Default client' 
            WHEN 1 THEN 'I/O Wizard' 
            WHEN 2 THEN 'DTS Designer' 
            WHEN 3 THEN 'Replication' 
            WHEN 5 THEN 'SSIS Designer' 
            WHEN 6 THEN 'Maintenance Plan' 
            ELSE 'Unknown' 
        END AS packagetype,
        SUBSTRING(LG.name, 1, 20) AS ownername,
        PCK.isencrypted AS IsEncrypted, 
        PCK.createdate AS CreateDate,
        CONVERT(VARCHAR(10), vermajor) + '.' + 
        CONVERT(VARCHAR(10), verminor) + '.' + 
        CONVERT(VARCHAR(10), verbuild) AS version,
        SUBSTRING(PCK.vercomments, 1, 100) AS versioncomment,
        DATALENGTH(PCK.packagedata) AS packagesize
    FROM msdb.dbo.sysssispackages AS PCK
    INNER JOIN msdb.dbo.sysssispackagefolders AS FLD ON PCK.folderid = FLD.folderid
    INNER JOIN sys.syslogins AS LG ON PCK.ownersid = LG.sid
    WHERE FLD.foldername NOT LIKE 'Data Collector%'
    ORDER BY PCK.name;
END
ELSE
BEGIN
    PRINT 'NO SSIS PACKAGES PRESENT';
END
------------------------------------------------------------
--- 'SSIS PACKAGES IN SSISDB '
PRINT '-----------------------'
USE msdb;
GO

IF EXISTS (
    SELECT 1 
    FROM dbo.sysssispackages AS P
    INNER JOIN dbo.sysssispackagefolders AS F
        ON P.folderid = F.folderid
    WHERE F.foldername NOT LIKE 'Data Collector%'
)
BEGIN
    PRINT 'SSIS PACKAGES FOUND IN MSDB';

    SELECT
        SUBSTRING(PCK.name, 1, 50) AS packagename,
        SUBSTRING(PCK.[description], 1, 80) AS [description],
        SUBSTRING(FLD.foldername, 1, 50) AS foldername,
        CASE PCK.packagetype 
            WHEN 0 THEN 'Default client' 
            WHEN 1 THEN 'I/O Wizard' 
            WHEN 2 THEN 'DTS Designer' 
            WHEN 3 THEN 'Replication' 
            WHEN 5 THEN 'SSIS Designer' 
            WHEN 6 THEN 'Maintenance Plan' 
            ELSE 'Unknown' 
        END AS packagetype,
        SUBSTRING(LG.name, 1, 20) AS ownername,
        PCK.isencrypted AS IsEncrypted, 
        PCK.createdate AS CreateDate,
        CONVERT(VARCHAR(10), vermajor) + '.' + 
        CONVERT(VARCHAR(10), verminor) + '.' + 
        CONVERT(VARCHAR(10), verbuild) AS version,
        SUBSTRING(PCK.vercomments, 1, 100) AS versioncomment,
        DATALENGTH(PCK.packagedata) AS packagesize
    FROM dbo.sysssispackages AS PCK
    INNER JOIN dbo.sysssispackagefolders AS FLD 
        ON PCK.folderid = FLD.folderid
    INNER JOIN sys.syslogins AS LG 
        ON PCK.ownersid = LG.sid
    WHERE FLD.foldername NOT LIKE 'Data Collector%'
    ORDER BY PCK.name;
END
ELSE
BEGIN
    PRINT 'NO SSIS PACKAGES IN MSDB';
END
GO
-----------------------------------------------
--GET SSIS SCALE OUT
---------------------------------------------------
-- Check if SSISDB exists
IF EXISTS (
    SELECT 1
    FROM master.dbo.sysdatabases
    WHERE name = 'SSISDB'
)
BEGIN
    PRINT N'⚠️ SSISDB FOUND';

    DECLARE @IsPrimaryReplica BIT = 0;

    -- Check if current replica is primary for SSISDB
    IF EXISTS (
        SELECT 1
        FROM sys.dm_hadr_database_replica_states AS drs
        JOIN sys.databases AS db ON drs.database_id = db.database_id
        WHERE db.name = 'SSISDB' AND drs.is_primary_replica = 1
    )
    SET @IsPrimaryReplica = 1;

    IF @IsPrimaryReplica = 1
    BEGIN
        PRINT 'SSISDB is on the primary replica';

        BEGIN TRY
            DECLARE @enabled BIT;

            SELECT @enabled = property_value
            FROM SSISDB.catalog.catalog_properties
            WHERE property_name = 'ScaleOutMasterEnabled';

            IF @enabled = 1
                PRINT 'SSIS SCALE OUT DEPLOYED';
            ELSE
                PRINT 'NO SSIS SCALE OUT DEPLOYED';
        END TRY
        BEGIN CATCH
            PRINT '⚠️ Error accessing SSISDB catalog properties';
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT 'SSISDB is on a secondary replica — skipping query to avoid error';
    END
END
ELSE
BEGIN
    PRINT 'SSISDB not found';
END

PRINT '---------------------------';

-- Check for user tables in MASTER
USE master;
GO

IF EXISTS (
    SELECT 1 
    FROM sys.objects 
    WHERE type = 'U' AND is_ms_shipped = 0
)
BEGIN
    PRINT N'⚠️ USER TABLES FOUND IN MASTER';
    SELECT 
        SUBSTRING(name, 1, 50) AS Tables_in_MASTER, 
        SUBSTRING(type_desc, 1, 20) AS type_desc, 
        create_date, 
        is_ms_shipped 
    FROM sys.objects 
    WHERE type = 'U' AND is_ms_shipped = 0;
END
ELSE
BEGIN
    PRINT N'✅ NO USER TABLES FOUND IN MASTER';
END
GO
              PRINT '-------------------------------'
-- Check for user tables in MSDB
USE msdb;
GO

IF EXISTS (
    SELECT 1 
    FROM sys.objects 
    WHERE type = 'U' AND is_ms_shipped = 0
)
BEGIN
    PRINT N'⚠️ USER TABLES FOUND IN MSDB';
    SELECT 
        SUBSTRING(name, 1, 50) AS Tables_in_MSDB, 
        SUBSTRING(type_desc, 1, 20) AS type_desc, 
        create_date, 
        is_ms_shipped 
    FROM sys.objects 
    WHERE type = 'U' AND is_ms_shipped = 0;
END
ELSE
BEGIN
    PRINT N'✅ NO USER TABLES FOUND IN MSDB';
END
GO
   PRINT '----------------------------------'

 --------------------------------------------
 --Databases that are accessing system tables
--------------------------------------------
SET NOCOUNT ON;

-- Create a permanent results table in tempdb
USE tempdb;
IF OBJECT_ID('dbo.SystemTableScanResults') IS NOT NULL DROP TABLE dbo.SystemTableScanResults;
CREATE TABLE dbo.SystemTableScanResults (
    DatabaseName SYSNAME,
    SystemTable SYSNAME,
    RecommendedView SYSNAME,
    ReferencingObject SYSNAME,
    ObjectType NVARCHAR(60),
    SchemaName SYSNAME,
    CodeSnippet NVARCHAR(MAX)
);

DECLARE @dbName2 SYSNAME;
DECLARE @sql NVARCHAR(MAX);

-- Loop through user databases
DECLARE dbs CURSOR LOCAL FAST_FORWARD FOR

SELECT d.name
FROM sys.databases d
LEFT JOIN sys.dm_hadr_database_replica_states drs
    ON d.database_id = drs.database_id
LEFT JOIN sys.dm_hadr_availability_replica_states ars
    ON drs.replica_id = ars.replica_id
LEFT JOIN sys.availability_replicas ar
    ON ars.replica_id = ar.replica_id
WHERE d.database_id > 4
  AND d.state_desc = 'ONLINE'
  AND d.is_read_only = 0
  AND (ars.role = 1 OR ars.role IS NULL); -- 1 = PRIMARY


OPEN dbs;
FETCH NEXT FROM dbs INTO @dbName2;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = '
    USE [' + @dbName2 + '];
    SET NOCOUNT ON;

    WITH SystemTableMap AS (
        SELECT * FROM (VALUES
            (''sysobjects'', ''sys.objects''),
            (''sysindexes'', ''sys.indexes''),
            (''syscolumns'', ''sys.columns''),
            (''sysusers'', ''sys.database_principals''),
            (''syscomments'', ''sys.sql_modules''),
            (''sysdepends'', ''sys.sql_expression_dependencies'')
        ) AS tbl(SystemTable, RecommendedView)
    )
    INSERT INTO tempdb.dbo.SystemTableScanResults
    SELECT
        DB_NAME(),
        stm.SystemTable,
        stm.RecommendedView,
        OBJECT_NAME(m.object_id),
        o.type_desc,
        OBJECT_SCHEMA_NAME(m.object_id),
        LEFT(m.definition, 500)
    FROM sys.sql_modules m
    JOIN sys.objects o ON m.object_id = o.object_id
    CROSS JOIN SystemTableMap stm
    WHERE m.definition LIKE ''%'' + stm.SystemTable + ''%'';
    ';

    EXEC (@sql);

    FETCH NEXT FROM dbs INTO @dbName2;
END

CLOSE dbs;
DEALLOCATE dbs;

-- Output results
PRINT 'DATABASES THAT ARE ACCESSING SYSTEM TABLES '
SELECT
SUBSTRING(DatabaseName,1,60)AS DatabaseName,
SUBSTRING(SystemTable,1,20)AS SystemTable,
SUBSTRING(RecommendedView,1,20)AS USE_Substitute,
SUBSTRING(ReferencingObject,1,30)AS ReferencingObject,
SUBSTRING(ObjectType,1,30)AS ObjectType,
SUBSTRING(SchemaName,1,20)AS SchemaName--,CodeSnippet
FROM tempdb.dbo.SystemTableScanResults;

-- Optional: clean up
DROP TABLE tempdb.dbo.SystemTableScanResults;
----------------------------------------------
-----CHECK MAXDOP ----------------------------
DECLARE @service_account VARCHAR(50) = '';
DECLARE @fillfactor VARCHAR(2) = '0';
DECLARE @maxdop INT = 0;
DECLARE @costthreshhold VARCHAR(2) = '50';
DECLARE @DAC VARCHAR(1) = '1';
DECLARE @advanced VARCHAR(1) = '1';

-- Get configuration values
SET @fillfactor = (
    SELECT CAST(value_in_use AS VARCHAR(2)) 
    FROM sys.configurations 
    WHERE configuration_id = 109
);

SET @maxdop = (
    SELECT CAST(value_in_use AS INT) 
    FROM sys.configurations 
    WHERE configuration_id = 1539
);

SET @costthreshhold = (
    SELECT CAST(value_in_use AS VARCHAR(2)) 
    FROM sys.configurations 
    WHERE configuration_id = 1538
);

SET @DAC = (
    SELECT CAST(value_in_use AS VARCHAR(1)) 
    FROM sys.configurations 
    WHERE configuration_id = 1576
);

SET @advanced = (
    SELECT CAST(value_in_use AS VARCHAR(1)) 
    FROM sys.configurations 
    WHERE configuration_id = 518
);

-- Check fill factor
IF @fillfactor <> '100' AND @fillfactor <> '0'
BEGIN
    PRINT 'FILL FACTOR IS NOT SET TO VALUE(100%)';
    PRINT 'Current Fill Factor: ' + @fillfactor;
END
ELSE
    PRINT ' FILLFACTOR is '+ @fillfactor;

-- Check MAXDOP
DECLARE @cpu_count INT = (SELECT cpu_count FROM sys.dm_os_sys_info);
DECLARE @recommended_maxdop_half INT = @cpu_count / 2;

IF @maxdop NOT IN (0, @recommended_maxdop_half, @cpu_count)
BEGIN
    PRINT N'⚠️ MAXDOP MAY NOT BE SET CORRECTLY';
    PRINT 'Current MAXDOP: ' + CAST(@maxdop AS VARCHAR);
    PRINT 'CPU Count: ' + CAST(@cpu_count AS VARCHAR);
--   PRINT 'Recommended MAXDOP (Half): ' + CAST(@recommended_maxdop_half AS VARCHAR);
    IF @cpu_count = 4
        PRINT N'💡 RECOMMENDED: Set MAXDOP to 4 for 4-core systems.';
END
ELSE
BEGIN
    PRINT N'✅ MAXDOP IS CORRECTLY SET.';
END
              PRINT '------------------------'
-- Check cost threshold
IF @costthreshhold <> '50'
BEGIN
    PRINT N'⚠️ COST THRESHOLD FOR PARALLELISM IS NOT SET TO VALUE(50)';
    PRINT 'CURRENT COST THRESHOLD: ' + @costthreshhold;
END
ELSE
    PRINT 'CURRENT COST THRESHOLD: ' + @costthreshhold;

-- Check DAC
IF @DAC <> '1'
BEGIN
    PRINT N'❌ REMOTE ADMIN CONNECTION NOT ENABLED (DAC)';
    PRINT 'CURRENT DAC SETTING: ' + @DAC;
END
ELSE
    PRINT N'✅ REMOTE DAC ENABLED';

-- Check advanced options
IF @advanced <> '1'
BEGIN
    PRINT N'❌ REMOTE ADMIN CONNECTION NOT ENABLED (DAC)';
    PRINT N'❌ SHOW ADVANCED OPTIONS NOT ENABLED (1)';
    PRINT 'CURRENT ADVANCED OPTIONS SETTING: ' + @advanced;
END
ELSE
    PRINT N'✅ ADVANCED OPTIONS ENABLED';
----------------------------------------------------------
------FIND SSRS REPORTS DEPLOYED
------13/08/25
SET NOCOUNT ON;
SET XACT_ABORT OFF;

DECLARE @ReportDbName SYSNAME = NULL;
DECLARE @sql1 NVARCHAR(MAX);

BEGIN TRY
    -- Step 1: Find a ReportServer database (excluding TempDB)
    SELECT TOP 1 @ReportDbName = name
    FROM sys.databases
    WHERE name LIKE 'ReportServer%' 
      AND name NOT LIKE '%TempDB'
      AND state_desc = 'ONLINE';

    -- Step 2: If found, check AG status and list all replicas
    IF @ReportDbName IS NOT NULL
    BEGIN
        PRINT N'⚠️ SSRS DATABASE DISCOVERED: ' + @ReportDbName;

        IF EXISTS (
            SELECT 1
            FROM sys.dm_hadr_database_replica_states
            WHERE database_id = DB_ID(@ReportDbName)
        )
        BEGIN
            PRINT N'⚠️ Availability Group detected. Listing replica roles:';

            SELECT 
                SUBSTRING(ag.name,1,60) AS AG_Name,
                SUBSTRING(ar.replica_server_name,1,40) AS InstanceName,
                SUBSTRING(ars.role_desc,1,20) AS ReplicaRole,
                SUBSTRING(ars.connected_state_desc,1,20) AS ConnectionState
            FROM sys.availability_groups ag
            JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
            JOIN sys.dm_hadr_availability_replica_states ars ON ar.replica_id = ars.replica_id
            ORDER BY ars.role_desc DESC;
        END
        ELSE
        BEGIN
            PRINT N'⚠️ SSRS DATABASE IS NOT PART OF AN AVAILABILITY GROUP.';
        END

        -- Step 3: Run SSRS config query
        SET @sql1 = '
        USE [' + @ReportDbName + '];

        SELECT 
            SUBSTRING([Name],1,60) AS SSRS_CONFIG,
            SUBSTRING([Value],1,20) AS SSRS_Value
        FROM 
            [dbo].[ConfigurationInfo]
        WHERE 
            [Name] IN (
                ''EditSessionCacheLimit'',
                ''EditSessionTimeout'',
                ''MyReportsRole'',
                ''SessionTimeout'',
                ''SharePointIntegrated'',
                ''SiteName''
            );';

        EXEC sp_executesql @sql1;
    END
    ELSE
    BEGIN
        PRINT 'NO SSRS DATABASES DISCOVERED';
    END
END TRY
BEGIN CATCH
    PRINT '';
END CATCH
     PRINT '-------------------------------'
----------------------------------------------
SET NOCOUNT ON;
DECLARE @SSRSInstalled BIT = 0;
DECLARE @SSRSDatabaseName NVARCHAR(128);
DECLARE @sql5 NVARCHAR(MAX);

-- Check for SSRS-related databases
SELECT TOP 1 @SSRSDatabaseName = name
FROM master.dbo.sysdatabases
WHERE name LIKE 'ReportServer%';

IF @SSRSDatabaseName IS NOT NULL
BEGIN
    SET @SSRSInstalled = 1;
END

-- Conditional execution
IF @SSRSInstalled = 1
BEGIN
    PRINT N'⚠️ REPORTING SERVER DATABASES FOUND: ' + @SSRSDatabaseName;

    SET @sql5 = '
    SELECT
        CASE CL.Type
            WHEN 1 THEN ''Folder''
            WHEN 2 THEN ''Report''
            WHEN 3 THEN ''Resource''
            WHEN 4 THEN ''Linked Report''
            WHEN 5 THEN ''Data Source''
        END                                 AS ObjectType,
        SUBSTRING(CP.Name,1,20)             AS ParentName,
        SUBSTRING(CL.Name,1,60)             AS Name,
        SUBSTRING(CL.Path ,1,90)            AS Path,
        SUBSTRING(CU.UserName,1,20)         AS CreatedBy,
        CL.CreationDate                     AS CreationDate,
        SUBSTRING(UM.UserName,1,20)         AS ModifiedBy,
        CL.ModifiedDate                     AS ModifiedDate,
        CE.CountStart                       AS TotalExecutions,
        SUBSTRING(EL.InstanceName,1,20)     AS LastExecutedInstanceName,
        SUBSTRING(EL.UserName,1,20)         AS LastExecuter,
        EL.Format                           AS LastFormat,
        EL.TimeStart                        AS LastTimeStarted,
        EL.TimeEnd                          AS LastTimeEnded,
        EL.TimeDataRetrieval                AS LastTimeDataRetrieval,
        EL.TimeProcessing                   AS LastTimeProcessing,
        EL.TimeRendering                    AS LastTimeRendering,
        SUBSTRING(EL.Status,1,10)           AS LastResult,
        EL.ByteCount                        AS LastByteCount,
        EL.[RowCount]                       AS LastRowCount,
        SUBSTRING(SO.UserName,1,20)         AS SubscriptionOwner,
        SUBSTRING(SU.UserName,1,20)         AS SubscriptionModifiedBy,
        SS.ModifiedDate                     AS SubscriptionModifiedDate,
        SUBSTRING(SS.Description,1,30)      AS SubscriptionDescription,
        SUBSTRING(SS.LastStatus,1,10)       AS SubscriptionLastResult,
        SS.LastRunTime                      AS SubscriptionLastRunTime
    FROM [' + @SSRSDatabaseName + '].dbo.Catalog CL
    JOIN [' + @SSRSDatabaseName + '].dbo.Catalog CP
        ON CP.ItemID = CL.ParentID
    JOIN [' + @SSRSDatabaseName + '].dbo.Users CU
        ON CU.UserID = CL.CreatedByID
    JOIN [' + @SSRSDatabaseName + '].dbo.Users UM
        ON UM.UserID = CL.ModifiedByID
    LEFT JOIN ( SELECT
                    ReportID,
                    MAX(TimeStart) LastTimeStart
                FROM [' + @SSRSDatabaseName + '].dbo.ExecutionLog
                GROUP BY ReportID) LE
        ON LE.ReportID = CL.ItemID
    LEFT JOIN ( SELECT
                    ReportID,
                    COUNT(TimeStart) CountStart
                FROM [' + @SSRSDatabaseName + '].dbo.ExecutionLog
                GROUP BY ReportID) CE
        ON CE.ReportID = CL.ItemID
    LEFT JOIN [' + @SSRSDatabaseName + '].dbo.ExecutionLog EL
        ON EL.ReportID = LE.ReportID
        AND EL.TimeStart = LE.LastTimeStart
    LEFT JOIN [' + @SSRSDatabaseName + '].dbo.Subscriptions SS
        ON SS.Report_OID = CL.ItemID
    LEFT JOIN [' + @SSRSDatabaseName + '].dbo.Users SO
        ON SO.UserID = SS.OwnerID
    LEFT JOIN [' + @SSRSDatabaseName + '].dbo.Users SU
        ON SU.UserID = SS.ModifiedByID
    WHERE 1 = 1
    ORDER BY CP.Name, CL.Name ASC;
    ';

    EXEC sp_executesql @sql5;
END
ELSE
BEGIN
    PRINT N'✅ NO SSRS DATABASE FOUND. Skipping report analysis.';
END

  ----------------------------------------------------------------
-- KERBEROS CHECK

IF EXISTS (
    SELECT 1
    FROM sys.dm_exec_connections
    WHERE session_id = @@SPID AND auth_scheme = 'KERBEROS'
)
    PRINT 'THE INSTANCE IS CONFIGURED TO USE KERBEROS';
              PRINT '------------------------------------------'
  ----------------------------------------------------------------
  --QUERYSTORE
--------------------------------------------------------------------
SET NOCOUNT ON;

-- Create a permanent results table in tempdb
USE tempdb;
IF OBJECT_ID('dbo.SystemTableScanResults') IS NOT NULL DROP TABLE dbo.SystemTableScanResults;
CREATE TABLE dbo.SystemTableScanResults (
    DatabaseName SYSNAME,
    SystemTable SYSNAME,
    RecommendedView SYSNAME,
    ReferencingObject SYSNAME,
    ObjectType NVARCHAR(60),
    SchemaName SYSNAME,
    CodeSnippet NVARCHAR(MAX)
);

DECLARE @DBName SYSNAME;
DECLARE @SQL6 NVARCHAR(MAX);

-- Cursor to loop through user databases that are ONLINE, writable, and PRIMARY in AG (or not in AG)
DECLARE db_cursor CURSOR LOCAL FAST_FORWARD FOR
SELECT d.name
FROM sys.databases d
LEFT JOIN sys.dm_hadr_database_replica_states drs
    ON d.database_id = drs.database_id
LEFT JOIN sys.dm_hadr_availability_replica_states ars
    ON drs.replica_id = ars.replica_id
WHERE d.database_id > 4
  AND d.state_desc = 'ONLINE'
  AND d.is_read_only = 0
  AND (ars.role = 1 OR ars.role IS NULL); -- 1 = PRIMARY, NULL = not in AG

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @DBName;

WHILE @@FETCH_STATUS = 0
BEGIN
    PRINT N'🔍 CHECKING DATABASE: ' + QUOTENAME(@DBName);

    BEGIN TRY
        -- Check for system table usage
        SET @SQL6 = '
        USE ' + QUOTENAME(@DBName) + ';
        SET NOCOUNT ON;

        WITH SystemTableMap AS (
            SELECT * FROM (VALUES
                (''sysobjects'', ''sys.objects''),
                (''sysindexes'', ''sys.indexes''),
                (''syscolumns'', ''sys.columns''),
                (''sysusers'', ''sys.database_principals''),
                (''syscomments'', ''sys.sql_modules''),
                (''sysdepends'', ''sys.sql_expression_dependencies'')
            ) AS tbl(SystemTable, RecommendedView)
        )
        INSERT INTO tempdb.dbo.SystemTableScanResults
        SELECT
            DB_NAME(),
            stm.SystemTable,
            stm.RecommendedView,
            OBJECT_NAME(m.object_id),
            o.type_desc,
            OBJECT_SCHEMA_NAME(m.object_id),
            LEFT(m.definition, 500)
        FROM sys.sql_modules m
        JOIN sys.objects o ON m.object_id = o.object_id
        CROSS JOIN SystemTableMap stm
        WHERE m.definition LIKE ''%'' + stm.SystemTable + ''%'';';
        
        EXEC (@SQL6);

        -- Check Query Store settings
        SET @SQL6 = '
        USE ' + QUOTENAME(@DBName) + ';
        SELECT 
            DB_NAME() AS DatabaseName,
            SUBSTRING(actual_state_desc,1,10) AS ActualState,
            SUBSTRING(desired_state_desc,1,10) AS DesiredState,
            SUBSTRING(query_capture_mode_desc,1,10) AS QueryCaptureMode,
            SUBSTRING(size_based_cleanup_mode_desc,1,10) AS CleanupMode,
            max_storage_size_mb,
            stale_query_threshold_days
        FROM sys.database_query_store_options;';
        
        EXEC (@SQL6);
    END TRY
    BEGIN CATCH
        PRINT N'⚠️ Error accessing database: ' + QUOTENAME(@DBName);
        PRINT ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @DBName;
END

CLOSE db_cursor;
DEALLOCATE db_cursor;
------------------------------------------------------------------------
-- Output results
PRINT N'📋 DATABASES THAT ARE ACCESSING SYSTEM TABLES';
SELECT
    SUBSTRING(DatabaseName,1,60) AS DatabaseName,
    SUBSTRING(SystemTable,1,20) AS SystemTable,
    SUBSTRING(RecommendedView,1,20) AS USE_Substitute,
    SUBSTRING(ReferencingObject,1,30) AS ReferencingObject,
    SUBSTRING(ObjectType,1,30) AS ObjectType,
    SUBSTRING(SchemaName,1,20) AS SchemaName
FROM tempdb.dbo.SystemTableScanResults;

-- Optional: clean up
DROP TABLE tempdb.dbo.SystemTableScanResults;

  ----------------------------------------------------------------
 --Get Orphaned Users 14/08/25
--------------------------------
-- Step 1: Create temp table for results
SET NOCOUNT ON
IF OBJECT_ID('tempdb..#orphaned_users') IS NOT NULL DROP TABLE #orphaned_users;

CREATE TABLE #orphaned_users (
    DatabaseName SYSNAME,
    OrphanedUser SYSNAME,
    UserType NVARCHAR(60)
);

-- Step 2: Create temp table with AG role info
IF OBJECT_ID('tempdb..#db_roles') IS NOT NULL DROP TABLE #db_roles;

SELECT 
    d.name AS DatabaseName,
    CASE 
        WHEN drs.is_primary_replica = 1 THEN 1
        WHEN drs.is_primary_replica = 0 THEN 0
        ELSE -1 -- Not in AG
    END AS is_primary_replica
INTO #db_roles
FROM sys.databases d
LEFT JOIN sys.dm_hadr_database_replica_states drs 
    ON d.database_id = drs.database_id
WHERE d.state_desc = 'ONLINE'
  AND d.name NOT IN ('master', 'model', 'msdb', 'tempdb', 'SSISDB'); -- exclude system DBs

-- Step 3: Cursor to loop through only primary or non-AG user databases
DECLARE @dbName6 NVARCHAR(128);
DECLARE @stmt NVARCHAR(MAX);

DECLARE db_cursor CURSOR FOR
SELECT DatabaseName
FROM #db_roles
WHERE is_primary_replica IN (1, -1); -- primary or not in AG

OPEN db_cursor;
FETCH NEXT FROM db_cursor INTO @dbName6;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @stmt = '
    INSERT INTO #orphaned_users (DatabaseName, OrphanedUser, UserType)
    SELECT 
        ''' + @dbName6 + ''' AS [DatabaseName],
        dp.name AS [OrphanedUser],
        dp.type_desc AS [UserType]
    FROM [' + @dbName6 + '].sys.database_principals dp
    LEFT JOIN sys.server_principals sp ON dp.sid = sp.sid
    WHERE dp.type IN (''S'', ''U'')
      AND sp.sid IS NULL
      AND dp.sid IS NOT NULL
      AND dp.name NOT IN (''guest'', ''INFORMATION_SCHEMA'', ''sys'', ''dbo'');';

    BEGIN TRY
        EXEC (@stmt);
    END TRY
    BEGIN CATCH
        PRINT 'Error accessing database [' + @dbName + ']: ' + ERROR_MESSAGE();
    END CATCH;

    FETCH NEXT FROM db_cursor INTO @dbName6;
END;

CLOSE db_cursor;
DEALLOCATE db_cursor;
PRINT 'ORPHANED USERS'

-- Step 4: Return only real orphaned users
SELECT SUBSTRING(DatabaseName,1,50)AS DatabaseName,
       SUBSTRING(OrphanedUser,1,20) AS OrphanedUser
FROM #orphaned_users;

-- Cleanup
DROP TABLE #db_roles;
DROP TABLE #orphaned_users;

------------------------------------------------------------------
--Databases with wrong owner found
---------------------------------------------------
DECLARE @Results TABLE (
    DatabaseName NVARCHAR(128),
    Owner NVARCHAR(128)
);

INSERT INTO @Results (DatabaseName, Owner)
SELECT 
   SUBSTRING(name, 1, 50) AS DatabaseName,
   SUBSTRING(SUSER_SNAME(owner_sid), 1, 30) AS Owner
FROM sys.databases

WHERE state_desc = 'ONLINE'
  AND database_id > 4  -- Exclude system databases
  AND SUSER_SNAME(owner_sid) IS NOT NULL
  AND UPPER(SUSER_SNAME(owner_sid)) <> 'SA'
    AND UPPER(SUSER_SNAME(owner_sid)) <> 'moxireader';

IF EXISTS (SELECT 1 FROM @Results)
BEGIN
    PRINT N'⚠️ DATABASES FOUND WITH WRONG OWNER';
--   SELECT * FROM @Results;
SELECT SUBSTRING(DatabaseName,1,50)AS DatabaseName,
       SUBSTRING(Owner,1,20) AS OrphanedUser
FROM @Results

END

  -----------------------------------------------------------------
  -- Check for non-system databases with non-SA owners
SET NOCOUNT ON;

DECLARE @Results1 TABLE (
    DatabaseName NVARCHAR(128),
    Owner NVARCHAR(128)
);

INSERT INTO @Results1 (DatabaseName, Owner)
SELECT 
   SUBSTRING(name, 1, 50) AS DatabaseName,
   SUBSTRING(SUSER_SNAME(owner_sid), 1, 30) AS Owner
FROM sys.databases
WHERE state_desc = 'ONLINE'
  AND database_id > 4
  AND SUSER_SNAME(owner_sid) IS NOT NULL
  AND UPPER(SUSER_SNAME(owner_sid)) <> 'SA'
  AND UPPER(SUSER_SNAME(owner_sid)) <> 'MOXIREADER';

IF EXISTS (SELECT 1 FROM @Results1)
BEGIN
    PRINT N'⚠️ DATABASES FOUND WITH WRONG OWNER';

	SELECT 
	SUBSTRING(DatabaseName,1,50)AS DatabaseName, 
	SUBSTRING(Owner,1,20) AS Owner
	 FROM @Results1;
END
----------------------------------------------------------------
-- Check if default trace is enabled

DECLARE @TraceEnabled INT;
SELECT @TraceEnabled = CAST(value AS INT)
FROM sys.configurations
WHERE name = 'default trace enabled';

PRINT N'🔍 Looking for login fails in the last 24 hours....';

IF @TraceEnabled = 1
BEGIN
    DECLARE @TraceFile NVARCHAR(255);
    SELECT TOP 1 @TraceFile = CAST(value AS NVARCHAR(255))
    FROM sys.fn_trace_getinfo(NULL)
    WHERE property = 2;

    IF @TraceFile IS NOT NULL AND @TraceFile <> ''
    BEGIN
        IF EXISTS (
            SELECT 1
            FROM sys.fn_trace_gettable(@TraceFile, DEFAULT)
            WHERE EventClass = 20
              AND StartTime >= DATEADD(DAY, -1, GETDATE())
        )
        BEGIN
            SELECT 
                SUBSTRING(LoginName, 1, 40) AS LoginName,
                StartTime,
                SUBSTRING(HostName, 1, 30) AS HostName,
                SUBSTRING(ApplicationName, 1, 30) AS ApplicationName,
                SUBSTRING(TextData, 1, 200) AS ErrorMessage
            FROM sys.fn_trace_gettable(@TraceFile, DEFAULT)
            WHERE EventClass = 20
              AND StartTime >= DATEADD(DAY, -1, GETDATE())
            ORDER BY StartTime DESC;
        END
        ELSE
        BEGIN
            PRINT N'✅ NO FAILED LOGINS LAST 24 HOURS';
        END
    END
    ELSE
    BEGIN
        PRINT N'⚠️ Default trace is enabled but no trace file found.';
    END
END
ELSE
BEGIN
    PRINT N'⚠️ Default trace is not enabled on this SQL Server instance.';
END

-----------------------------------------------
PRINT 'CURRENT ERRORLOG [ERRORS]'
PRINT '-------------------------'
-- Drop the temp table if it already exists
IF OBJECT_ID('tempdb..#ReadErrorLog') IS NOT NULL
    DROP TABLE #ReadErrorLog;

-- Create a temporary table to hold the results
CREATE TABLE #ReadErrorLog (
    LogDate DATETIME,
    ProcessInfo NVARCHAR(20),
    LogText NVARCHAR(MAX)
);
--CREATE NONCLUSTERED INDEX IX_ReadErrorLog_ProcessInfo_LogDate
--ON #ReadErrorLog (ProcessInfo, LogDate);

-- Insert the results of xp_readerrorlog into the temp table
INSERT INTO #ReadErrorLog
EXEC xp_readerrorlog;

SELECT   LogDate,ProcessInfo,LogText
    FROM #ReadErrorLog
    WHERE           
          LogDate >= getdate()-7
     AND   
          LogText LIKE '%error%' 

-- Clean up
DROP TABLE #ReadErrorLog
-----------------------------------------------
--------------------BACKUP INFORMATION FOR 1 WEEK
PRINT 'FULL BACKUPS FOR LAST WEEK'
PRINT '--------------------------'
                             USE MSDB
                             SELECT 
               SUBSTRING ([database_name],1,50) as 'DB',
                                              [backup_start_date] as 'backup start',
                                              [backup_finish_date] as 'backup finish',
               SUBSTRING([physical_device_name],1,90) as BackupLocation,
                                                          [type],
                                                          SUBSTRING(CAST([backup_size]AS VARCHAR(20)),1,20) as 'Size in KB' ,
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

PRINT N'📊 REPORT HAS NOW COMPLETED. RAN  ON ----> ' + CAST(getdate()AS VARCHAR(20))
---------REPORT END---------------------------------------



