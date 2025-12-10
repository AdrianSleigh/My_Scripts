
SET NOCOUNT ON
--SQL Instance Report
--Designed to collate most useful data to create report for dbas to get an instant view.	
--Written By Adrian Sleigh 10/12/25
--Version 32.0 Added SQL 2016 out of order bersion check fixed
---------------------------------------------------------------------------
PRINT N'📊 Generating Report...';
SELECT
    'MSSQL SQL SERVER REPORT - INSTANCE NAME IS ' + 
    @@SERVERNAME + 
    ' | Last SQL Restart: ' + 
    CONVERT(VARCHAR, sqlserver_start_time, 120) + 
    ' | UPTIME: ' + 
    CAST(DATEDIFF(SECOND, sqlserver_start_time, GETDATE()) / 86400 AS VARCHAR) + ' days, ' +
    CAST((DATEDIFF(SECOND, sqlserver_start_time, GETDATE()) % 86400) / 3600 AS VARCHAR) + ' hours, ' +
    CAST((DATEDIFF(SECOND, sqlserver_start_time, GETDATE()) % 3600) / 60 AS VARCHAR) + ' minutes'
FROM 
    sys.dm_os_sys_info;

-- ============================================================
-- SQL Server Version Check with 2019 Baseline + Back-branch patch check
-- ============================================================

SET NOCOUNT ON;

-- Current version info
DECLARE @CurrentVersion NVARCHAR(50) = CONVERT(NVARCHAR(50), SERVERPROPERTY('ProductVersion'));
DECLARE @MajorVersion   INT          = TRY_CONVERT(INT, LEFT(@CurrentVersion, CHARINDEX('.', @CurrentVersion + '.') - 1));

DECLARE @VersionName   NVARCHAR(50);
DECLARE @LatestVersion NVARCHAR(50); -- four-part version string per branch

-- Map major versions to friendly names & latest known builds

IF @MajorVersion = 17
BEGIN
    SET @VersionName   = N'SQL Server 2025';
    SET @LatestVersion = N'17.0.1000.7'; -- 18/11/25 SQL Server 2025 
END
ELSE IF @MajorVersion = 16
BEGIN
    SET @VersionName   = N'SQL Server 2022';
    SET @LatestVersion = N'16.0.4225.2'; -- SQL Server 2022 CU22 (Nov 2025)
END
ELSE IF @MajorVersion = 15
BEGIN
    SET @VersionName   = N'SQL Server 2019';
    SET @LatestVersion = N'15.0.4452.2'; -- SQL Server 2019 CU32 (Nov 2025)
END
ELSE IF @MajorVersion = 14
BEGIN
    SET @VersionName   = N'SQL Server 2017';
    SET @LatestVersion = N'14.0.3456.2'; -- SQL Server 2017 CU31
END
ELSE IF @MajorVersion = 13
BEGIN
    -----OUT OF SYNC VERSION CHECK 10/12/25
    -- Branch/Track-aware handling for SQL Server 2016 (13.x)
    -- This prevents misclassification when Microsoft ships a later-dated
    -- GDR on SP2 with a lower build number than SP3 (e.g., 13.0.6475.1).
    -----------------------------------------------------------------------
    DECLARE @ProductLevel       sysname = CONVERT(sysname, SERVERPROPERTY('ProductLevel'));         -- RTM/SP1/SP2/SP3
    DECLARE @ProductUpdateLevel sysname = CONVERT(sysname, SERVERPROPERTY('ProductUpdateLevel'));   -- CUxx or GDRxx (NULL if none)

    DECLARE @SP tinyint = CASE WHEN @ProductLevel = 'RTM' THEN 0
                               ELSE TRY_CONVERT(tinyint, REPLACE(@ProductLevel,'SP','')) END;
    DECLARE @Track varchar(3) = CASE WHEN @ProductUpdateLevel LIKE 'CU%' THEN 'CU' ELSE 'GDR' END;

    -- Friendly name reflects actual branch & update train
    SET @VersionName =
        N'SQL Server 2016' +
        CASE WHEN @SP > 0 THEN CONCAT(' SP', @SP) ELSE N'' END +
        CASE WHEN @ProductUpdateLevel IS NULL THEN N'' ELSE CONCAT(' ', @ProductUpdateLevel) END;

    -- Baselines per branch/track (update these when Microsoft ships new fixes)
    IF @SP = 3 AND @Track = 'GDR'
        SET @LatestVersion = N'13.0.7070.1';   -- SQL Server 2016 SP3 GDR
    ELSE IF @SP = 2 AND @Track = 'GDR'
        SET @LatestVersion = N'13.0.6475.1';   -- SQL Server 2016 SP2 GDR (Nov release)
    ELSE IF @SP = 3 AND @Track = 'CU'
        -- If you maintain CU baselines, put the current SP3 CU here; else default to SP3 GDR
        SET @LatestVersion = N'13.0.7070.1';   -- defaulting to SP3 GDR baseline
        -- Example: SET @LatestVersion = N'13.0.78xx.x'; -- SP3 CUx
    ELSE IF @SP = 2 AND @Track = 'CU'
        -- If you maintain CU baselines, put the current SP2 CU here; else default to SP2 GDR
        SET @LatestVersion = N'13.0.6475.1';   -- defaulting to SP2 GDR baseline
        -- Example: SET @LatestVersion = N'13.0.65xx.x'; -- SP2 CUx
    ELSE
        -- Fallback: prefer highest serviced GDR you allow (keeps policy simple)
        SET @LatestVersion = N'13.0.7060.1';   -- safe default (SP3 GDR)
