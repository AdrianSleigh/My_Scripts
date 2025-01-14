----SCOM QUERIES
--Whats using the space in db

SELECT TOP 1000 
a2.name AS 'Tablename', 
CAST((a1.reserved + ISNULL(a4.reserved,0))* 8/1024.0 AS DECIMAL(10, 0)) AS 'TotalSpace(MB)', 
CAST(a1.data * 8/1024.0 AS DECIMAL(10, 0)) AS 'DataSize(MB)', 
CAST((CASE WHEN (a1.used + ISNULL(a4.used,0)) > a1.data THEN (a1.used + ISNULL(a4.used,0)) - a1.data ELSE 0 END) * 8/1024.0 AS DECIMAL(10, 0)) AS 'IndexSize(MB)', 
CAST((CASE WHEN (a1.reserved + ISNULL(a4.reserved,0)) > a1.used THEN (a1.reserved + ISNULL(a4.reserved,0)) - a1.used ELSE 0 END) * 8/1024.0 AS DECIMAL(10, 0)) AS 'Unused(MB)',
a1.rows as 'RowCount', 
(row_number() over(order by (a1.reserved + ISNULL(a4.reserved,0)) desc))%2 as l1, 
a3.name AS 'Schema' 
FROM (SELECT ps.object_id, SUM (CASE WHEN (ps.index_id < 2) THEN row_count ELSE 0 END) AS [rows], 
SUM (ps.reserved_page_count) AS reserved, 
SUM (CASE WHEN (ps.index_id < 2) THEN (ps.in_row_data_page_count + ps.lob_used_page_count + ps.row_overflow_used_page_count) 
ELSE (ps.lob_used_page_count + ps.row_overflow_used_page_count) END ) AS data, 
SUM (ps.used_page_count) AS used 
FROM sys.dm_db_partition_stats ps 
GROUP BY ps.object_id) AS a1 
LEFT OUTER JOIN (SELECT it.parent_id, SUM(ps.reserved_page_count) AS reserved, 
SUM(ps.used_page_count) AS used 
FROM sys.dm_db_partition_stats ps 
INNER JOIN sys.internal_tables it ON (it.object_id = ps.object_id) 
WHERE it.internal_type IN (202,204) 
GROUP BY it.parent_id) AS a4 ON (a4.parent_id = a1.object_id) 
INNER JOIN sys.all_objects a2  ON ( a1.object_id = a2.object_id ) 
INNER JOIN sys.schemas a3 ON (a2.schema_id = a3.schema_id)
--END OF QUERY
----------------------------------------------------------------
--Number of console Alerts per Day:

SELECT CONVERT(VARCHAR(20), TimeAdded, 102) AS DayAdded, COUNT(*) AS NumAlertsPerDay 
FROM Alert WITH (NOLOCK) 
WHERE TimeRaised is not NULL 
GROUP BY CONVERT(VARCHAR(20), TimeAdded, 102) 
ORDER BY DayAdded DESC
----------------------------------------------------------------
--Number of console Alerts per Day:

SELECT CONVERT(VARCHAR(20), TimeAdded, 102) AS DayAdded, COUNT(*) AS NumAlertsPerDay 
FROM Alert WITH (NOLOCK) 
WHERE TimeRaised is not NULL 
GROUP BY CONVERT(VARCHAR(20), TimeAdded, 102) 
ORDER BY DayAdded DESC
-----------------------------------------------------------------
--Top 20 Alerts in an Operational Database, by Repeat Count

SELECT TOP 20 SUM(RepeatCount+1) AS RepeatCount,
 AlertStringName as 'AlertName',
 AlertStringDescription as 'Description',
 Name,
 MonitoringRuleId 
FROM Alertview WITH (NOLOCK) 
WHERE Timeraised is not NULL 
GROUP BY AlertStringName, AlertStringDescription, Name, MonitoringRuleId 
ORDER BY RepeatCount DESC
-----------------------------------------------------------------
--Top 20 Objects generating the most Alerts in an Operational Database, by Repeat Count

SELECT TOP 20 SUM(RepeatCount+1) AS RepeatCount,
 MonitoringObjectPath AS 'Path'
FROM Alertview WITH (NOLOCK) 
WHERE Timeraised is not NULL 
GROUP BY MonitoringObjectPath 
ORDER BY RepeatCount DESC
-----------------------------------------------------------------
--Top 20 Objects generating the most Alerts in an Operational Database, by Alert Count

SELECT TOP 20 SUM(1) AS AlertCount,
 MonitoringObjectPath AS 'Path'
FROM Alertview WITH (NOLOCK) 
WHERE TimeRaised is not NULL 
GROUP BY MonitoringObjectPath
ORDER BY AlertCount DESC
-----------------------------------------------------------------
--Number of console Alerts per Day by Resolution State:

SELECT 
CASE WHEN(GROUPING(CONVERT(VARCHAR(20), TimeAdded, 102)) = 1) 
  THEN 'All Days' ELSE CONVERT(VARCHAR(20), TimeAdded, 102) 
  END AS [Date], 
CASE WHEN(GROUPING(ResolutionState) = 1) 
  THEN 'All Resolution States' ELSE CAST(ResolutionState AS VARCHAR(5)) 
  END AS [ResolutionState], 
