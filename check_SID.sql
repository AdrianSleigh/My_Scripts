--CheckSID
-------------------------------------------------------------------------------
SELECT @@servername,[name] as [logins],sid,type_desc from sys.server_principals 
WHERE type in ('S','U')
AND [name]  NOT like 'NT%'
AND [name]  NOT like '##%'
AND [name]  NOT like 'SA'