--Tempdb usage---
-----------------
--returns the total number of free pages and total free space in megabytes (MB) available in all files in tempdb.
SELECT SUM(unallocated_extent_page_count) AS [free pages], 
(SUM(unallocated_extent_page_count)*1.0/128) AS [free space in MB]
FROM sys.dm_db_file_space_usage;

--returns the total number of pages used by the version store and the total space in MB used by the version store in tempdb.
SELECT SUM(version_store_reserved_page_count) AS [version store pages used],
(SUM(version_store_reserved_page_count)*1.0/128) AS [version store space in MB]
FROM sys.dm_db_file_space_usage;

--returns the total number of pages used by internal objects and the total space in MB used by internal objects in tempdb
SELECT transaction_id
FROM sys.dm_tran_active_snapshot_database_transactions 
ORDER BY elapsed_time_seconds DESC;

--returns the total number of pages used by user objects and the total space used by user objects in tempdb
SELECT SUM(user_object_reserved_page_count) AS [user object pages used],
(SUM(user_object_reserved_page_count)*1.0/128) AS [user object space in MB]
FROM sys.dm_db_file_space_usage;

-- returns the total amount of disk space used by all files in tempdb.
SELECT SUM(size)*1.0/128 AS [size in MB]
FROM tempdb.sys.database_files