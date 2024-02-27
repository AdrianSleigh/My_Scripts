/*FILL Factor ALL tables

  Created by : Solihin ho - https://solihinho.wordpress.com
  
  Compatibility : SQL 2005 and next version

*/

IF object_id('tempdb..#result') IS NOT NULL
   DROP TABLE #result

CREATE TABLE #result
(
   DBName       sysname,
   TableName    sysname,
   IndexName    sysname,
   [Rows]       int,
   [FillFactor] tinyint,
   Index_Fragmentation float,
   page_count   int, 
   [TimeStamp]  datetime
)

GO


sp_msforeachdb 'USE ?
INSERT INTO #Result (DBName, TableName, IndexName
    , [FillFactor], [Rows], Index_Fragmentation
    , page_count, [TimeStamp])
SELECT
  db_name() AS DbName
, B.name AS TableName
, C.name AS IndexName
, C.fill_factor AS IndexFillFactor
, D.rows AS RowsCount
, A.avg_fragmentation_in_percent
, A.page_count
, GetDate() as [TimeStamp]
FROM sys.dm_db_index_physical_stats(DB_ID(),NULL,NULL,NULL,NULL) A
INNER JOIN sys.objects B 
   ON A.object_id = B.object_id
INNER JOIN sys.indexes C 
   ON B.object_id = C.object_id AND A.index_id = C.index_id
INNER JOIN sys.partitions D 
   ON B.object_id = D.object_id AND A.index_id = D.index_id
WHERE C.index_id > 0'

SELECT * FROM #Result