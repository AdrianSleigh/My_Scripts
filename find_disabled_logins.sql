
---FIND DISABLEd LOGINS
SELECT name, type_desc, is_disabled
FROM sys.server_principals WHERE is_disabled = 1
ORDER BY name ASC