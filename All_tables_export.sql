------CREATE A SERIES OF SCRIPTS TO CREATE BCP OUTPUT TO CSV SCRIPTS
-------------------------------------------------------------------
USE myDatabase
SELECT 'exec master..xp_cmdshell'
+ ' '''
+ 'bcp'
+ ' ' + TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME
+ ' out'
+ ' E:\releasedDB\prod\'
+ TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + '.csv'
+ ' -c'
+ ' -t,'
+ ' -T'
+ ' -S' + @@SERVERNAME
+ ''''
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE'