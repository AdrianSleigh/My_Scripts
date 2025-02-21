/* Query - Run All *.sql Scripts in Folder 05-05-17
 1. put scripts in the required location 
 2. change @Server and @Folder
*/
-- Server to run script
DECLARE @Server VARCHAR(255);
SET @Server = 'SO-paravel\osql008,22005';
 
-- Define location of folder with scripts to run (Always have \ at the end)
DECLARE @Folder VARCHAR(255);
SET @Folder = 'D:\ADE\';
 
-- Define DIR command to find scripts in @Folder
DECLARE @DirCmd VARCHAR(1000);
SET @DirCmd = 'dir /b ' + @Folder + '*.sql';
 
-- Create Temp table to list scripts to run
CREATE TABLE #SQLScripts
    (
      ScriptName VARCHAR(2000)
    );
 
INSERT  INTO #SQLScripts
        EXECUTE xp_cmdshell @DirCmd;
 
-- Declare var for calling scripts
DECLARE @SqlCmd VARCHAR(1000);
-- Declare script var name
DECLARE @script NVARCHAR(128);
-- Define the cursor
DECLARE ScriptCursor CURSOR
  
-- Define the cursor dataset
FOR
    SELECT DISTINCT
            [ScriptName]
    FROM    #SQLScripts
    WHERE   [ScriptName] IS NOT NULL
            AND [ScriptName] <> 'NULL'
            AND [ScriptName] <> 'File Not Found'
    ORDER BY [ScriptName];
 
 -- Start loop
OPEN ScriptCursor;
  
-- Get information from the first row
FETCH NEXT FROM ScriptCursor INTO @script;
  
-- Loop until there are no more rows
WHILE @@fetch_status = 0
    BEGIN
        PRINT 'RUNNING SCRIPT : ' + @script;
        SET @SqlCmd = 'EXEC xp_cmdshell "sqlcmd -s ' + @Server + ' -i '
            + @Folder + @script + '"';
        PRINT @SqlCmd;
        EXEC(@SqlCmd);
-- Get information from next row
        FETCH NEXT FROM ScriptCursor INTO @script;
    END;
  
-- End loop and clean up
CLOSE ScriptCursor;
DEALLOCATE ScriptCursor;
DROP TABLE #SQLScripts; 
GO
------END SCRIPT--------------------------