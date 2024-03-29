--FIND POTENTIAL UNUSED ACCOUNTS
--APS 19/02/21
--if db_present column is null database does not exist and so orphaned SQL account
---------------------------------------------------------------------------------------------------------
select a.principal_id,a.[sid],a.name AS account, a.[default_database_name], a.is_disabled,c.name AS db_present
from sys.server_principals a
LEFT join sys.database_principals b
on a.[sid] = b.[sid]
LEFT JOIN sys.databases c
on a.default_database_name = c.name
WHERE a.name NOT IN ('sa','public','sysadmin','securityadmin','serveradmin','setupadmin','processadmin','diskadmin','dbcreator','bulkadmin',
'##MS_SQLResourceSigningCertificate##','##MS_SQLReplicationSigningCertificate##','##MS_SQLAuthenticatorCertificate##','##MS_PolicySigningCertificate##',
'##MS_SmoExtendedSigningCertificate##','##MS_PolicyTsqlExecutionLogin##','NT AUTHORITY\SYSTEM','NT SERVICE\MSSQLSERVER','BUILTIN\Administrators','NT SERVICE\SQLSERVERAGENT'
)
--database level query
--select * from sys.database_principals