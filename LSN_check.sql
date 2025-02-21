---CHECK  LSN
----------------------------------------------------------------------------------
SELECT 
s.database_name,
CAST(CAST(s.backup_size / 1000000 AS INT) AS VARCHAR(14)) + ' ' + 'MB' AS bkSize,
CAST(DATEDIFF(second, s.backup_start_date,
s.backup_finish_date) AS VARCHAR(4)) + ' ' + 'Seconds' TimeTaken,
s.backup_start_date,
CAST(s.first_lsn AS VARCHAR(50)) AS first_lsn,
CAST(s.last_lsn AS VARCHAR(50)) AS last_lsn,
CAST(s.database_backup_lsn AS VARCHAR(50)) AS database_backup_lsn,
CAST(s.checkpoint_lsn AS VARCHAR(50)) AS checkpoint_lsn,
CASE s.[type] WHEN 'D' THEN 'Full'
WHEN 'I' THEN 'Differential'
WHEN 'L' THEN 'Transaction Log'
END AS BackupType,
s.recovery_model
FROM msdb.dbo.backupset s
INNER JOIN msdb.dbo.backupmediafamily m ON s.media_set_id = m.media_set_id
WHERE s.database_name = DB_NAME() 
ORDER BY backup_start_date DESC, backup_finish_date
GO