END
ELSE IF @MajorVersion = 12
BEGIN
    SET @VersionName   = N'SQL Server 2014';
    SET @LatestVersion = N'12.0.6329.1'; -- SQL Server 2014 SP3 CU4
END
ELSE IF @MajorVersion = 11
BEGIN
    SET @VersionName   = N'SQL Server 2012';
    SET @LatestVersion = N'11.0.7462.6'; -- SQL Server 2012 SP4 CU4
END
ELSE IF @MajorVersion = 10
BEGIN
    SET @VersionName   = N'SQL Server 2008 R2';
    SET @LatestVersion = N'10.50.6560.0'; -- SQL Server 2008 R2 SP3 GDR
END
ELSE
BEGIN
    PRINT N'⚠️ POSSIBLE UNSUPPORTED/UNKNOWN VERSION: ' + ISNULL(@CurrentVersion, N'(null)');
    RETURN;
END

-- Helper: numeric compare of four-part versions using PARSENAME
DECLARE @cMaj INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@CurrentVersion, 4)), 0);
DECLARE @cMin INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@CurrentVersion, 3)), 0);
DECLARE @cBld INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@CurrentVersion, 2)), 0);
DECLARE @cRev INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@CurrentVersion, 1)), 0);

DECLARE @lMaj INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@LatestVersion, 4)), 0);
DECLARE @lMin INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@LatestVersion, 3)), 0);
DECLARE @lBld INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@LatestVersion, 2)), 0);
DECLARE @lRev INT = ISNULL(TRY_CONVERT(INT, PARSENAME(@LatestVersion, 1)), 0);

DECLARE @BranchOutdated BIT =
    CASE
        WHEN @cMaj < @lMaj THEN 1
        WHEN @cMaj > @lMaj THEN 0
        WHEN @cMin < @lMin THEN 1
        WHEN @cMin > @lMin THEN 0
        WHEN @cBld < @lBld THEN 1
        WHEN @cBld > @lBld THEN 0
        WHEN @cRev < @lRev THEN 1
        ELSE 0
    END;

-- Output base info
PRINT N'Detected Version: ' + @VersionName;
PRINT N'Current SQL Server Version: ' + @CurrentVersion;
PRINT N'Latest Known Version (Dec 2025) for this branch: ' + @LatestVersion;

-- ============================================
-- Enforce baseline: SQL Server 2019 required
-- ============================================
IF @MajorVersion <> 15
BEGIN
    PRINT N'⚠️ Upgrade to SQL Server 2019 required (baseline policy). Detected: '
        + @VersionName + N' (' + @CurrentVersion + N')';

    -- Additionally evaluate patch status only when LOWER than 2019
    IF @MajorVersion < 15
    BEGIN
        IF @BranchOutdated = 1
            PRINT N'⚠️ Patch Required (Current Branch): Your ' + @VersionName
                + N' instance is not fully patched. Target at least: ' + @LatestVersion + N'.';
        ELSE
            PRINT N' Current Branch Status: Your ' + @VersionName
                + N' ✅ instance appears fully patched for its branch.';
    END

    RETURN; -- stop here; remove/modify if you want further actions
END

-- ============================================
-- Only for SQL Server 2019: evaluate patch status
-- ============================================
IF @BranchOutdated = 1
    PRINT N'⚠️ UPDATE REQUIRED: Your SQL Server 2019 instance is not fully patched. Target: ' + @LatestVersion + N'.';
ELSE
    PRINT N'✅ Up to Date: Your SQL Server 2019 instance appears to be on the latest patch.';
GO
--------------------------------------------------------------
---latest version 22/09/25
------------------------------------------------------------------
PRINT '.NET VERSION'
PRINT '------------'
SET NOCOUNT ON
DECLARE @Release INT;

-- Primary (64‑bit) registry view
EXEC master..xp_regread
    @rootkey    = N'HKEY_LOCAL_MACHINE',
    @key        = N'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full',
    @value_name = N'Release',
    @value      = @Release OUTPUT;

-- Fallback to 32‑bit view if needed
IF @Release IS NULL
BEGIN
    EXEC master..xp_regread
        @rootkey    = N'HKEY_LOCAL_MACHINE',
        @key        = N'SOFTWARE\Wow6432Node\Microsoft\NET Framework Setup\NDP\v4\Full',
        @value_name = N'Release',
        @value      = @Release OUTPUT;
END
SELECT 
    @Release AS ReleaseValue,
    CASE 
        WHEN @Release IS NULL        THEN 'No 4.5 or later detected'
        WHEN @Release >= 533320      THEN '.NET Framework 4.8.1 or later'
        WHEN @Release >= 528040      THEN '.NET Framework 4.8'
        WHEN @Release >= 461808      THEN '.NET Framework 4.7.2'
        WHEN @Release >= 461308      THEN '.NET Framework 4.7.1'
        WHEN @Release >= 460798      THEN '.NET Framework 4.7'
        WHEN @Release >= 394802      THEN '.NET Framework 4.6.2'
        WHEN @Release >= 394254      THEN '.NET Framework 4.6.1'
        WHEN @Release >= 393295      THEN '.NET Framework 4.6'
        WHEN @Release >= 379893      THEN '.NET Framework 4.5.2'
        WHEN @Release >= 378675      THEN '.NET Framework 4.5.1'
        WHEN @Release >= 378389      THEN '.NET Framework 4.5'
        ELSE N' ⛔ Version not recognized'
    END AS DotNetVersion;
   PRINT '---------------------------------------------------------------------'