COUNT(*) AS NumAlerts 
FROM Alert WITH (NOLOCK) 
WHERE TimeRaised is not NULL 
GROUP BY CONVERT(VARCHAR(20), TimeAdded, 102), ResolutionState WITH ROLLUP 
ORDER BY DATE DESC
-----------------------------------------------------------------
----EVENTS------------------------------
----------------------------------------
--All Events by count by day, with total for entire database

SELECT CASE WHEN(GROUPING(CONVERT(VARCHAR(20), TimeAdded, 102)) = 1) 
THEN 'All Days' 
ELSE CONVERT(VARCHAR(20), TimeAdded, 102) END AS DayAdded, 
COUNT(*) AS EventsPerDay 
FROM EventAllView 
GROUP BY CONVERT(VARCHAR(20), TimeAdded, 102) WITH ROLLUP 
ORDER BY DayAdded DESC
-----------------------------------------------------------------
--Most common events by event number and event source

SELECT top 20 Number as EventID, 
 COUNT(*) AS TotalEvents,
 Publishername as EventSource 
FROM EventAllView eav with (nolock) 
GROUP BY Number, Publishername 
ORDER BY TotalEvents DESC
-----------------------------------------------------------------
--Computers generating the most events

SELECT top 20 LoggingComputer as ComputerName,
 COUNT(*) AS TotalEvents 
FROM EventallView with (NOLOCK) 
GROUP BY LoggingComputer 
ORDER BY TotalEvents DESC
----------------------------------------------------------------
-----PERFORMANCE-----------------------
----------------------------------------------------------------
--Performance insertions per day: 

SELECT CASE WHEN(GROUPING(CONVERT(VARCHAR(20), TimeSampled, 102)) = 1) 
 THEN 'All Days' 
 ELSE CONVERT(VARCHAR(20), TimeSampled, 102) 
 END AS DaySampled, COUNT(*) AS PerfInsertPerDay 
FROM PerformanceDataAllView with (NOLOCK) 
GROUP BY CONVERT(VARCHAR(20), TimeSampled, 102) WITH ROLLUP 
ORDER BY DaySampled DESC
----------------------------------------------------------------
--Top 20 performance insertions by perf object and counter name: 

SELECT TOP 20 pcv.ObjectName,
 pcv.CounterName,
 COUNT (pcv.countername) AS Total 
FROM performancedataallview AS pdv, performancecounterview AS pcv 
WHERE (pdv.performancesourceinternalid = pcv.performancesourceinternalid) 
GROUP BY pcv.objectname, pcv.countername 
ORDER BY COUNT (pcv.countername) DESC
----------------------------------------------------------------
--To view all performance insertions for a given computer:

select Distinct Path,
 ObjectName,
  CounterName,
  InstanceName 
from PerformanceDataAllView pdv with (NOLOCK) 
inner join PerformanceCounterView pcv on pdv.performancesourceinternalid = pcv.performancesourceinternalid 
inner join BaseManagedEntity bme on pcv.ManagedEntityId = bme.BaseManagedEntityId 
where path = 'sql2a.opsmgr.net'
order by objectname, countername, InstanceName
-------------------------------------------------------------
--To pull all perf data for a given computer, object, counter, and instance:

select Path,
 ObjectName,
 CounterName,
 InstanceName,
 SampleValue,
 TimeSampled 
from PerformanceDataAllView pdv with (NOLOCK) 
inner join PerformanceCounterView pcv on pdv.performancesourceinternalid = pcv.performancesourceinternalid 
inner join BaseManagedEntity bme on pcv.ManagedEntityId = bme.BaseManagedEntityId 
where path = 'sql2a.opsmgr.net' AND 
 objectname = 'LogicalDisk' AND 
 countername = 'Free Megabytes' 
order by timesampled DESC
--------------------------------------------------------------

----STATE--------------------------------------
-----------------------------------------------
--To find out how old your StateChange data is:

