-----Find detached databases based on name
-----APS 23/11/20
-----------------------------------------------
----1. check file locations
USE master;
SELECT 
  name 'Logical Name', 
  physical_name 'File Location'
FROM sys.master_files;
-------------------------------------------------
-------------------------------------------------
-- 2. get drives used first then add below then run second part of script

-- sysaltfiles solution
SELECT DISTINCT LEFT([filename], 1)  AS 'Drive'
FROM sysaltfiles
ORDER BY [Drive];

-------------------------------------------------
-------------------------------------------------
GO

sp_configure 'show advanced options', 1;

GO

RECONFIGURE;

GO

---- enable xp_cmdshell

sp_configure 'xp_cmdshell', 1;

GO

RECONFIGURE;

GO


RECONFIGURE;

GO 

-- create temporary table

create table #temp_mdf_files

(

full_filename varchar(200)

)

--populate the temp table with any MDF files found
--3 add drive letters based on 2. above-----------
--------------------------------------------------
insert #temp_mdf_files

exec xp_cmdshell 'dir d:\*.mdf /s/b'

insert #temp_mdf_files

exec xp_cmdshell 'dir e:\*.mdf /s/b'

-- 

select

-- exclude the subdirectory name

upper(reverse(substring(reverse(full_filename ), 1,charindex('\', reverse(full_filename ) )-1) )) As MDF_FileName,

full_filename

from #temp_mdf_files

where

--exclude rows which contain system messages or nulls

full_filename like '%\%'

--exclude system databases

and upper(reverse(substring(reverse(full_filename ), 1,charindex('\', reverse(full_filename ) )-1) ))

not in ('DISTMDL.MDF', 'MASTER.MDF', 'MODEL.MDF', 'MSDBDATA.MDF' , 'MSSQLSYSTEMRESOURCE.MDF', 'TEMPDB.MDF' ) 

-- MDF filename excluding the subdirectory name

and full_filename

not in (select Upper(FILEname) from sys.SYSdatabases)

order by MDF_FileName

-- Housekeeping

drop table #temp_mdf_files

-- disable these jobs


GO

RECONFIGURE;

GO

-- disable xp_cmdshell

sp_configure 'xp_cmdshell', 0;

GO

RECONFIGURE;

GO

-- hide advanced options

sp_configure 'show advanced options', 0;

GO

RECONFIGURE;

GO