-- Print upgrade warning if version is below 4.7.2
IF @Release IS NULL OR @Release < 461808

    PRINT N'⛔ .NET Framework 4.7.2 or later is required. ❌ .NET NEEDS UPGRADE.'
	ELSE PRINT N' ✅.NET Version is OK'
	;
--------------------------------------------------------------
--GET INSTANCE PROPERTIES
SELECT 
  SUBSTRING(SUSER_SNAME(),1,20)AS RanBy, 
  SUBSTRING(HOST_NAME(),1,20) AS RanFrom,
  SUBSTRING(CAST(SERVERPROPERTY('MachineName')AS VARCHAR(20)),1,20) AS ComputerName,
  SUBSTRING(CAST(SERVERPROPERTY('Edition') AS VARCHAR(30)),1,30)AS 'SQL Server Edition',
  SUBSTRING(CAST(SERVERPROPERTY('Collation') AS VARCHAR(25)),1,25)AS Collation,
  SUBSTRING(CAST(SERVERPROPERTY('IsClustered') AS VARCHAR(10)),1,10)AS IsClustered, 
  SUBSTRING(CAST(SERVERPROPERTY('IsFullTextInstalled')AS VARCHAR(10)),1,10) AS IsFullTextInstalled 
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID
SELECT    
   SUBSTRING(CAST(SERVERPROPERTY('ProductUpdateReference') AS VARCHAR),1,16) AS [Update Ref],    
   SUBSTRING(CAST(SERVERPROPERTY('BuildClrVersion')  AS VARCHAR),1,16) AS[CLR Version],
   SUBSTRING(CAST(CONNECTIONPROPERTY('local_net_address') AS VARCHAR(16)),1,16) AS Server_net_address,
   SUBSTRING(CAST(CONNECTIONPROPERTY('local_tcp_port')AS VARCHAR (10)),1,10) AS local_tcp_port,
   SUBSTRING(CAST(CONNECTIONPROPERTY('client_net_address') AS VARCHAR(16)),1,16) AS myclient_net_address

  SELECT
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultDataPath')AS VARCHAR(50)),1,2) AS DefaultDatadrive, 
  SUBSTRING(CAST(SERVERPROPERTY('InstanceDefaultLogPath') AS VARCHAR(50)),1,2)AS DefaultLogdrive, 
  SUBSTRING(CAST(SERVERPROPERTY('IsHadrEnabled') AS VARCHAR(10)),1,20)AS IsHadrEnabled, 
  SUBSTRING(CAST(SERVERPROPERTY('HadrManagerStatus') AS VARCHAR(10)),1,20)AS AlwaysOnStatus,
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSet') AS VARCHAR(10)),1,10) AS SqlCharSet,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrder') AS VARCHAR(10)),1,10) AS SqlSortOrder,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlCharSetName')AS VARCHAR(10)),1,10) AS SqlCharSetName,  
  SUBSTRING(CAST(SERVERPROPERTY('SqlSortOrderName')AS VARCHAR(20)),1,20) AS SqlSortOrderName,  
  SUBSTRING(CAST(SERVERPROPERTY('IsIntegratedSecurityOnly')AS VARCHAR(10)),1,20) AS IsIntegratedSecurityOnly  
  FROM SYS.DM_EXEC_CONNECTIONS WHERE SESSION_ID = @@SPID

-------------------------------------------------------------------------
--GET SERVER CPU AND MEMORY INFO

SET NOCOUNT ON
--GET CPU SPEED
--PRINT 'CPU TYPE/SPEED'
CREATE TABLE #Temp_cpu
(
Col1 VARCHAR(20),
Col2 VARCHAR(60)
)

INSERT INTO #Temp_cpu
EXEC sys.xp_instance_regread N'HKEY_LOCAL_MACHINE', N'HARDWARE\DESCRIPTION\System\CentralProcessor\0', N'ProcessorNameString';

SELECT col2 AS PROCESSOR FROM #temp_cpu

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
---CHECK MEMORY SETTINGS 16/09/25 revised version
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
    WHERE [name] LIKE '%SSISDB%'
)
    SET @SSISPresent = 1;

