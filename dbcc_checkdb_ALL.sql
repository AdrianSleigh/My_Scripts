
-----------------------------------------------
----DBCCC CHECKDB FOR ALL DATABASES
----Adrian Sleigh 05/04/17
-----------------------------------------------
DECLARE database_cursor CURSOR FOR SELECT name FROM MASTER..sysdatabases
DECLARE @database_name sysname

OPEN database_cursor
FETCH NEXT FROM database_cursor INTO @database_name
WHILE @@FETCH_STATUS=0
BEGIN
  PRINT @database_name
  --dbcc checkdb(@database_name) with no_infomsgs
  DBCC checkdb(@database_name) WITH ALL_ERRORMSGS,DATA_PURITY
  FETCH NEXT FROM database_cursor INTO @database_name
END

CLOSE database_cursor
DEALLOCATE database_cursor