declare @statedaystokeep INT 
SELECT @statedaystokeep = DaysToKeep from PartitionAndGroomingSettings 
WHERE ObjectName = 'StateChangeEvent'
SELECT COUNT(*) as 'Total StateChanges', 
count(CASE WHEN sce.TimeGenerated > dateadd(dd,-@statedaystokeep,getutcdate()) THEN sce.TimeGenerated ELSE NULL END) as 'within grooming retention', 
count(CASE WHEN sce.TimeGenerated < dateadd(dd,-@statedaystokeep,getutcdate()) THEN sce.TimeGenerated ELSE NULL END) as '> grooming retention', 
count(CASE WHEN sce.TimeGenerated < dateadd(dd,-30,getutcdate()) THEN sce.TimeGenerated ELSE NULL END) as '> 30 days', 
count(CASE WHEN sce.TimeGenerated < dateadd(dd,-90,getutcdate()) THEN sce.TimeGenerated ELSE NULL END) as '> 90 days', 
count(CASE WHEN sce.TimeGenerated < dateadd(dd,-365,getutcdate()) THEN sce.TimeGenerated ELSE NULL END) as '> 365 days' 
from StateChangeEvent sce
-------------------------------------------------------------
USE [OperationsManager] 
GO 
SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 
BEGIN
    SET NOCOUNT ON
    DECLARE @Err int 
    DECLARE @Ret int 
    DECLARE @DaysToKeep tinyint 
    DECLARE @GroomingThresholdLocal datetime 
    DECLARE @GroomingThresholdUTC datetime 
    DECLARE @TimeGroomingRan datetime 
    DECLARE @MaxTimeGroomed datetime 
    DECLARE @RowCount int 
    SET @TimeGroomingRan = getutcdate()
    SELECT @GroomingThresholdLocal = dbo.fn_GroomingThreshold(DaysToKeep, getdate()) 
    FROM dbo.PartitionAndGroomingSettings 
    WHERE ObjectName = 'StateChangeEvent'
    EXEC dbo.p_ConvertLocalTimeToUTC @GroomingThresholdLocal, @GroomingThresholdUTC OUT 
    SET @Err = @@ERROR
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END
    SET @RowCount = 1  
    -- This is to update the settings table 
    -- with the max groomed data 
    SELECT @MaxTimeGroomed = MAX(TimeGenerated) 
    FROM dbo.StateChangeEvent 
    WHERE TimeGenerated < @GroomingThresholdUTC
    IF @MaxTimeGroomed IS NULL 
        GOTO Success_Exit
    -- Instead of the FK DELETE CASCADE handling the deletion of the rows from 
    -- the MJS table, do it explicitly. Performance is much better this way. 
    DELETE MJS 
    FROM dbo.MonitoringJobStatus MJS 
    JOIN dbo.StateChangeEvent SCE 
        ON SCE.StateChangeEventId = MJS.StateChangeEventId 
    JOIN dbo.State S WITH(NOLOCK) 
        ON SCE.[StateId] = S.[StateId] 
    WHERE SCE.TimeGenerated < @GroomingThresholdUTC 
    AND S.[HealthState] in (0,1,2,3)
    SELECT @Err = @@ERROR 
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END
    WHILE (@RowCount > 0) 
    BEGIN 
        -- Delete StateChangeEvents that are older than @GroomingThresholdUTC 
        -- We are doing this in chunks in separate transactions on 
        -- purpose: to avoid the transaction log to grow too large. 
        DELETE TOP (10000) SCE 
        FROM dbo.StateChangeEvent SCE 
        JOIN dbo.State S WITH(NOLOCK) 
            ON SCE.[StateId] = S.[StateId] 
        WHERE TimeGenerated < @GroomingThresholdUTC 
        AND S.[HealthState] in (0,1,2,3)
        SELECT @Err = @@ERROR, @RowCount = @@ROWCOUNT
        IF (@Err <> 0) 
        BEGIN 
            GOTO Error_Exit 
        END 
    END   
    UPDATE dbo.PartitionAndGroomingSettings 
    SET GroomingRunTime = @TimeGroomingRan, 
        DataGroomedMaxTime = @MaxTimeGroomed 
    WHERE ObjectName = 'StateChangeEvent'
    SELECT @Err = @@ERROR, @RowCount = @@ROWCOUNT
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END  
Success_Exit: 
Error_Exit:    
END
---------------------------------------------------------------------------
USE [OperationsManager] 
GO 
SET ANSI_NULLS ON 
GO 
SET QUOTED_IDENTIFIER ON 
GO 
BEGIN
    SET NOCOUNT ON
    DECLARE @Err int 
    DECLARE @Ret int 
    DECLARE @DaysToKeep tinyint 
    DECLARE @GroomingThresholdLocal datetime 
    DECLARE @GroomingThresholdUTC datetime 
    DECLARE @TimeGroomingRan datetime 
    DECLARE @MaxTimeGroomed datetime 
    DECLARE @RowCount int 
    SET @TimeGroomingRan = getutcdate()
    SELECT @GroomingThresholdLocal = dbo.fn_GroomingThreshold(DaysToKeep, getdate()) 
    FROM dbo.PartitionAndGroomingSettings 
    WHERE ObjectName = 'StateChangeEvent'
    EXEC dbo.p_ConvertLocalTimeToUTC @GroomingThresholdLocal, @GroomingThresholdUTC OUT 
    SET @Err = @@ERROR
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END
    SET @RowCount = 1  
    -- This is to update the settings table 
    -- with the max groomed data 
    SELECT @MaxTimeGroomed = MAX(TimeGenerated) 
    FROM dbo.StateChangeEvent 
    WHERE TimeGenerated < @GroomingThresholdUTC
    IF @MaxTimeGroomed IS NULL 
        GOTO Success_Exit
    -- Instead of the FK DELETE CASCADE handling the deletion of the rows from 
    -- the MJS table, do it explicitly. Performance is much better this way. 
    DELETE MJS 
    FROM dbo.MonitoringJobStatus MJS 
    JOIN dbo.StateChangeEvent SCE 
        ON SCE.StateChangeEventId = MJS.StateChangeEventId 
    JOIN dbo.State S WITH(NOLOCK) 
        ON SCE.[StateId] = S.[StateId] 
    WHERE SCE.TimeGenerated < @GroomingThresholdUTC 
    AND S.[HealthState] in (0,1,2,3)
    SELECT @Err = @@ERROR 
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END
    WHILE (@RowCount > 0) 
    BEGIN 
        -- Delete StateChangeEvents that are older than @GroomingThresholdUTC 
        -- We are doing this in chunks in separate transactions on 
        -- purpose: to avoid the transaction log to grow too large. 
        DELETE TOP (10000) SCE 
        FROM dbo.StateChangeEvent SCE 
        JOIN dbo.State S WITH(NOLOCK) 
            ON SCE.[StateId] = S.[StateId] 
        WHERE TimeGenerated < @GroomingThresholdUTC 
        AND S.[HealthState] in (0,1,2,3)
        SELECT @Err = @@ERROR, @RowCount = @@ROWCOUNT
        IF (@Err <> 0) 
        BEGIN 
            GOTO Error_Exit 
        END 
    END   
    UPDATE dbo.PartitionAndGroomingSettings 
    SET GroomingRunTime = @TimeGroomingRan, 
        DataGroomedMaxTime = @MaxTimeGroomed 
    WHERE ObjectName = 'StateChangeEvent'
    SELECT @Err = @@ERROR, @RowCount = @@ROWCOUNT
    IF (@Err <> 0) 
    BEGIN 
        GOTO Error_Exit 
    END  
