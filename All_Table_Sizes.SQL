-------ALL Table sizes
-------------------------------------------
CREATE TABLE #TableSizes
(

           TableName NVARCHAR(255),
           TableRows INT,
           ReservedSpaceKB VARCHAR(20),
           DataSpaceKB VARCHAR(20),
           IndexSizeKB VARCHAR(20),
           UnusedSpaceKB VARCHAR(20)

)

INSERT INTO #TableSizes
 EXEC sp_msforeachtable 'sp_spaceused ''?'''
   SELECT * FROM #TableSizes
ORDER BY TableRows DESC
DROP TABLE #TableSizes