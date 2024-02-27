---USE ON CENTRAL MANAGEMENT SERVER TO GET ESTATE INFO
------------------------------------------------------
USE [msdb]
GO
SELECT	g.[name] AS [Group],
		s.[name] AS [SQLAlias],
		s.[server_name] AS [SQLInstance],
		s.[description] AS [Description]
FROM    [dbo].[sysmanagement_shared_server_groups_internal] g
--use INNER JOIN to not show empty folders
LEFT JOIN [dbo].[sysmanagement_shared_registered_servers_internal] s
	ON	g.[server_group_id] = s.[server_group_id]
WHERE	g.[server_type] = 0 --dbengine group
	AND	g.[is_system_object] = 0 --user added only
	
	
-----FIND MY INSTANCE
	AND s.[server_Name]	like '%\PSQL010%'
ORDER BY [Group], [SQLAlias] --alpha sort
GO