Success_Exit: 
Error_Exit:    
END
----------------------------------------------------------------------------
--State changes per day: 

SELECT CASE WHEN(GROUPING(CONVERT(VARCHAR(20), TimeGenerated, 102)) = 1) 
THEN 'All Days' ELSE CONVERT(VARCHAR(20), TimeGenerated, 102) 
END AS DayGenerated, COUNT(*) AS StateChangesPerDay 
FROM StateChangeEvent WITH (NOLOCK) 
GROUP BY CONVERT(VARCHAR(20), TimeGenerated, 102) WITH ROLLUP 
ORDER BY DayGenerated DESC
--------------------------------------------------------------------------
--Noisiest monitors changing state in the database in the last 7 days:

SELECT DISTINCT TOP 50 count(sce.StateId) as StateChanges, 
  m.DisplayName as MonitorName, 
  m.Name as MonitorId, 
  mt.typename AS TargetClass 
FROM StateChangeEvent sce with (nolock) 
join state s with (nolock) on sce.StateId = s.StateId 
join monitorview m with (nolock) on s.MonitorId = m.Id 
join managedtype mt with (nolock) on m.TargetMonitoringClassId = mt.ManagedTypeId 
where m.IsUnitMonitor = 1 
  -- Scoped to within last 7 days 
AND sce.TimeGenerated > dateadd(dd,-7,getutcdate()) 
group by m.DisplayName, m.Name,mt.typename 
order by StateChanges desc
----------------------------------------------------------------------------
--Noisiest Monitor in the database – PER Object/Computer in the last 7 days:

select distinct top 50 count(sce.StateId) as NumStateChanges, 
bme.DisplayName AS ObjectName, 
bme.Path, 
m.DisplayName as MonitorDisplayName, 
m.Name as MonitorIdName, 
mt.typename AS TargetClass 
from StateChangeEvent sce with (nolock) 
join state s with (nolock) on sce.StateId = s.StateId 
join BaseManagedEntity bme with (nolock) on s.BasemanagedEntityId = bme.BasemanagedEntityId 
join MonitorView m with (nolock) on s.MonitorId = m.Id 
join managedtype mt with (nolock) on m.TargetMonitoringClassId = mt.ManagedTypeId 
where m.IsUnitMonitor = 1 
   -- Scoped to specific Monitor (remove the "--" below): 
   -- AND m.MonitorName like ('%HealthService%') 
   -- Scoped to specific Computer (remove the "--" below): 
   -- AND bme.Path like ('%sql%') 
   -- Scoped to within last 7 days 
AND sce.TimeGenerated > dateadd(dd,-7,getutcdate()) 
group by s.BasemanagedEntityId,bme.DisplayName,bme.Path,m.DisplayName,m.Name,mt.typename 
order by NumStateChanges desc
----------------------------------------------------------------------------
-- Monitors with the most instances of critical state
SELECT 
 count(*) as 'MonitorCount',
mv.DisplayName AS 'MonitorDisplayName',
mv.Name AS 'MonitorName'
FROM State s
JOIN MonitorView mv ON mv.Id = s.MonitorId
WHERE s.HealthState = 3
AND mv.IsUnitMonitor = 1
--ORDER BY mv.DisplayName
GROUP BY mv.Name,mv.DisplayName
ORDER by count(*) DESC
---------------------------------------------------------------------------
--List of all monitors in a critical state

SELECT 
mv.DisplayName AS 'MonitorDisplayName',
mv.Name AS 'MonitorName',
bme.Path,
bme.DisplayName,
bme.FullName AS 'Target',
s.LastModified AS 'StateLastModified'
FROM State s
JOIN BaseManagedEntity bme ON s.BaseManagedEntityId = bme.BaseManagedEntityId
JOIN MonitorView mv ON mv.Id = s.MonitorId
WHERE s.HealthState = 3
AND mv.IsUnitMonitor = 1
ORDER BY mv.DisplayName
--------------------------------------------------------------------------
----MANAGEMENT PACK INFO
----------------------------------------------------------
----------------------------------------------------------
--To find a common rule name given a Rule ID name:
SELECT DisplayName from RuleView 
where name = 'Microsoft.SystemCenter.GenericNTPerfMapperModule.FailedExecution.Alert' 

