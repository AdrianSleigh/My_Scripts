----LOOKS FOR CLR OBJECTS
-------------------------------------------------------------
sp_MSforeachdb 'Use [?]; 
SELECT o.object_id AS [Object_ID]
    ,schema_name(o.schema_id) + ''.'' + o.[name] AS [CLRObjectName]
    ,o.type_desc AS [CLRType]
    ,o.create_date AS [Created]
    ,o.modify_date AS [Modified]
    ,a.permission_set_desc AS [CLRPermission]
FROM sys.objects o
INNER JOIN sys.module_assembly_usages ma
    ON o.object_id = ma.object_id
INNER JOIN sys.assemblies a
    ON ma.assembly_id = a.assembly_id '