-- Detect SSRS
IF EXISTS (
    SELECT 1
    FROM sysdatabases
    WHERE [name] LIKE '%ReportServer%'
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
    PRINT N'⚠️ SQL Server is using less memory than recommended.';
    PRINT N'💡 Consider increasing max server memory to ' + CAST(@SuggestedMaxMemoryMB AS VARCHAR) + ' MB.';
END
ELSE
BEGIN
    PRINT N'✅ SQL Server memory configuration appears appropriate for this workload.';
END
PRINT 'Always leave at least 2GB for operating system. If SSRS or SSIS is installed leave additional memory for those external services'
PRINT 'Example settings if BI Stack is being used..'
PRINT '---------------------------------------------'
PRINT 'SQL only          - leave 2GB for OS 6144MB 8GB-2G'
PRINT 'SQL + SSRS        - leave 2GB for OS 5120MB +1 GB for SSRS'
PRINT 'SQL + SSIS        - leave 2GallB for OS 4096MB +2 GB for SSIS'
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
    PRINT N'⛔ NO PROXY ACCOUNTS PRESENT';
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
                  @SQLVersion      INT
                 ,@NumaNodes       INT
                 ,@NumCPUs         INT
                 ,@MaxDop          SQL_VARIANT
                 ,@RecommendedMaxDop    INT

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
    PRINT N'⛔ NO OLA HALLENGREN SCRIPTS PRESENT IN ANY DATABASE.';
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
    PRINT N'⛔ NOT A CLUSTERED INSTANCE';
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
    PRINT N'⛔ NO ALWAYS ON AVAILABILITY GROUP PRESENT';
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
    PRINT N'⛔ NO MIRRORED DATABASES PRESENT';
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
    PRINT N'⛔ NO LOG SHIPPING CONFIGURED';
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
        PRINT N'⛔ POLYBASE IS NOT INSTALLED.';
    END
END
-----------------------------------------------------
-- CHECK TEMPDB FILES ARE CORRECT
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
    PRINT N'⛔ TEMPDB DATAFILE CONFIGURATION ISSUE: ' + @ErrorMessage;
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
    PRINT N'⛔ NO POLICY-BASED MANAGEMENT CONFIGURED';
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
-- Check SSRS Account
IF EXISTS (
    SELECT 1
    FROM sys.dm_hadr_availability_replica_states ars
    JOIN sys.availability_replicas ar ON ars.replica_id = ar.replica_id
    WHERE ars.role_desc = 'PRIMARY'
      AND ar.replica_server_name = @@SERVERNAME
)
BEGIN
    PRINT 'Running on PRIMARY. Proceeding with script...';

/* ================================================================
   Identify SSRS gMSA via ReportServer DB permissions
   - Searches all ReportServer* DBs (excludes *TempDB)
   - Looks for membership in RSExecRole and/or db_owner
   - Returns only principals that look like gMSA (name ends with $)
   - If none found, prints "SSRS likely using a system account"
   Requirements: Typically sysadmin (or rights to read DB metadata)
   ================================================================*/
SET NOCOUNT ON;

-- 1) Collect ReportServer DBs (exclude TempDBs)
IF OBJECT_ID('tempdb..#RSDBs') IS NOT NULL DROP TABLE #RSDBs;
CREATE TABLE #RSDBs (DBName SYSNAME PRIMARY KEY);

INSERT INTO #RSDBs(DBName)
SELECT name
FROM sys.databases



WHERE name LIKE N'ReportServer%' 
  AND name NOT LIKE N'%TempDB'
  AND state_desc = N'ONLINE' ;

IF NOT EXISTS (SELECT 1 FROM #RSDBs)
BEGIN
    PRINT N'⛔ No ReportServer database found on this instance.';
    RETURN;
END

-- 2) Holder for gMSA findings across all RS DBs
IF OBJECT_ID('tempdb..#FoundGmsa') IS NOT NULL DROP TABLE #FoundGmsa;
CREATE TABLE #FoundGmsa
(
    DBName        SYSNAME         NOT NULL,
    GmsaAccount   NVARCHAR(512)   NOT NULL,
    RoleName      SYSNAME         NOT NULL,
    PrincipalType NVARCHAR(128)   NULL
);

-- 3) Iterate RS DBs and pull role membership; filter to gMSA (ends with $)
DECLARE @db SYSNAME, @sql NVARCHAR(MAX);

DECLARE dbs CURSOR LOCAL FAST_FORWARD FOR
    SELECT DBName FROM #RSDBs
    ORDER BY CASE WHEN DBName = N'ReportServer' THEN 0 ELSE 1 END, DBName;

OPEN dbs;
FETCH NEXT FROM dbs INTO @db;

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = N'
USE ' + QUOTENAME(@db) + N';
;WITH RoleMembers AS
(
    SELECT 
        dp.name           AS DatabaseUser,
        dp.type_desc      AS DbPrincipalType,
        dp.sid            AS DbSid,
        rl.name           AS RoleName
    FROM sys.database_principals AS dp
    JOIN sys.database_role_members AS drm
      ON dp.principal_id = drm.member_principal_id
    JOIN sys.database_principals AS rl
      ON rl.principal_id = drm.role_principal_id
    WHERE rl.name IN (N''RSExecRole'', N''db_owner'')
      AND dp.name <> N''dbo'' -- exclude dbo alias
),
Mapped AS
(
    SELECT 
        rm.DatabaseUser,
        rm.RoleName,
        -- Collate both sides to the database default collation
        COALESCE(
            sp.name COLLATE DATABASE_DEFAULT,
            rm.DatabaseUser COLLATE DATABASE_DEFAULT
        ) AS PrincipalName,
        COALESCE(sp.type_desc, rm.DbPrincipalType) AS PrincipalType
    FROM RoleMembers rm
    LEFT JOIN sys.server_principals sp
      ON sp.sid = rm.DbSid
     AND rm.DbSid IS NOT NULL
     AND rm.DbSid <> 0x00
)
SELECT
    DB_NAME()       AS DBName,
    M.PrincipalName AS GmsaAccount,
    M.RoleName      AS RoleName,
    M.PrincipalType AS PrincipalType
FROM Mapped AS M
WHERE M.PrincipalName LIKE N''%$''; -- gMSA pattern (DOMAIN\name$)
';
    INSERT INTO #FoundGmsa (DBName, GmsaAccount, RoleName, PrincipalType)
    EXEC (@sql);

    FETCH NEXT FROM dbs INTO @db;
END

CLOSE dbs;
DEALLOCATE dbs;

