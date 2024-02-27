---------estimate backup time new added database name
-------15/05/17--------------------------------------
SELECT
     	b.name AS backing_up,
		a.estimated_completion_time /60/1000 AS mins_left,
		c.text AS query_running,
	--  a.command,
        a.start_time,
DATEADD(n,(a.estimated_completion_time /60/1000),GETDATE()) AS finish_time,
        ROUND(a.percent_complete,2) AS percent_done       
          
FROM    sys.dm_exec_requests a 
  JOIN      sys.databases b
  ON a.database_id =b.database_id
  CROSS APPLY sys.dm_exec_sql_text(a.sql_handle) c

WHERE command = 'BACKUP DATABASE' OR command = 'RESTORE DATABASE'
OR c.text LIKE '%VERIFY%'
AND b.name <> 'msdb'