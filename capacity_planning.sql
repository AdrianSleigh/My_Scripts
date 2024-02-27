/* Database Capacity planning last 12 months

---script1--
 T-SQL script - Analyses database growth using backup information -Last (12) months 
 Looks only to FULL backups information
*/

SET NOCOUNT ON
DECLARE @endDate datetime, @months smallint; 
SET @endDate = GetDate();  -- Date actual
SET @months = 12;          -- months

;WITH HIST AS 
   (SELECT BS.database_name AS DatabaseName 
          ,YEAR(BS.backup_start_date) * 100 
           + MONTH(BS.backup_start_date) AS YearMonth 
          ,CONVERT(numeric(10, 1), MIN(BS.backup_size / 1048576.0)) AS MinSizeMB 
          ,CONVERT(numeric(10, 1), MAX(BS.backup_size / 1048576.0)) AS MaxSizeMB 
          ,CONVERT(numeric(10, 1), AVG(BS.backup_size / 1048576.0)) AS AvgSizeMB 
    FROM msdb.dbo.backupset as BS 
    WHERE NOT BS.database_name IN 
              ('Master', 'Msdb', 'Model', 'Tempdb','SQLMonitoring') 
          AND BS.type = 'D' 
          AND BS.backup_start_date BETWEEN DATEADD(mm, - @months, @endDate) AND     @endDate 
    GROUP BY BS.database_name 
            ,YEAR(BS.backup_start_date) 
            ,MONTH(BS.backup_start_date)) 
SELECT @@SERVERNAME AS SQL_Instance
      ,MAIN.DatabaseName 
      ,MAIN.YearMonth 
      ,MAIN.MinSizeMB 
      ,MAIN.MaxSizeMB 
      ,MAIN.AvgSizeMB 
      ,MAIN.AvgSizeMB  
       - (SELECT TOP 1 SUB.AvgSizeMB 
          FROM HIST AS SUB 
          WHERE SUB.DatabaseName = MAIN.DatabaseName 
                AND SUB.YearMonth < MAIN.YearMonth 
          ORDER BY SUB.YearMonth DESC) AS GrowthMB 
FROM HIST AS MAIN 
ORDER BY MAIN.DatabaseName 
        ,MAIN.YearMonth
DECLARE @startDate DATETIME;

---script2 Database growth over months 0 being current month

SET @startDate = GetDate();

SELECT @@SERVERNAME AS SQL_Instance,
     PVT.DatabaseName
    ,PVT.[0],PVT.[-1],PVT.[-2],PVT.[-3],PVT.[-4],PVT.[-5],PVT.[-6],PVT.[-7],PVT.[-8],PVT.[-9],PVT.[-10],PVT.[-11],PVT.[-12]
FROM (
    SELECT BS.database_name AS DatabaseName
        ,DATEDIFF(mm, @startDate, BS.backup_start_date) AS MonthsAgo
        ,CONVERT(NUMERIC(10, 1), AVG(BF.file_size / 1048576.0)) AS AvgSizeMB
    FROM msdb.dbo.backupset AS BS
    INNER JOIN msdb.dbo.backupfile AS BF ON BS.backup_set_id = BF.backup_set_id
    WHERE BS.database_name NOT IN ('Master','Msdb','Model','Tempdb','SQL_Monitoring')
        AND BS.database_name IN (
            SELECT db_name(database_id)
            FROM master.SYS.DATABASES
            WHERE state_desc = 'ONLINE'
            )
        AND BF.[file_type] = 'D'
        AND BS.backup_start_date BETWEEN DATEADD(yy, - 1, @startDate)
            AND @startDate
    GROUP BY BS.database_name
        ,DATEDIFF(mm, @startDate, BS.backup_start_date)
    ) AS BCKSTAT
PIVOT(SUM(BCKSTAT.AvgSizeMB) FOR BCKSTAT.MonthsAgo IN (
            [0],[-1],[-2],[-3],[-4],[-5],[-6],[-7],[-8],[-9],[-10],[-11],[-12]
            )) AS PVT
ORDER BY PVT.DatabaseName;

------------------------------------------------------------------