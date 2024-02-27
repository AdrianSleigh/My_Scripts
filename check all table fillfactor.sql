/*check fill factor
  Created by : Solihin ho - http://solihinho.wordpress.com

  Compatibility : SQL 2000

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
   [TimeStamp]  datetime
)

GO

sp_msforeachdb 'USE ?
INSERT #result (DbName, TableName, IndexName, [Rows], [FillFactor], [TimeStamp])

SELECT db_name() as DbName
,o.name as TableName
,i.name as IndexName
,i.rows as RowsCount
,i.OrigFillFactor
,GetDate() as [TimeStamp]

FROM sysindexes i
INNER JOIN sysobjects o ON i.id = o.id
WHERE i.indid > 0 and i.indid < 255
AND i.name NOT LIKE ''_WA_Sys_%'''

SELECT * FROM #Result

--Or:

 SELECT * FROM #Result WHERE DBNAME = 'mydb' AND Rows > 10000 Order BY [Fillfactor]