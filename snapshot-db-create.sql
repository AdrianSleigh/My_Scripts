--snapshot database creation

-- MUST BE RUN FROM SOURCE DATABASE
-- Destination Directory and target DB name
declare @ssdirname varchar(1000), @targetdb varchar(255) 
SET @ssdirname = 'c:\MSSnapShots\'
SET @targetdb = DB_NAME() + 'SS'

-- Unique timestamp for filenames
DECLARE @timestamp varchar(50)
SET @timestamp = REPLACE(REPLACE(REPLACE(CONVERT(varchar(50),GETDATE(),126),':',''),'.',''),'-','')

DECLARE oncmd CURSOR FOR
	select OnCmd = '(NAME=''' + [name] + ''', FILENAME=''' + @ssdirname + [name] + '-' + @timestamp + '.ss'')'
	from sys.database_files
	where [type] = 0

DECLARE @oncmd varchar(500), @sqlcmd varchar(4000)
SET @sqlcmd = ''

OPEN oncmd
FETCH NEXT FROM oncmd INTO @oncmd
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @sqlcmd <> ''
		SET @sqlcmd = @sqlcmd + ', ' + CHAR(10)
	SET @sqlcmd = @sqlcmd + @oncmd

	FETCH NEXT FROM oncmd INTO @oncmd
END
CLOSE oncmd
DEALLOCATE oncmd

SET @sqlcmd = 'CREATE DATABASE ' + @targetdb + ' ON ' + CHAR(10) + @sqlcmd
SET @sqlcmd = @sqlcmd + CHAR(10) + 'AS SNAPSHOT OF ' + DB_NAME()


IF EXISTS (SELECT name FROM sys.databases WHERE name = @targetdb)
	SET @sqlcmd = 'DROP DATABASE ' + @targetdb + ';' + CHAR(10) + @sqlcmd

PRINT @sqlcmd
EXEC (@sqlcmd)
