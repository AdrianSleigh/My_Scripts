-------------------------------------------------------------------------- 
---GENERATES SQL CODE FOR ANY USER DATABASES THAT ARE NOT OWNED BY 'topdog')
---Adrian sleigh 11/01/19
---RUN AGAINST CMS
---------------------------------------------------------------------------
--FIND ALL DATABASE OWNERS

SELECT [name],[compatibility_level],suser_sname(owner_sid)AS DatabaseOwner,[collation_name],[create_date]
 from sys.databases
 where suser_sname(owner_sid)
NOT like 'topdog'

--GENERATE TSQL TO CHANGE OWNERS
--------------------------------------------------------------------------
/*
SELECT 'ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME(name) + ' TO [topdog];'
from sys.databases
where name not in ('master', 'model', 'tempdb', 'msdb')
AND suser_sname(owner_sid) <> 'topdog'
-----------------------------------------------------------------------------
*/