--Rules per MP:
SELECT mp.MPName, COUNT(*) As RulesPerMP 
FROM Rules r 
INNER JOIN ManagementPack mp ON mp.ManagementPackID = r.ManagementPackID 
GROUP BY mp.MPName 
ORDER BY RulesPerMP DESC

--Rules per MP by category:
SELECT mp.MPName, r.RuleCategory, COUNT(*) As RulesPerMPPerCategory 
FROM Rules r 
INNER JOIN ManagementPack mp ON mp.ManagementPackID = r.ManagementPackID 
GROUP BY mp.MPName, r.RuleCategory 
ORDER BY RulesPerMPPerCategory DESC 

--To find all rules per MP with a given alert severity:
declare @mpid as varchar(50) 
select @mpid= managementpackid 
  from managementpack 
  where mpName='Microsoft.SystemCenter.2007' 
select rl.rulename,rl.ruleid,md.modulename 
  from rules rl, module md 
  where md.managementpackid = @mpid 
  and rl.ruleid=md.parentid 
  and moduleconfiguration like '%<Severity>2%'

--Rules are stored in a table named Rules. This table has columns linking rules to classes and Management Packs. 
--To find all rules in a Management Pack use the following query and substitute in the required Management Pack name:
SELECT * 
FROM Rules 
WHERE ManagementPackID = (SELECT ManagementPackID from ManagementPack WHERE MPName = 'Microsoft.SystemCenter.2007') 

--To find all rules targeted at a given class use the following query and substitute in the required class name:
SELECT * FROM Rules WHERE TargetManagedEntityType = (SELECT ManagedTypeId FROM ManagedType WHERE TypeName = 'Microsoft.Windows.Computer') 

--Rules by Class targeted and enabled by default excluding perf collection and discovery rules
SELECT mtv.Name AS 'ClassName', mtv.DisplayName, COUNT(*) AS 'COUNT'
FROM RuleView rv
JOIN ManagedTypeView mtv ON rv.TargetMonitoringClassId = mtv.Id
WHERE mtv.LanguageCode = 'ENU'
AND rv.LanguageCode = 'ENU'
AND rv.Enabled NOT IN (0)
AND rv.Category NOT IN ('PerformanceCollection','Discovery')
GROUP BY mtv.Name, mtv.DisplayName
ORDER BY COUNT DESC
------------------------------------------------------------------------
--Monitors Per MP:
SELECT mp.MPName, COUNT(*) As MonitorsPerMPPerCategory 
FROM Monitor m 
INNER JOIN ManagementPack mp ON mp.ManagementPackID = m.ManagementPackID 
GROUP BY mp.MPName 
ORDER BY COUNT(*) Desc

--To find your Monitor by common name:
select * from Monitor m 
Inner join LocalizedText LT on LT.ElementName = m.MonitorName 
where LTValue = ‘Monitor Common Name’

--To find your Monitor by ID name:
select * from Monitor m 
Inner join LocalizedText LT on LT.ElementName = m.MonitorName 
where m.monitorname = 'your Monitor ID name'

--To find all monitors targeted at a specific class:
SELECT * FROM monitor WHERE TargetManagedEntityType = (SELECT ManagedTypeId FROM ManagedType WHERE TypeName = 'Microsoft.Windows.Computer')

--Unit Monitors by Class targeted that are configured to alert and monitor enabled by default
SELECT mtv.Name AS 'ClassName', mtv.DisplayName, COUNT(*) AS 'COUNT'
FROM MonitorView mv
JOIN ManagedTypeView mtv ON mv.TargetMonitoringClassId = mtv.Id
WHERE mtv.LanguageCode = 'ENU'
AND mv.LanguageCode = 'ENU'
AND mv.IsUnitMonitor = 1
AND mv.AlertMessage IS NOT NULL
AND mv.Enabled NOT IN (0)
GROUP BY mtv.Name, mtv.DisplayName
ORDER BY COUNT DESC
---------------------------------------------------------------------
--To find all members of a given group (change the group name below):
select TargetObjectDisplayName as 'Group Members' 
from RelationshipGenericView 
where isDeleted=0 
AND SourceObjectDisplayName = 'All Windows Computers' 
ORDER BY TargetObjectDisplayName

--Find find the entity data on all members of a given group (change the group name below):
SELECT bme.* 
FROM BaseManagedEntity bme 
INNER JOIN RelationshipGenericView rgv WITH(NOLOCK) ON bme.basemanagedentityid = rgv.TargetObjectId 
WHERE bme.IsDeleted = '0' 
AND rgv.SourceObjectDisplayName = 'All Windows Computers' 
ORDER BY bme.displayname