-- 4) Output gMSA or print system-account hint
IF EXISTS (SELECT 1 FROM #FoundGmsa)
BEGIN
PRINT N'SSRS ACCOUNT'
    SELECT DISTINCT 
        SUBSTRING(DBName,1,50)AS DbName,
        SUBSTRING(GmsaAccount,1,20)  AS SSRS_gMSA_Account,
        SUBSTRING(RoleName,1,20) AS RoleName,
        SUBSTRING(PrincipalType,1,20) AS PrincipalType
    FROM #FoundGmsa
    ORDER BY DBName, RoleName, SSRS_gMSA_Account, PrincipalType;
END
ELSE
BEGIN
    PRINT N'SSRS likely using a system account (no gMSA found in RSExecRole/db_owner).';
END

-- Cleanup (optional)
DROP TABLE IF EXISTS #FoundGmsa;
DROP TABLE IF EXISTS #RSDBs;

END
ELSE
BEGIN
    PRINT 'No SSRS or running on the SECONDARY. Skipping ----.';
END
--------------------------------------------------------------
--GET SSRS SERVERS LIST
IF EXISTS (
    SELECT 1 
    FROM sys.databases 
    WHERE name = 'ReportServer' AND state_desc = 'ONLINE'
)
BEGIN
    IF DATABASEPROPERTYEX('ReportServer', 'Updateability') = 'READ_WRITE'
    BEGIN
        -- Safe to run SSRS-related queries
     SELECT 
SUBSTRING(MachineName,1,30) AS 'Associated SSRS Servers' 
FROM ReportServer.dbo.Keys
WHERE MachineName IS NOT NULL;
    END
    ELSE
    BEGIN
        PRINT 'ReportServer database is not writable (likely on AG secondary). Skipping SSRS queries.';
    END
END
ELSE
BEGIN
    PRINT 'ReportServer database does not exist on this instance.';
END

------------------------------------------------------------------------
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
    PRINT N'⛔ NO SSIS PACKAGES IN FOLDERS PRESENT';
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
    PRINT N'⛔ NO SSIS PACKAGES IN MSDB';
END
GO
-------------------------------------------------

-----------------------------------------------
--GET SSIS SCALE OUT
---------------------------------------------------
---revised 23/10/25 to remove false positives on standalone
IF EXISTS (
    SELECT 1
    FROM sys.databases
    WHERE name = 'SSISDB' AND state_desc = 'ONLINE'
)
BEGIN
    PRINT N'✅ SSISDB FOUND';

    DECLARE @IsInAG BIT = 0;
    DECLARE @IsPrimaryReplica BIT = 0;

    -- Check if SSISDB is part of an AG
    IF EXISTS (
        SELECT 1
        FROM sys.dm_hadr_database_replica_states AS drs
        JOIN sys.databases AS db ON drs.database_id = db.database_id
        WHERE db.name = 'SSISDB'
    )
    BEGIN
        SET @IsInAG = 1;

        -- Check if current replica is primary
        IF EXISTS (
            SELECT 1
            FROM sys.dm_hadr_database_replica_states AS drs
            JOIN sys.databases AS db ON drs.database_id = db.database_id
            WHERE db.name = 'SSISDB' AND drs.is_primary_replica = 1
        )
        SET @IsPrimaryReplica = 1;
    END
    ELSE
    BEGIN
        -- Not in AG, assume standalone and writable
        SET @IsPrimaryReplica = 1;
    END
    IF @IsPrimaryReplica = 1
    BEGIN
        PRINT N'✅ SSISDB is writable (primary or standalone)';

        BEGIN TRY
            DECLARE @enabled BIT;

            SELECT @enabled = property_value
            FROM SSISDB.catalog.catalog_properties
            WHERE property_name = 'ScaleOutMasterEnabled';

            IF @enabled = 1
                PRINT N'🚀 SSIS SCALE OUT DEPLOYED';
            ELSE
                PRINT N'⛔ NO SSIS SCALE OUT DEPLOYED';
        END TRY
        BEGIN CATCH
            PRINT N'⚠️ Error accessing SSISDB catalog properties';
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT N'🕒 SSISDB is on AG secondary — skipping catalog query';
    END
END
ELSE
BEGIN
    PRINT N'⛔ SSISDB not found';
END
PRINT '---------------------------';

-- SSISDB REPORT
--Adrian Sleigh 15/10/25
-------------------------------------------------
SET NOCOUNT ON
PRINT 'SSISDB REPORT  '+ @@servername + CONVERT(VARCHAR(20),getdate(),120)
PRINT '-------------------------------------------------------'
SELECT 
    SUBSTRING(DB_NAME(database_id),1,20) AS SSISDB_FILES,
    size * 8 / 1024 AS SizeMB,
	SUBSTRING(physical_name,1,90) AS PhysicalName
 FROM sys.master_files
WHERE DB_NAME(database_id) = 'SSISDB';

-- Execution History Summary
-- Check if any packages ran in the last 3 months
IF EXISTS (
    SELECT 1
    FROM SSISDB.catalog.executions
    WHERE start_time > DATEADD(MONTH, -3, GETDATE())
)
BEGIN
    PRINT 'Packages ran in the last 3 months';
    PRINT '---------------------------------';

    SELECT 
        TOP 100 
        SUBSTRING(project_name, 1, 40) AS Project,
        SUBSTRING(package_name, 1, 30) AS PackageName,
        COUNT(*) AS ExecutionCount,
        CONVERT(VARCHAR(20), start_time, 120) AS StartTime,
        AVG(DATEDIFF(SECOND, start_time, end_time)) AS AvgDurationSec
    FROM SSISDB.catalog.executions
    WHERE start_time > DATEADD(MONTH, -3, GETDATE())
    GROUP BY project_name, package_name, start_time
    ORDER BY ExecutionCount DESC;
END
ELSE
BEGIN
    PRINT N'⚠️ No SSISDB packages ran in the last 3 months';
END

-- Retention Policy Check
SELECT
    SUBSTRING(property_name,1,30) AS Property_Name,
    SUBSTRING(property_value,1,10)AS Property_Value
FROM SSISDB.catalog.catalog_properties
WHERE property_name IN ('RETENTION_WINDOW', 'OPERATION_CLEANUP_ENABLED');

-- Orphaned Executions (no logs)
-- Check for orphaned executions (executions with no operation messages)
IF EXISTS (
    SELECT 1
    FROM SSISDB.catalog.executions e
    LEFT JOIN SSISDB.catalog.operation_messages om ON e.execution_id = om.operation_id
    WHERE om.operation_id IS NULL
)
BEGIN
    SELECT 
        'Orphaned Executions found' AS Orphaned_Executions,
        SUBSTRING(e.project_name, 1, 50) AS Project_Name,
        SUBSTRING(e.package_name, 1, 40) AS Package_Name,
		CONVERT(VARCHAR(20),e.start_time,120) AS start_time,
      	CONVERT(VARCHAR(20),e.end_time,120) AS end_time
     
    FROM SSISDB.catalog.executions e
    LEFT JOIN SSISDB.catalog.operation_messages om ON e.execution_id = om.operation_id
    WHERE om.operation_id IS NULL;
END
ELSE
BEGIN
    PRINT 'No SSISDB Orphaned Executions Found';
END

-- Old Execution Data (older than retention window)
-- Summary count

SET NOCOUNT ON
SELECT
    CAST(COUNT(*) AS VARCHAR) + ' packages not run in over 30 days ' AS Message
FROM SSISDB.catalog.executions
WHERE start_time < DATEADD(DAY, -30, GETDATE());

SELECT
    SUBSTRING(package_name, 1, 40) AS Package_Name,
    SUBSTRING(project_name,1,40)AS Project_Name,
    CONVERT(VARCHAR(20),start_time,120) AS start_time,
    CONVERT(VARCHAR(20),end_time,120) AS end_time
FROM SSISDB.catalog.executions
--WHERE start_time < DATEADD(DAY, -30, GETDATE())
ORDER BY start_time;

----------------------------------------------------------------




----------------------------------------------------------------

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
        PRINT N'⛔ NO SSRS DATABASES DISCOVERED';
    END
END TRY
BEGIN CATCH
    PRINT '';
END CATCH
     PRINT '-------------------------------'
SET NOCOUNT ON;

-- Check if current instance is PRIMARY
IF EXISTS (
    SELECT 1
    FROM sys.dm_hadr_availability_replica_states ars
    JOIN sys.availability_replicas ar ON ars.replica_id = ar.replica_id
    WHERE ars.role_desc = 'PRIMARY'
      AND ar.replica_server_name = @@SERVERNAME
)
BEGIN
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
        PRINT N'⛔ NO SSRS DATABASE FOUND. Skipping report analysis.';
    END
END
ELSE
BEGIN
    PRINT N'⛔ Skipping SSRS analysis.';
END

------------------------------------------------------------------
/* =====================================================================
   Detect whether SSAS is being used from the SQL Server Database Engine
   Checks:
     1) Linked servers using MSOLAP (SSAS provider)
     2) SQL Agent jobs with Analysis Services steps (ANALYSISCOMMAND/QUERY)
     3) SSIS packages referencing SSAS (MSDB legacy store)
     4) SSIS packages referencing SSAS (SSISDB project deployment)
        - AG-aware: handles SSISDB when this replica is secondary
   Output:
     - Detail rows for each category (if found)
     - A summary status at the end
   Notes:
     - SSAS usage can also occur externally (e.g., Power BI/Excel) with no traces here.
   ===================================================================== */
SET NOCOUNT ON;

-- =========================================================
-- Prep: temp tables for results
-- =========================================================
IF OBJECT_ID('tempdb..#LinkedServers') IS NOT NULL DROP TABLE #LinkedServers;
IF OBJECT_ID('tempdb..#AgentJobs')    IS NOT NULL DROP TABLE #AgentJobs;
IF OBJECT_ID('tempdb..#SSIS_MSDB')    IS NOT NULL DROP TABLE #SSIS_MSDB;
IF OBJECT_ID('tempdb..#SSIS_SSISDB')  IS NOT NULL DROP TABLE #SSIS_SSISDB;

CREATE TABLE #LinkedServers
(
    name         sysname,
    provider     nvarchar(128),
    data_source  nvarchar(4000),
    product      nvarchar(128),
    is_linked    bit
);

CREATE TABLE #AgentJobs
(
    JobName   sysname,
    StepName  sysname,
    Subsystem nvarchar(50)
);

CREATE TABLE #SSIS_MSDB
(
    FolderName  sysname,
    PackageName sysname,
    Location    nvarchar(20)  -- 'MSDB'
);

CREATE TABLE #SSIS_SSISDB
(
    FolderName   nvarchar(128),
    ProjectName  nvarchar(128),
    PackageName  nvarchar(260),
    Location     nvarchar(20)  -- 'SSISDB'
);

-- Optional: avoid blocking when scanning metadata
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT N'CHECKING FOR SSAS CONNECTIVITY....'
-- =========================================================
-- 1) Linked servers using MSOLAP (SSAS OLE DB provider)
-- =========================================================
BEGIN TRY
    INSERT INTO #LinkedServers (name, provider, data_source, product, is_linked)
    SELECT s.name, s.provider, s.data_source, s.product, s.is_linked
    FROM sys.servers AS s
    WHERE s.is_linked = 1
      AND s.provider LIKE N'MSOLAP%'; -- e.g., MSOLAP, MSOLAP.8, MSOLAP.9, etc.
