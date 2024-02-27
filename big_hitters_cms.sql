---BIG HITTERS RUN ACROSS CMS

--------------------------------------------------------
---CPU count

SELECT cpu_count AS [Logical CPU Count], hyperthread_ratio AS Hyperthread_Ratio,
cpu_count/hyperthread_ratio AS Physical_CPU_Count,
--physical_memory_kb/1024 AS Physical_Memory_mb,
sqlserver_start_time AS Last_service_restart
FROM sys.dm_os_sys_info

---------------------------------------------------------
--page life expectancy

SELECT object_name,counter_name,cntr_value as PageLifeValue
FROM sys.dm_os_performance_counters WHERE
object_name like '%Buffer Manager%'
AND counter_name = 'Page life expectancy'

---------------------------------------------------------
--active connections

SELECT DB_NAME(ST.dbid) AS the_database
	, COUNT(eC.connection_id) AS total_database_connections
FROM sys.dm_exec_connections eC 
	CROSS APPLY sys.dm_exec_sql_text (eC.most_recent_sql_handle) ST
	LEFT JOIN sys.dm_exec_sessions eS 
		ON eC.most_recent_session_id = eS.session_id
GROUP BY DB_NAME(ST.dbid)
ORDER BY 1;

---------------------------------------------------------
---spaceused--------------------------------------------

exec master.dbo.sp_msforeachdb "exec [?].dbo.sp_spaceused"

---------------------------------------------------------
---database file sizes--------------------------------

SELECT
    D.name AS databasename,
    F.Name AS FileType,
    F.physical_name AS PhysicalFile,
   (F.size*8)/1024   AS FileSizeMB,
   (F.size*8) as SizeInBytes
FROM 
    sys.master_files F
    INNER JOIN sys.databases D ON D.database_id = F.database_id
ORDER BY
    D.name
	------------------------------------------------------
	------------------------------------------------------