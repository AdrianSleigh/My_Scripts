/*
EXEC sp_change_users_login 'Report';
EXEC sp_change_users_login 'Auto_Fix', 'TribalFormsLive'
*/


/*
Script to fix orphans when moving db to another server.
Note: Auto_fix option will create a SQL login id if necessary.
Note: Update_one option will NOT create a SQL login.
Note: Report option reports on sql login vs user login mismatches.
*/
SET NOCOUNT ON

DECLARE @UserName nvarchar(128)
,@MissingUsers varchar(4000)
,@cmd varchar(1000)

-- Re-sync user ids to master database
SET @UserName = ''

WHILE @UserName IS NOT NULL
BEGIN
IF @UserName IS NOT NULL
BEGIN
SELECT @UserName = min(a.name)
FROM sysusers AS a
WHERE a.name > @UserName and IsSQLRole = 0
AND name NOT IN('dbo','guest', 'INFORMATION_SCHEMA', 'sys')

-- Add this check for domain accounts 
-- They do not need synced with the master database
IF (SELECT CHARINDEX('\',@UserName) )= 0
BEGIN
SET @cmd = 'sp_change_users_login ''update_one'', ''' 
+ @UserName + ''', ''' + @UserName + ''''

EXEC(@cmd)
END
END
END

EXEC sp_change_users_login 'Report'