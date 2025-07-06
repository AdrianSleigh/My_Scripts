---CreateExtended events for SQL Upgrade monitoring Pre-Post 2016-2019
---Adrian Sleigh 07/06/25
--job required to update data
-----------------------------------------------------------------------
-- Detect SQL Server version via XE catalog
DECLARE @version_label NVARCHAR(10) =
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM sys.dm_xe_objects 
            WHERE name = 'query_execution_plan_profile'
                  AND object_type = 'event'
        ) THEN '2019'
        ELSE '2016'
    END;

-- Create XE session only if it doesn't exist
IF NOT EXISTS (
    SELECT 1 FROM sys.server_event_sessions WHERE name = 'PerfSnapshot'
)
BEGIN
    EXEC('CREATE EVENT SESSION [PerfSnapshot] ON SERVER
    ADD EVENT sqlserver.sql_batch_completed (
        ACTION (
            sqlserver.sql_text,
            sqlserver.session_id,
            sqlserver.database_name
        )
        WHERE duration > 5000
    ),
    ADD EVENT sqlserver.query_post_execution_showplan (
        ACTION (
            sqlserver.sql_text,
            sqlserver.session_id,
            sqlserver.database_name
        )
    )
    ADD TARGET package0.event_file (
        SET filename = N''C:\XELogs\PerfSnapshot.xel'',
            max_file_size = 50,
            max_rollover_files = 5
    )
    WITH (
        MAX_MEMORY = 4096 KB,
        EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
        MAX_DISPATCH_LATENCY = 30 SECONDS,
        TRACK_CAUSALITY = ON,
        STARTUP_STATE = OFF
    );');
END;
----------------------------------------------------------------------------
--2.

-- Detect SQL Server version
DECLARE @version_label NVARCHAR(10) =
    CASE 
        WHEN EXISTS (
            SELECT 1 
            FROM sys.dm_xe_objects 
            WHERE name = 'query_execution_plan_profile'
                  AND object_type = 'event'
        ) THEN '2019'
        ELSE '2016'
    END;

-- Detect local time offset in minutes
DECLARE @offset_minutes INT =
    DATEPART(TZOFFSET, SYSDATETIMEOFFSET());

-- Capture system metrics
DECLARE @ple_value INT =
    (SELECT TOP 1 cntr_value
     FROM sys.dm_os_performance_counters
     WHERE object_name LIKE '%Buffer Manager%' AND counter_name = 'Page life expectancy');

DECLARE @cpu_usage NUMERIC(5,2) =
    (SELECT TOP 1 
         record.value('(./Record/SchedulerMonitorEvent/SystemHealth/ProcessUtilization)[1]', 'int')
     FROM (
         SELECT CAST(record AS XML) AS record
         FROM sys.dm_os_ring_buffers
         WHERE ring_buffer_type = N'RING_BUFFER_SCHEDULER_MONITOR'
     ) AS x
     ORDER BY record.value('(./Record/@timestamp)[1]', 'datetime2') DESC);

-- Create tables if needed
IF OBJECT_ID('PerfSnapshotResults') IS NULL
BEGIN
    CREATE TABLE PerfSnapshotResults (
        inferred_sql_version NVARCHAR(10),
        page_life_expectancy INT,
        cpu_percent NUMERIC(5,2),
        event_name NVARCHAR(100),
        sql_text NVARCHAR(MAX),
        database_name NVARCHAR(128),
        duration_ms BIGINT,
        event_time DATETIME2,
        event_time_local DATETIME2
    );
END;

IF OBJECT_ID('PerfWaitStats') IS NULL
BEGIN
    CREATE TABLE PerfWaitStats (
        inferred_sql_version NVARCHAR(10),
        snapshot_time DATETIME2,
        wait_type NVARCHAR(100),
        wait_time_ms BIGINT,
        waiting_tasks_count BIGINT,
        max_wait_time_ms BIGINT
    );
END;

-- Insert wait stats
INSERT INTO PerfWaitStats (
    inferred_sql_version,
    snapshot_time,
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    max_wait_time_ms
)
SELECT TOP 10
    @version_label,
    GETDATE(),
    wait_type,
    wait_time_ms,
    waiting_tasks_count,
    max_wait_time_ms
FROM sys.dm_os_wait_stats
WHERE wait_type NOT IN (
    'SLEEP_TASK','LAZYWRITER_SLEEP','RESOURCE_QUEUE',
    'BROKER_TASK_STOP','XE_TIMER_EVENT'
)
ORDER BY wait_time_ms DESC;

-- Insert Extended Events diagnostics
INSERT INTO PerfSnapshotResults (
    inferred_sql_version,
    page_life_expectancy,
    cpu_percent,
    event_name,
    sql_text,
    database_name,
    duration_ms,
    event_time,
    event_time_local
)
SELECT
    @version_label,
    @ple_value,
    @cpu_usage,
    event_data.value('(event/@name)[1]', 'nvarchar(100)'),
    event_data.value('(event/action[@name="sql_text"]/value)[1]', 'nvarchar(max)'),
    event_data.value('(event/action[@name="database_name"]/value)[1]', 'nvarchar(128)'),
    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint'),
    event_data.value('(event/@timestamp)[1]', 'datetime2'),
    DATEADD(MINUTE, @offset_minutes, event_data.value('(event/@timestamp)[1]', 'datetime2'))
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        N'C:\XELogs\PerfSnapshot*.xel', NULL, NULL, NULL
    )
) AS data;
---------------------------------------------------------------------------------
----3. query tables
SELECT * FROM PerfSnapshotResults order by event_time desc
--truncate table PerfSnapshotResults

SELECT * FROM PerfWaitStats
-----4. export to csv