END TRY
BEGIN CATCH
    PRINT N'⚠️ Unable to query sys.servers for linked servers (permissions?).';
END CATCH;

-- =========================================================
-- 2) SQL Agent jobs with Analysis Services subsystems
--    ANALYSISCOMMAND (XMLA/DDL) / ANALYSISQUERY (MDX/DMX)
-- =========================================================
BEGIN TRY
    IF DB_ID(N'msdb') IS NOT NULL
    BEGIN
        INSERT INTO #AgentJobs (JobName, StepName, Subsystem)
        SELECT j.name, s.step_name, s.subsystem
        FROM msdb.dbo.sysjobsteps AS s
        JOIN msdb.dbo.sysjobs AS j
          ON j.job_id = s.job_id
        WHERE s.subsystem IN (N'ANALYSISCOMMAND', N'ANALYSISQUERY');
    END
END TRY
BEGIN CATCH
    PRINT N'⚠️ Unable to query msdb SQL Agent metadata (permissions?).';
END CATCH;

-- =========================================================
-- 3) SSIS packages (legacy MSDB store) referencing SSAS
--    Look for 'AnalysisServices' or 'MSOLAP' in package XML
-- =========================================================
BEGIN TRY
    IF OBJECT_ID(N'msdb.dbo.sysssispackages') IS NOT NULL
    BEGIN
        INSERT INTO #SSIS_MSDB (FolderName, PackageName, Location)
        SELECT f.foldername, p.name, N'MSDB'
        FROM msdb.dbo.sysssispackages AS p
        JOIN msdb.dbo.sysssispackagefolders AS f
          ON p.folderid = f.folderid
        WHERE TRY_CONVERT(xml, CAST(p.packagedata AS varbinary(max))) IS NOT NULL
          AND (
                CONVERT(nvarchar(max), TRY_CONVERT(xml, CAST(p.packagedata AS varbinary(max)))) LIKE N'%AnalysisServices%'
             OR CONVERT(nvarchar(max), TRY_CONVERT(xml, CAST(p.packagedata AS varbinary(max)))) LIKE N'%MSOLAP%'
          );
    END
