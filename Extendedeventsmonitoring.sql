--Extended events for upgrade monitoring
--07/07/25 Adrian Sleigh
-----------------------------------------------------
CREATE EVENT SESSION [PerfSnapshot] ON SERVER
ADD EVENT sqlserver.sql_batch_completed (
    ACTION (sqlserver.sql_text, sqlserver.session_id, sqlserver.client_app_name)
    WHERE duration > 5000
),
ADD EVENT sqlserver.wait_info (
    WHERE wait_type <> 'SLEEP_TASK'
),
ADD EVENT sqlserver.file_read,
ADD EVENT sqlserver.file_write,

--  Always On Diagnostic Events
ADD EVENT sqlserver.availability_group_state_change,
ADD EVENT sqlserver.database_replica_state_change,
ADD EVENT sqlserver.hadr_db_partner_state_change

--  Target: Event File for Export
ADD TARGET package0.event_file (
    SET filename = N'C:\XELogs\PerfSnapshot.xel'
)
WITH (STARTUP_STATE=OFF);

------------------------------------------------

ALTER EVENT SESSION [PerfSnapshot] ON SERVER STATE = START;
-- ...collect for appropriate window
ALTER EVENT SESSION [PerfSnapshot] ON SERVER STATE = STOP;
------------------------------------------------

SELECT
    event_data.value('(event/@name)[1]', 'nvarchar(100)') AS event_name,
    event_data.value('(event/data[@name="duration"]/value)[1]', 'bigint') AS duration_ms,
    event_data.value('(event/data[@name="wait_type"]/value)[1]', 'nvarchar(100)') AS wait_type,
    event_data.value('(event/data[@name="file_handle"]/value)[1]', 'nvarchar(100)') AS file_handle,
    event_data.value('(event/data[@name="size"]/value)[1]', 'bigint') AS size_bytes,
    event_data.value('(event/data[@name="availability_group_id"]/value)[1]', 'nvarchar(100)') AS ag_id,
    event_data.value('(event/data[@name="database_name"]/value)[1]', 'nvarchar(100)') AS replica_db,
    event_data.value('(event/data[@name="synchronization_state"]/value)[1]', 'int') AS sync_state,
    event_data.value('(event/data[@name="replica_role"]/value)[1]', 'int') AS replica_role
INTO PerfSnapshotResults
FROM (
    SELECT CAST(event_data AS XML) AS event_data
    FROM sys.fn_xe_file_target_read_file(
        N'C:\XELogs\PerfSnapshot*.xel',
        NULL, NULL, NULL)
) AS data;
-----------------------------------------------------
SELECT 'PRE' AS snapshot_phase, * 
INTO AG_Snapshot_Pre
FROM (
    SELECT
        ag.name AS AG_Name,
        ar.replica_server_name,
        drs.database_name,
        drs.synchronization_state_desc,
        drs.is_failover_ready,
        drs.recovery_lsn
    FROM sys.availability_groups ag
    JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
    JOIN sys.dm_hadr_database_replica_states drs ON ar.replica_id = drs.replica_id
) AS snapshot;
------------------------------------------------------
SELECT 'POST' AS snapshot_phase, * 
INTO AG_Snapshot_Post
FROM (
    SELECT
        ag.name AS AG_Name,
        ar.replica_server_name,
        drs.database_name,
        drs.synchronization_state_desc,
        drs.is_failover_ready,
        drs.recovery_lsn
    FROM sys.availability_groups ag
    JOIN sys.availability_replicas ar ON ag.group_id = ar.group_id
    JOIN sys.dm_hadr_database_replica_states drs ON ar.replica_id = drs.replica_id
) AS snapshot;
-------------------------------------------------------
