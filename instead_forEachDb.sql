----instead of foreach database 
----Replace "?" with the database name
-----------------------------------------------------
CREATE PROCEDURE dbo.run_query_across_databases
@sql_command VARCHAR(MAX)
AS
BEGIN
       SET NOCOUNT ON;

  DECLARE @database_name VARCHAR(300)           
  DECLARE @sql_command_to_execute NVARCHAR(MAX) 
  DECLARE @database_names TABLE (database_name VARCHAR(100))
  DECLARE @SQL VARCHAR(MAX) 
     SET @SQL =
       '      SELECT
              SD.name AS database_name
              FROM sys.databases SD
       '
  -- Prepare database name list
       INSERT INTO @database_names
               ( database_name )
       EXEC (@SQL)
      
       DECLARE db_cursor CURSOR FOR SELECT database_name FROM @database_names
       OPEN db_cursor

       FETCH NEXT FROM db_cursor INTO @database_name

       WHILE @@FETCH_STATUS = 0
       BEGIN
          SET @sql_command_to_execute = REPLACE(@sql_command, '?', @database_name) 
          EXEC sp_executesql @sql_command_to_execute
          FETCH NEXT FROM db_cursor INTO @database_name
       END

       CLOSE db_cursor;
       DEALLOCATE db_cursor;
END
GO
--------------------------------------------END----------------------------------