END TRY
BEGIN CATCH
    PRINT N'⚠️ Unable to scan MSDB-stored SSIS packages (permissions or SSIS not installed).';
END CATCH;

-- =========================================================
-- 4) SSIS packages (SSISDB project deployment) referencing SSAS
--    AG-aware: Only scan if SSISDB is ONLINE here (primary or readable secondary)
-- =========================================================
DECLARE 
    @hasSSISDB bit           = CASE WHEN DB_ID(N'SSISDB') IS NOT NULL THEN 1 ELSE 0 END,
    @ssisState sysname       = NULL,
    @ssisReadOnly bit        = NULL,
    @isPrimaryReplica bit    = NULL;

IF @hasSSISDB = 1
BEGIN
    SELECT 
        @ssisState   = d.state_desc,
        @ssisReadOnly = d.is_read_only
    FROM sys.databases AS d
    WHERE d.name = N'SSISDB';

    -- If HADR is enabled and SSISDB participates, this returns 1 (primary) or 0 (secondary).
    -- If not in AG, it may return NULL; we treat NULL as "not in AG".
    BEGIN TRY
        SELECT @isPrimaryReplica = TRY_CONVERT(bit, sys.fn_hadr_is_primary_replica(N'SSISDB'));
    END TRY
    BEGIN CATCH
        SET @isPrimaryReplica = NULL; -- function may not be available or AG not enabled
    END CATCH;


	IF @ssisState = N'ONLINE' AND @ssisReadOnly = 0 AND (@isPrimaryReplica = 1 OR @isPrimaryReplica IS NULL)

    BEGIN
        -- ONLINE covers both primary (read-write) and readable secondary (read-only).
        BEGIN TRY
            ;WITH pkg AS
            (
                SELECT
                    f.name   AS FolderName,
                    prj.name AS ProjectName,
                    p.name   AS PackageName,
                    p.package_data
                FROM SSISDB.internal.packages AS p
                JOIN SSISDB.internal.projects AS prj
                  ON p.project_id = prj.project_id
                JOIN SSISDB.internal.folders AS f
                  ON prj.folder_id = f.folder_id
            )
            INSERT INTO #SSIS_SSISDB (FolderName, ProjectName, PackageName, Location)
            SELECT
                pkg.FolderName, pkg.ProjectName, pkg.PackageName, N'SSISDB'
            FROM pkg
            CROSS APPLY (SELECT TRY_CONVERT(xml, pkg.package_data) AS pkg_xml) AS x
            WHERE x.pkg_xml IS NOT NULL
              AND (
                    CONVERT(nvarchar(max), x.pkg_xml) LIKE N'%AnalysisServices%'
                 OR CONVERT(nvarchar(max), x.pkg_xml) LIKE N'%MSOLAP%'
              );
        END TRY
        BEGIN CATCH
            PRINT N'⚠️ Unable to scan SSISDB packages (permissions? role membership in SSISDB needed).';
        END CATCH;
    END
    ELSE
    BEGIN
        PRINT N'⚠️ SSISDB exists but is not ONLINE on this replica (state: ' + COALESCE(@ssisState, N'UNKNOWN') + N'). Skipping SSISDB scan.';
    END
END
ELSE
BEGIN
    PRINT N'⛔ SSISDB database not present on this instance.';
