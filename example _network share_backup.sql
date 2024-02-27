BACKUP DATABASE [ICS_Live] TO  DISK = N'\\eo-sqlag-bkups\WorthMSClust\SW-WORTH01\ICS_Live_030917_APS.bak' WITH  COPY_ONLY, FORMAT, INIT,  NAME = N'ics_live-Full Database Backup', SKIP, COMPRESSION,  STATS = 10
GO
declare @backupSetId as int
select @backupSetId = position from msdb..backupset where database_name=N'ics_live' and backup_set_id=(select max(backup_set_id) from msdb..backupset where database_name=N'ics_live' )
if @backupSetId is null begin raiserror(N'Verify failed. Backup information for database ''ics_live'' not found.', 16, 1) end
RESTORE VERIFYONLY FROM  DISK = N'\\eo-sqlag-bkups\WorthMSClust\SW-WORTH01\ICS_Live_030917_APS.bak' WITH  FILE = @backupSetId,  NOUNLOAD,  NOREWIND
GO



----mail step
send-mailmessage -to "adrian.sleigh@cheshireeast.gov.uk" `
-subject " PROD SW-WORTH01\ics_live_0080517_APS.bak  success" `
-body "The one-off backup  PROD SW-WORTH01\ics_live_0080517_APS.bak  success has completed successfully" `
-from "Backup@do.not.reply" `
-cc "SQLDBA.TEAM@cheshireeast.gov.uk" `
-smtpserver "Mailext.ourcheshire.cccusers.com"
