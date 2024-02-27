---Find which database a table is in 
---------------------------------------------------------------------
	select [name] as [database_name] from sys.databases 
where 
    case when state_desc = 'ONLINE' 
        then object_id(quotename([name]) + '.[dbo].[tableNameHere]', 'U') 
    end is not null
order by 1