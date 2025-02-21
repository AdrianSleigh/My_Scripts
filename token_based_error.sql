SELECT
spm.class_desc, spm.permission_name,spm.state_desc,spr.name, spr.type_desc, spr.is_disabled,
ep.name,ep.protocol_desc,ep.state_desc, ep.type_desc
FROM sys.server_permissions spm
JOIN sys.server_principals spr ON spm.grantee_principal_id= spr.principal_id
LEFT OUTER JOIN sys.endpoints ep ON spm.major_id= ep.endpoint_id
WHERE (spm.permission_name = 'CONNECT SQL' and spm.class_desc = 'SERVER')
OR (spm.permission_name = 'CONNECT' and spm.class_desc = 'ENDPOINT')
GO