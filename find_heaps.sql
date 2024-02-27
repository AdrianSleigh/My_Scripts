----FIND HEAP TABLES
----Adrian Sleigh
---------------------
SELECT T.Name 'HEAP TABLE'
FROM sys.indexes I      
    INNER JOIN sys.tables T 
        ON I.object_id = T.object_id 
WHERE I.type = 0 AND T.type = 'U'
