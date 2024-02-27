---GET linked server info
-------------------------------------------------------------------------
SELECT *
FROM sys.Servers a
LEFT OUTER JOIN sys.linked_logins b ON b.server_id = a.server_id
LEFT OUTER JOIN sys.server_principals c ON c.principal_id = b.local_principal_id




SELECT c.credential_id, c.name AS Credential_Name, c.credential_identity, p.name AS Proxy_Name, p.enabled, p.description
FROM master.sys.credentials c
LEFT JOIN msdb..sysproxies p
ON  c.credential_id = p.credential_id

SELECT c.credential_id, c.name AS Credential_Name, c.credential_identity, p.name AS Principal_Name, p.type_desc, p.is_disabled, p.default_database_name
FROM master.sys.credentials c
LEFT JOIN master.sys.server_principals p
ON  c.credential_id = p.credential_id

SELECT * FROM sys.server_principal_credentials
SELECT * FROM sys.server_principals