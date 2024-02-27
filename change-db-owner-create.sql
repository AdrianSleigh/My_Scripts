-------------------------------------------------------------------------- 
---GENERATES SQL CODE FOR ANY USER DATABASES THAT ARE NOT OWNED BY 'topdog')
---Adrian sleigh 11/01/19
---------------------------------------------------------------------------

SELECT 'ALTER AUTHORIZATION ON DATABASE::' + QUOTENAME(name) + ' TO [topdog];'
from sys.databases
where name not in ('master', 'model', 'tempdb', 'msdb')
AND suser_sname(owner_sid) <> 'topdog'
-----------------------------------------------------------------------------