END

-- =========================================================
-- Detail outputs
-- =========================================================
IF EXISTS (SELECT 1 FROM #LinkedServers)
BEGIN
    PRINT N'🔗 SSAS Linked Servers (MSOLAP) found:';
    SELECT name, provider, data_source, product
    FROM #LinkedServers
    ORDER BY name;
END
ELSE
BEGIN
    PRINT N'⛔ No MSOLAP linked servers found.';
END

IF EXISTS (SELECT 1 FROM #AgentJobs)
BEGIN
    PRINT N'🗓️ SQL Agent jobs with Analysis Services steps found:';
    SELECT JobName, StepName, Subsystem
    FROM #AgentJobs
    ORDER BY JobName, StepName;
END
ELSE
BEGIN
    PRINT N'⛔ No SQL Agent jobs with Analysis Services steps found.';
END
IF EXISTS (SELECT 1 FROM #SSIS_MSDB)
BEGIN
    PRINT N'📦 SSIS (MSDB) packages referencing SSAS found:';
    SELECT FolderName, PackageName, Location
    FROM #SSIS_MSDB
    ORDER BY FolderName, PackageName;
END
ELSE
BEGIN
    PRINT N'⛔ No SSIS (MSDB) packages referencing SSAS found.';
END

IF EXISTS (SELECT 1 FROM #SSIS_SSISDB)
BEGIN
    DECLARE @roleNote nvarchar(200) = N'';
    IF @hasSSISDB = 1
    BEGIN
        IF @ssisReadOnly = 1 SET @roleNote = N' (readable secondary)';
        ELSE IF @ssisReadOnly = 0 SET @roleNote = N' (primary replica)';
    END

    PRINT N'📦 SSIS (SSISDB) packages referencing SSAS found' + @roleNote + N':';
    SELECT FolderName, ProjectName, PackageName, Location
    FROM #SSIS_SSISDB
    ORDER BY FolderName, ProjectName, PackageName;
END
ELSE
BEGIN
    PRINT N'⛔ No SSIS (SSISDB) packages referencing SSAS found (or SSISDB not readable here).';
END

-- =========================================================
-- Summary
-- =========================================================
DECLARE 
    @cntLinked   int = (SELECT COUNT(*) FROM #LinkedServers),
    @cntJobs     int = (SELECT COUNT(*) FROM #AgentJobs),
    @cntMSDB     int = (SELECT COUNT(*) FROM #SSIS_MSDB),
    @cntSSISDB   int = (SELECT COUNT(*) FROM #SSIS_SSISDB);

SELECT N'Linked Servers (MSOLAP)' AS [Check],
       @cntLinked                 AS [Count],
       CASE WHEN @cntLinked > 0 THEN N'Found' ELSE N'Not Found' END AS [Status]
UNION ALL
SELECT N'SQL Agent (ANALYSIS* steps)',
       @cntJobs,
       CASE WHEN @cntJobs > 0 THEN N'Found' ELSE N'Not Found' END
UNION ALL
SELECT N'SSIS (MSDB) packages -> SSAS',
       @cntMSDB,
       CASE WHEN @cntMSDB > 0 THEN N'Found' ELSE N'Not Found' END
UNION ALL
SELECT N'SSIS (SSISDB) packages -> SSAS',
       @cntSSISDB,
       CASE WHEN @cntSSISDB > 0 THEN N'Found' ELSE N'Not Found' END;

-- Cleanup (optional)
DROP TABLE IF EXISTS #LinkedServers;
DROP TABLE IF EXISTS #AgentJobs;
DROP TABLE IF EXISTS #SSIS_MSDB;
DROP TABLE IF EXISTS #SSIS_SSISDB;

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

---------------------------------------------------
--Databases with wrong owner found
---------------------------------------------------
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
USE MSDB;
GO

SELECT 
    SUBSTRING([database_name], 1, 50) AS 'DB',
    [backup_start_date] AS 'backup start',
    '' AS '-',
    [backup_finish_date] AS 'backup finish',
    '' AS '-',
    LEFT(
        CAST(DATEDIFF(SECOND, backup_start_date, backup_finish_date) / 3600 AS VARCHAR) + ' hrs ' +
        CAST((DATEDIFF(SECOND, backup_start_date, backup_finish_date) % 3600) / 60 AS VARCHAR) + ' mins ' +
        CAST(DATEDIFF(SECOND, backup_start_date, backup_finish_date) % 60 AS VARCHAR) + ' secs',
        25
    ) AS Time_Taken,
    SUBSTRING([physical_device_name], 1, 90) AS BackupLocation,
    [type],
    SUBSTRING(CAST([backup_size] AS VARCHAR(20)), 1, 20) AS 'Size in KB',
    SUBSTRING([recovery_model], 1, 10) AS 'Model',
    [is_snapshot] AS 'Snapshot',
    [is_copy_only],
    SUBSTRING([name], 1, 40) AS 'backup utility',
    SUBSTRING([user_name], 1, 26) AS 'utility account'
FROM 
    backupset 
JOIN 
    msdb.dbo.backupmediafamily ON backupset.media_set_id = backupmediafamily.media_set_id
WHERE 
    backup_finish_date >= DATEADD(week, -1, GETDATE()) 
    AND type LIKE 'D'
                  ORDER BY database_name ,backup_start_date DESC
--------------------------------------------------------------------------------------------
PRINT N'📊 REPORT HAS NOW COMPLETED. RAN  ON ----> ' + CAST(getdate()AS VARCHAR(20))
---------REPORT END---------------------------------------




















