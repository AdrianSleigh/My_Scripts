---Change HADR_ENDPOINT TO SA ACCOUNT
---Adrian Sleigh 13/02/23
--------------------------------------------------
--1.GET ENDPOINT OWNER
USE [master];
SELECT SUSER_NAME(principal_id) AS endpoint_owner,
name as endpoint_name
FROM sys.database_mirroring_endpoints
--------------------------------------------------
--2.GRANT TO ACCOUNT
USE [master];
SELECT ep.name,
sp.STATE, 
CONVERT(nvarchar(38), 
SUSER_NAME(sp.grantor_principal_id)) AS [GRANT BY],
sp.TYPE AS PERMISSION,
CONVERT(nvarchar(46),
SUSER_NAME(sp.grantee_principal_id)) AS [GRANT TO]
FROM sys.server_permissions sp, sys.endpoints ep
WHERE sp.major_id = ep.endpoint_id AND [name] = 'Hadr_endpoint'
-------------------------------------------------------
--3. FROM GRANT TO RESULT 2. ABOVE Change [Domain\Account]
BEGIN TRANSACTION
USE [master];
ALTER AUTHORIZATION ON ENDPOINT::Hadr_endpoint TO sa;
GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [Domain\Account];
COMMIT TRANSACTION
-------------------------------------------------------

-----FIX OWNERSHIP OF ALWAYS ON OBJECTS
--- 14/02/23 Adrian Sleigh
----------------------------------------------------------------
USE [master]
GO
DROP LOGIN [domain\account]
GO 
--------------------------------------------------------

USE [master]
GO
SELECT pm.class, pm.class_desc, pm.major_id, pm.minor_id, 
   pm.grantee_principal_id, pm.grantor_principal_id, 
   pm.[type], pm.[permission_name], pm.[state],pm.state_desc, 
   pr.[name] AS [owner], gr.[name] AS grantee
FROM sys.server_permissions pm 
   JOIN sys.server_principals pr ON pm.grantor_principal_id = pr.principal_id
   JOIN sys.server_principals gr ON pm.grantee_principal_id = gr.principal_id
WHERE pr.[name] = N'domain\account';   
--------------------------------------------------------

USE [master]
GO
SELECT pm.class, pm.class_desc, pm.major_id, pm.minor_id, 
   pm.grantee_principal_id, pm.grantor_principal_id, 
   pm.[type], pm.[permission_name], pm.[state],pm.state_desc, 
   pr.[name] AS [owner], gr.[name] AS grantee, e.[name] AS endpoint_name
FROM sys.server_permissions pm 
   JOIN sys.server_principals pr ON pm.grantor_principal_id = pr.principal_id
   JOIN sys.server_principals gr ON pm.grantee_principal_id = gr.principal_id
   JOIN sys.endpoints e ON pm.grantor_principal_id = e.principal_id 
        AND pm.major_id = e.endpoint_id
WHERE pr.[name] = N'domain\account';
--------------------------------------------------------

USE [master]
GO
SELECT ag.[name] AS AG_name, ag.group_id, r.replica_id, r.owner_sid, p.[name] as owner_name 
FROM sys.availability_groups ag 
   JOIN sys.availability_replicas r ON ag.group_id = r.group_id
   JOIN sys.server_principals p ON r.owner_sid = p.[sid]
WHERE p.[name] = 'domain\account'
GO   
--------------------------------------------------------
USE [master]
GO
ALTER AUTHORIZATION ON ENDPOINT::Hadr_endpoint TO SA;
GO   

---------------------------------------------------------
USE [master]
GO
SELECT ag.[name] AS AG_name, ag.group_id, r.replica_id, r.owner_sid, p.[name] as owner_name 
FROM sys.availability_groups ag 
   JOIN sys.availability_replicas r ON ag.group_id = r.group_id
   JOIN sys.server_principals p ON r.owner_sid = p.[sid]
WHERE p.[name] = 'domain\account'
GO   

--------------------------------------------------------

USE [master]
GO
ALTER AUTHORIZATION ON AVAILABILITY GROUP::CONFAG TO SA;
GO
-------------------------------------------------------
USE [master]
GO
DROP LOGIN [domain\account]
GO 
-------------