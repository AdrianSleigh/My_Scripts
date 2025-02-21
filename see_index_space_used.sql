-----FIND INDEX USAGE SIZE
-----------------------------------------------------------------
select ss.name [schema], object_name(ddips.object_id) table_name, si.name index_name,
ddips.page_count * 8 [Size KB], ddips.page_count * 8/1024.0 [Size MB]
from sys.dm_db_index_physical_stats(db_id(), null, null, null, 'SAMPLED') ddips
join sys.indexes si on ddips.index_id = si.index_id and ddips.object_id = si.object_id
join sys.tables st on ddips.object_id = st.object_id
join sys.schemas ss on st.schema_id = ss.schema_id
group by ss.name,ddips.object_id,si.name,ddips.page_count
order by table_name asc