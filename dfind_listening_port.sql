--FIND ACTIVE LISTENING PORT
----------------------------------------------
SET NOCOUNT ON
if(SELECT Convert(varchar(1),(SERVERPROPERTY('ProductVersion'))))=8

BEGIN

Create Table ##ErrorLog_2K

(ErrorLog nvarchar(1000),

ContinuationRow int )


INSERT INTO ##ErrorLog_2K

Exec master..xp_readerrorlog


SELECT DISTINCT @@SERVERNAME as[ServerName] , SUBSTRING(RIGHT(ErrorLog,5),1,4) as [PortNumber]

FROM ##ErrorLog_2K where ErrorLog like '%SQL Server listening on 1%'


DROP TABLE ##ErrorLog_2K

END



if(SELECT Convert(varchar(1),(SERVERPROPERTY('ProductVersion'))))<>8

BEGIN

Create Table ##ErrorLog

(Logdate datetime,

ProcessInfo nvarchar(100),

[Text] nvarchar(1000))


INSERT INTO ##ErrorLog exec master..xp_readerrorlog


SELECT DISTINCT @@SERVERNAME as[ServerName] , SUBSTRING(RIGHT(text,6),1,4) as [PortNumber]

FROM ##ErrorLog where text like 'Server is listening on % ''any'' %'


DROP TABLE ##ErrorLog

END

SET NOCOUNT OFF