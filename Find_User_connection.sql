--FIND USER CONNECTION
----18/02/24 Adrian Sleigh
SELECT 
    DB_NAME(dbid) as DBName, 
    COUNT(dbid) as NumberOfConnections,
    loginame as LoginName
FROM
    sys.sysprocesses
WHERE 
    dbid > 0
	----- add user in the below like

	AND loginame like '%35020%'
GROUP BY 
    dbid, loginame
;