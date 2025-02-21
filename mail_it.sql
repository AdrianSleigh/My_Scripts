-- Start T-SQL

--------------------mail 

USE msdb
EXEC sp_send_dbmail 
  @profile_name='ROBOT MAIL',
  @recipients='adrian.sleigh@hmrcaspire.com',
  @copy_recipients = 'gareth.hay@hmrcaspire.com',
 -- @blind_copy_recipients ='......',
 -- @sensitivity = '..........',
  @subject='Employer Registration Automation ROBOT STATUS',
  @body='This email will be sent every 30 minutes.An XLS attachement has been included in this email.',
  @importance = 'LOW',
  @file_attachments='C:\GH\Robotics\excel_output.xls'
-- End T-SQL

---SMTP Server location  CASArray1.hmrcaspire.com port 25