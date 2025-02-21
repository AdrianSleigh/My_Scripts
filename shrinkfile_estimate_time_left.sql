--DBCC SHRINKFILE ESTIMATE
----------------------------------------------------
SELECT Percent_Complete, Start_Time, status, Command,
 estimated_completion_time/1000 as Times_Left_Secs, Cpu_time, total_elapsed_time/1000 as Total_Secs
FROM sys.dm_exec_requests
 where command like 'DbccFilesCompact'