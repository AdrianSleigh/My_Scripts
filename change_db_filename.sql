---Rename physical file names of database
---Adrian Sleigh 14/03/23
-----------------------------------------
USE [master];
GO
--Disconnect all existing session.
ALTER DATABASE testdb SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
--Change database in to OFFLINE mode.
ALTER DATABASE testdb SET OFFLINE
-----------------------------------------------------------
---via windows change the file names of .mdf and .ldf
-----------------------------------------------------------

----update system catalog with new file names

ALTER DATABASE testdb MODIFY FILE (Name='testdb', FILENAME='F:\Program Files\Microsoft SQL Server\MSSQL15.DEVELOPMENT\MSSQL\DATA\testdb_altered.mdf')
GO
ALTER DATABASE testdb MODIFY FILE (Name='testdb_log', FILENAME='F:\Program Files\Microsoft SQL Server\MSSQL15.DEVELOPMENT\MSSQL\DATA\testdb_altered.ldf')
GO
-----------------------------------------------------------
---Put database back ONLINE 

ALTER DATABASE testdb SET OnLINE

ALTER DATABASE testdb SET MULTI_USER
Go