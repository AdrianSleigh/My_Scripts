----file factor calc....
Select object_name(i.object_id) As 'tableName'
    , i.name As 'indexName'
    , i.type_desc
    , Max(p.partition_number) As 'partitions'
    , Sum(p.rows) As 'rows'
    , Sum(au.data_pages) As 'dataPages'
    , Sum(p.rows) / Sum(au.data_pages) As 'rowsPerPage'
From sys.indexes As i
Join sys.partitions As p
    On i.object_id = p.object_id
    And i.index_id = p.index_id
Join sys.allocation_units As au
    On p.hobt_id = au.container_id
Where object_name(i.object_id) Not Like 'sys%'
    And au.type_desc = 'IN_ROW_DATA'
Group By object_name(i.object_id)
    , i.name
    , i.type_desc
Having Sum(au.data_pages) > 100
Order By rowsPerPage;
