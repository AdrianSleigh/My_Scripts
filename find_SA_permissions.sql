----FIND SA PERMISSIONS
SELECT 'Name' = sp.NAME
    ,sp.is_disabled AS [Is_disabled]
FROM sys.server_role_members rm
    ,sys.server_principals sp
WHERE rm.role_principal_id = SUSER_ID('dbcreator')
    AND rm.member_principal_id = sp.principal_id
	AND  sp.name NOT IN ('OURCHESHIRE\CITSQLMonitors','topdog','sa','NT SERVICE\SQLWriter','NT AUTHORITY\SYSTEM')