--To find all groups for a given computer/object (change “computername” in the query below):
SELECT SourceObjectDisplayName AS 'Group' 
FROM RelationshipGenericView 
WHERE TargetObjectDisplayName like ('%sql2a.opsmgr.net%') 
AND (SourceObjectDisplayName IN 
(SELECT ManagedEntityGenericView.DisplayName 
FROM ManagedEntityGenericView INNER JOIN 
(SELECT     BaseManagedEntityId 
FROM          BaseManagedEntity WITH (NOLOCK) 
WHERE      (BaseManagedEntityId = TopLevelHostEntityId) AND (BaseManagedEntityId NOT IN 
(SELECT     R.TargetEntityId 
FROM          Relationship AS R WITH (NOLOCK) INNER JOIN 
dbo.fn_ContainmentRelationshipTypes() AS CRT ON R.RelationshipTypeId = CRT.RelationshipTypeId 
WHERE      (R.IsDeleted = 0)))) AS GetTopLevelEntities ON 
GetTopLevelEntities.BaseManagedEntityId = ManagedEntityGenericView.Id INNER JOIN 
(SELECT DISTINCT BaseManagedEntityId 
FROM          TypedManagedEntity WITH (NOLOCK) 
WHERE      (ManagedTypeId IN 
(SELECT     DerivedManagedTypeId 
FROM dbo.fn_DerivedManagedTypes(dbo.fn_ManagedTypeId_Group()) AS fn_DerivedManagedTypes_1))) AS GetOnlyGroups ON 
GetOnlyGroups.BaseManagedEntityId = ManagedEntityGenericView.Id)) 
ORDER BY 'Group'
--------------------------------------------------------------------------------
--To find all installed Management Packs and their version:
SELECT Name AS 'ManagementPackID',
 FriendlyName,
 DisplayName,
 Version,
 Sealed,
 LastModified,
 TimeCreated 
FROM ManagementPackView
WHERE LanguageCode = 'ENU' 
OR LanguageCode IS NULL
ORDER BY DisplayName

--Number of Views per Management Pack:
SELECT mp.MPName, v.ViewVisible, COUNT(*) As ViewsPerMP 
FROM [Views] v 
            INNER JOIN ManagementPack mp ON mp.ManagementPackID = v.ManagementPackID 
GROUP BY  mp.MPName, v.ViewVisible 
ORDER BY v.ViewVisible DESC, COUNT(*) Desc

--How to gather all the views in the database, their ID, MP location, and view type:
select vv.id as 'View Id', 
vv.displayname as 'View DisplayName', 
vv.name as 'View Name', 
vtv.DisplayName as 'ViewType', 
mpv.FriendlyName as 'MP Name' 
from ViewsView vv 
inner join managementpackview mpv on mpv.id = vv.managementpackid 
inner join viewtypeview vtv on vtv.id = vv.monitoringviewtypeid 
-- where mpv.FriendlyName like '%default%' 
-- where vv.displayname like '%operating%' 
order by mpv.FriendlyName, vv.displayname

--Classes available in the DB:
SELECT count(*) FROM ManagedType

--Total BaseManagedEntities
SELECT count(*) FROM BaseManagedEntity

--To get the state of every instance of a particular monitor the following query can be run, (replace <Health Service Heartbeat Failure> with the name of the monitor):
SELECT bme.FullName,
 bme.DisplayName,
 s.HealthState 
FROM state AS s, 
 BaseManagedEntity as bme 
WHERE s.basemanagedentityid = bme.basemanagedentityid 
AND s.monitorid IN (SELECT Id FROM MonitorView WHERE DisplayName = 'Health Service Heartbeat Failure')

--For example, this gets the state of the Microsoft.SQLServer.2012.DBEngine.ServiceMonitor for each instance of the SQL 2012 Database Engine class.
SELECT bme.FullName,
 bme.DisplayName,
 s.HealthState 
FROM state AS s, BaseManagedEntity as bme 
WHERE s.basemanagedentityid = bme.basemanagedentityid 
AND s.monitorid IN (SELECT MonitorId FROM Monitor WHERE MonitorName = 'Microsoft.SQLServer.2012.DBEngine.ServiceMonitor') 

--To find the overall state of any object in OpsMgr the following query should be used to return the state of the System.EntityState monitor:
SELECT bme.FullName,
 bme.DisplayName,
 s.HealthState 
FROM state AS s, BaseManagedEntity as bme 
WHERE s.basemanagedentityid = bme.basemanagedentityid AND s.monitorid IN (SELECT MonitorId FROM Monitor WHERE MonitorName = 'System.Health.EntityState')

 --The Alert table contains all alerts currently open in OpsMgr. This includes resolved alerts until they are groomed out of the database. To get all alerts across all instances of a given monitor use the following query and substitute in the required monitor name:
SELECT * FROM Alert WHERE ProblemID IN (SELECT MonitorId FROM Monitor WHERE MonitorName = 'Microsoft.SQLServer.2012.DBEngine.ServiceMonitor')

--To retrieve all alerts for all instances of a specific class use the following query and substitute in the required table name, in this example MT_Microsoft$SQLServer$2012$DBEngine is used to look for SQL alerts:
SELECT * FROM Alert WHERE BaseManagedEntityID IN (SELECT BaseManagedEntityID from MT_Microsoft$SQLServer$2012$DBEngine)

--To determine which table is currently being written to for event and performance data use the following query:
SELECT * FROM PartitionTables WHERE IsCurrent = 1

