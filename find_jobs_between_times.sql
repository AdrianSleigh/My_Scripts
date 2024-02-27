--FIND JOBS RUNNNG BETWEEN SET TIMES
--Adrian Sleigh 06/06/20 V1.0
------------------------------------------------------------------
SELECT 
DISTINCT a.name, 
b.run_date, CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_time,120))AS Runtime, 
                    CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_duration,120))AS Secs,
					a.description
FROM 
	msdb.dbo.sysjobs a
	JOIN  
	 msdb.dbo.sysjobhistory b
	ON a.job_id=b.job_id
	--------------------------------------------------------------LATEST TIME
	WHERE CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_time,120))<= '15:00:00:00' 
	AND
	--------------------------------------------------------------EARLIEST TIME 
	CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_time,120))>= '12:00:00:00' 

	GROUP BY a.name,b.run_date,CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_time,120)),CONVERT(VARCHAR(5) ,CONVERT(Varchar(10), b.run_duration,120)),
	a.description