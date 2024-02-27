--Cursor all databases
---------------------------------------------------------
DECLARE @DB_Name varchar(100) 
DECLARE @Command nvarchar(200) 
DECLARE database_cursor CURSOR FOR 
SELECT name 
FROM MASTER.sys.sysdatabases 
OPEN database_cursor 
FETCH NEXT FROM database_cursor INTO @DB_Name 
WHILE @@FETCH_STATUS = 0 
BEGIN 
    SELECT @Command = 'SELECT ' + '''' + @DB_Name + '''' + ', SF.filename, SF.size FROM sys.sysfiles SF'
     EXEC sp_executesql @Command 

     
	 FETCH NEXT FROM database_cursor INTO @DB_Name 
END 
CLOSE database_cursor 
DEALLOCATE database_cursor 