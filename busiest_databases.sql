---BUSIEST DATABASES
---RUN ACROSS ESTATE
-----------------------------------------------------------------

select sum(qs.total_elapsed_time) total_elapsed_time,
 sum(qs.total_worker_time) total_worker_time,
 db_name(CONVERT(SMALLINT, dep.value)) db_name, dep.value from
 sys.dm_exec_query_stats qs
 cross apply sys.dm_exec_plan_attributes(qs.plan_handle) dep
 where dep.attribute = N'dbid'
 group by dep.value
 order by sum(qs.total_elapsed_time) desc

 ------------------------------------------------
 SELECT SUM(deqs.total_logical_reads) TotalPageReads,
SUM(deqs.total_logical_writes) TotalPageWrites,
CASE
WHEN DB_NAME(dest.dbid) IS NULL THEN 'AdhocSQL'
ELSE DB_NAME(dest.dbid) END Databasename
FROM sys.dm_exec_query_stats deqs
CROSS APPLY sys.dm_exec_sql_text(deqs.sql_handle) AS dest
GROUP BY DB_NAME(dest.dbid)

-------------------------------------------------