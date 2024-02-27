--FIND NON SYSTEM TABLES IN MASTER DB ALNG WITH LAST USED INFO
--Adrian Sleigh 13/01/21
--------------------------------------------------------------
USE MASTER
GO
SELECT 
a.Table_Name ,
b.create_date,b.modify_date,
d.index_id,d.user_seeks,d.user_scans,d.user_lookups,d.user_updates,d.last_user_seek,d.last_user_scan,d.last_user_lookup,d.last_user_update
FROM [master].INFORMATION_SCHEMA.TABLES a
   JOIN sys.tables b
      ON a.table_name = b.name
   JOIN sysobjects c
      ON a.table_name =c.name
   JOIN  sys.dm_db_index_usage_stats d
      ON c.id =d.object_id

WHERE Table_Type = 'BASE TABLE'
AND  Table_Name NOT IN ('spt_values','spt_fallback_db','spt_fallback_dev','spt_fallback_usg','spt_monitor','MSreplication_options')
--AND TableE_Name NOT IN ('CPU_Usage','PLE')

