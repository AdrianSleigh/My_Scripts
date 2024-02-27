----DISABLE ALL FOREIGN KEYS
EXEC sp_msforeachtable "ALTER TABLE ? NOCHECK CONSTRAINT all"

----ENABLE ALL FOREIGN KEYS
--EXEC sp_msforeachtable "ALTER TABLE ? WITH CHECK CHECK CONSTRAINT all"



use [database]

GO
---to use exec Disable_Triggers_v2 0
--pr_Disable_Triggers_v2 1

CREATE PROCEDURE pr_Disable_Triggers_v2
    @disable BIT = 1
AS
    DECLARE @sql VARCHAR(500)
        ,   @tableName VARCHAR(128)
        ,   @tableSchema VARCHAR(128)

    -- List of all tables
    DECLARE triggerCursor CURSOR FOR
        SELECT  t.TABLE_NAME AS TableName
            ,   t.TABLE_SCHEMA AS TableSchema
        FROM    INFORMATION_SCHEMA.TABLES t
        ORDER BY t.TABLE_NAME, t.TABLE_SCHEMA

    OPEN    triggerCursor
    FETCH NEXT FROM triggerCursor INTO @tableName, @tableSchema
    WHILE ( @@FETCH_STATUS = 0 )
    BEGIN

        SET @sql = 'ALTER TABLE ' + @tableSchema + '.[' + @tableName + '] '
        IF @disable = 1
            SET @sql = @sql + ' DISABLE TRIGGER ALL'
        ELSE
            SET @sql = @sql + ' ENABLE TRIGGER ALL'

        PRINT 'Executing Statement - ' + @sql
        EXECUTE ( @sql )

        FETCH NEXT FROM triggerCursor INTO @tableName, @tableSchema

    END

    CLOSE triggerCursor
    DEALLOCATE triggerCursor