--Number of instances of a type:  (Number of disks, computers, databases, etc that OpsMgr has discovered) 
SELECT mt.TypeName, COUNT(*) AS NumEntitiesByType 
FROM BaseManagedEntity bme WITH(NOLOCK) 
LEFT JOIN ManagedType mt WITH(NOLOCK) ON mt.ManagedTypeID = bme.BaseManagedTypeID 
WHERE bme.IsDeleted = 0 
GROUP BY mt.TypeName 
ORDER BY COUNT(*) DESC

--To retrieve all performance data for a given rule in a readable format use the following query: (change the r.RuleName value – get list from Rules Table)
SELECT bme.Path, pc.ObjectName, pc.CounterName, ps.PerfmonInstanceName, pdav.SampleValue, pdav.TimeSampled 
FROM PerformanceDataAllView AS pdav with (NOLOCK) 
INNER JOIN PerformanceSource ps on pdav.PerformanceSourceInternalId = ps.PerformanceSourceInternalId 
INNER JOIN PerformanceCounter pc on ps.PerformanceCounterId = pc.PerformanceCounterId 
INNER JOIN Rules r on ps.RuleId = r.RuleId 
INNER JOIN BaseManagedEntity bme on ps.BaseManagedEntityID = bme.BaseManagedEntityID 
WHERE r.RuleName = 'Microsoft.Windows.Server.6.2.LogicalDisk.FreeSpace.Collection' 
GROUP BY PerfmonInstanceName, ObjectName, CounterName, SampleValue, TimeSampled, bme.path 
ORDER BY bme.path, PerfmonInstanceName, TimeSampled

--To determine what discoveries are still associated with a computer – helpful in finding old stale computer objects in the console that are no longer agent managed, or desired.
select BME.FullName, DS.DiscoveryRuleID, D.DiscoveryName from typedmanagedentity TME 
Join BaseManagedEntity BME ON TME.BaseManagedEntityId = BME.BaseManagedEntityId 
JOIN DiscoverySourceToTypedManagedEntity DSTME ON TME.TypedManagedEntityID = DSTME.TypedManagedEntityID 
JOIN DiscoverySource DS ON DS.DiscoverySourceID = DSTME.DiscoverySourceID 
JOIN Discovery D ON DS.DiscoveryRuleID=D.DiscoveryID 
Where BME.Fullname like '%SQL2A%'

--To dump out all the rules and monitors that have overrides, and display the context and instance of the override:
select rv.DisplayName as WorkFlowName, OverrideName, mo.Value as OverrideValue, 
mt.TypeName as OverrideScope, bme.DisplayName as InstanceName, bme.Path as InstancePath, 
mpv.DisplayName as ORMPName, mo.LastModified as LastModified 
from ModuleOverride mo 
inner join managementpackview mpv on mpv.Id = mo.ManagementPackId 
inner join ruleview rv on rv.Id = mo.ParentId 
inner join ManagedType mt on mt.managedtypeid = mo.TypeContext 
left join BaseManagedEntity bme on bme.BaseManagedEntityId = mo.InstanceContext 
Where mpv.Sealed = 0 
UNION ALL 
select mv.DisplayName as WorkFlowName, OverrideName, mto.Value as OverrideValue, 
mt.TypeName as OverrideScope, bme.DisplayName as InstanceName, bme.Path as InstancePath, 
mpv.DisplayName as ORMPName, mto.LastModified as LastModified 
from MonitorOverride mto 
inner join managementpackview mpv on mpv.Id = mto.ManagementPackId 
inner join monitorview mv on mv.Id = mto.MonitorId 
inner join ManagedType mt on mt.managedtypeid = mto.TypeContext 
left join BaseManagedEntity bme on bme.BaseManagedEntityId = mto.InstanceContext 
Where mpv.Sealed = 0 
Order By mpv.DisplayName
-----------------------------------------------------------------------------------
---AGENT INFO
------------------------------------------------
------------------------------------------------
--To find all managed computers that are currently down and not pingable:
SELECT bme.DisplayName,
  s.LastModified as LastModifiedUTC,
  dateadd(hh,-5,s.LastModified) as 'LastModifiedCST (GMT-5)' 
FROM state AS s, BaseManagedEntity AS bme 
WHERE s.basemanagedentityid = bme.basemanagedentityid 
AND s.monitorid 
 IN (SELECT MonitorId FROM Monitor WHERE MonitorName = 'Microsoft.SystemCenter.HealthService.ComputerDown') 
 AND s.Healthstate = '3' AND bme.IsDeleted = '0' 
ORDER BY s.Lastmodified DESC

--To find a computer name from a HealthServiceID (guid from the Agent proxy alerts)
select DisplayName, Path, basemanagedentityid from basemanagedentity where basemanagedentityid = '<guid>'

--To view the agent patch list (all hotfixes applied to all agents)
select bme.path AS 'Agent Name',
 hs.patchlist AS 'Patch List' 
from MT_HealthService hs 
inner join BaseManagedEntity bme on hs.BaseManagedEntityId = bme.BaseManagedEntityId 
order by path

--Here is a query to see all Agents which are manually installed:
select bme.DisplayName from MT_HealthService mths 
INNER JOIN BaseManagedEntity bme on bme.BaseManagedEntityId = mths.BaseManagedEntityId 
where IsManuallyInstalled = 1

--Here is a query that will set all agents back to Remotely Manageable:
UPDATE MT_HealthService 
SET IsManuallyInstalled=0 
WHERE IsManuallyInstalled=1

--Now – the above query will set ALL agents back to “Remotely Manageable = Yes” in the console.  If you want to control it agent by agent – you need to specify it by name here:
UPDATE MT_HealthService 
SET IsManuallyInstalled=0 
WHERE IsManuallyInstalled=1 
AND BaseManagedEntityId IN 
(select BaseManagedEntityID from BaseManagedEntity 
where BaseManagedTypeId = 'AB4C891F-3359-3FB6-0704-075FBFE36710' 
AND DisplayName = 'servername.domain.com')

--Get the discovered instance count of the top 50 agents 
DECLARE @RelationshipTypeId_Manages UNIQUEIDENTIFIER 
SELECT @RelationshipTypeId_Manages = dbo.fn_RelationshipTypeId_Manages() 
SELECT TOP 50 bme.DisplayName, SUM(1) AS HostedInstances 
FROM BaseManagedEntity bme 
RIGHT JOIN ( 
SELECT 
      HBME.BaseManagedEntityId AS HS_BMEID, 
      TBME.FullName AS TopLevelEntityName, 
      BME.FullName AS BaseEntityName, 
      TYPE.TypeName AS TypedEntityName 
FROM BaseManagedEntity BME WITH(NOLOCK) 
      INNER JOIN TypedManagedEntity TME WITH(NOLOCK) ON BME.BaseManagedEntityId = TME.BaseManagedEntityId AND BME.IsDeleted = 0 AND TME.IsDeleted = 0 
      INNER JOIN BaseManagedEntity TBME WITH(NOLOCK) ON BME.TopLevelHostEntityId = TBME.BaseManagedEntityId AND TBME.IsDeleted = 0 
      INNER JOIN ManagedType TYPE WITH(NOLOCK) ON TME.ManagedTypeID = TYPE.ManagedTypeID 
      LEFT JOIN Relationship R WITH(NOLOCK) ON R.TargetEntityId = TBME.BaseManagedEntityId AND R.RelationshipTypeId = @RelationshipTypeId_Manages AND R.IsDeleted = 0 
      LEFT JOIN BaseManagedEntity HBME WITH(NOLOCK) ON R.SourceEntityId = HBME.BaseManagedEntityId 
) AS dt ON dt.HS_BMEID = bme.BaseManagedEntityId 
GROUP by BME.displayname 
order by HostedInstances DESC
----------------------------------------------------------------------
----OPS MISC
------------------------------------------------------------
------------------------------------------------------------
--To get all the OperationsManager configuration settings from the database:
SELECT ManagedTypePropertyName,
 SettingValue,
 mtv.DisplayName,
 gs.LastModified
FROM GlobalSettings gs
INNER JOIN ManagedTypeProperty mtp on gs.ManagedTypePropertyId = mtp.ManagedTypePropertyId
INNER JOIN ManagedTypeView mtv on mtp.ManagedTypeId = mtv.Id
ORDER BY mtv.DisplayName


--To view grooming info:
SELECT * FROM PartitionAndGroomingSettings WITH (NOLOCK)

--GroomHistory
select * from InternalJobHistory
order by InternalJobHistoryId DESC

--Information on existing User Roles:
SELECT UserRoleName, IsSystem from userrole

--Operational DB version:
select DBVersion from __MOMManagementGroupInfo__

--To view all Run-As Profiles, their associated Run-As account, and associated agent name:
select srv.displayname as 'RunAs Profile Name', 
srv.description as 'RunAs Profile Description', 
cmss.name as 'RunAs Account Name', 
cmss.description as 'RunAs Account Description', 
cmss.username as 'RunAs Account Username', 
cmss.domain as 'RunAs Account Domain', 
mp.FriendlyName as 'RunAs Profile MP', 
bme.displayname as 'HealthService' 
from dbo.SecureStorageSecureReference sssr 
inner join SecureReferenceView srv on srv.id = sssr.securereferenceID 
inner join CredentialManagerSecureStorage cmss on cmss.securestorageelementID = sssr.securestorageelementID 
inner join managementpackview mp on srv.ManagementPackId = mp.Id 
inner join BaseManagedEntity bme on bme.basemanagedentityID = sssr.healthserviceid 
order by srv.displayname

--Config Service logs
SELECT * FROM cs.workitem
ORDER BY WorkItemRowId DESC

--Config Service Snapshot history
SELECT * FROM cs.workitem
WHERE WorkItemName like '%snap%'
ORDER BY WorkItemRowId DESC
----------------------------------------------------------
---MY WORKSPACE VIEWS
-----------------------------------------------------------
-----------------------------------------------------------
SELECT 
  MyWSViews.UserSid,
  MyWSViews.SavedSearchName,
  VT.ViewTypeName,
  VT.ManagementPackId,
  MyWSViews.ConfigurationXML
FROM [OperationsManager].[dbo].[SavedSearch] AS MyWSViews
  INNER JOIN [OperationsManager].[dbo].[ViewType] AS VT ON MyWSViews.ViewTypeId=VT.ViewTypeId
WHERE
  MyWSViews.TargetManagedTypeId is not NULL
--------------------------------------------------------------------------


 



 




 



 










 




