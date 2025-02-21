---RELOCATE TEMP DB FILES
---------------------
Use master
 GO

 SELECT 
 name AS [LogicalName]
 ,physical_name AS [Location]
 ,state_desc AS [Status]
 FROM sys.master_files
 WHERE database_id = DB_ID(N'tempdb');
 GO

------------------------------------------------
--MOVE
USE master;
 GO

 ALTER DATABASE tempdb 
 MODIFY FILE (NAME = tempdev, FILENAME = 'D:\MSSQL\DATA\tempdb.mdf');
 GO

/* ALTER DATABASE tempdb 
 MODIFY FILE (NAME = tempdev2, FILENAME = 'D:\MSSQL\DATA\tempdb_mssql_2.ndf');
 GO
 */
 ALTER DATABASE tempdb 
 MODIFY FILE (NAME = templog, FILENAME = 'D:\MSSQL\LOG\templog.ldf');
 GO
--VERIFY