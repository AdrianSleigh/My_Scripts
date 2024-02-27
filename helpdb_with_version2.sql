--SQL VERSION AND DATABASE INFO
--APS 05/01/21
---------------------------------------------------------------------------------------------------
DECLARE @Version VARCHAR (14)

IF          CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like     '8%' SET @Version = 'SQL2000_(80)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like     '9%' SET @version = 'SQL2005_(90)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like  '10.0%' SET @Version = 'SQL2008_(100)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like  '10.5%' SET @Version = 'SQL2008R2_(100)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like    '11%' SET @Version = 'SQL2012_(110)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like    '12%' SET @Version = 'SQL2014_(120)'
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like    '13%' SET @Version = 'SQL2016_(130)'     
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like    '14%' SET @Version = 'SQL2017_(140)' 
    ELSE IF CONVERT(VARCHAR(128), SERVERPROPERTY ('productversion')) like    '15%' SET @Version = 'SQL2019_(150)' 
     ELSE SET @Version ='unknown'

CREATE TABLE #SQLVersion
([version] VARCHAR(14)
)
INSERT INTO #SQLVersion ([Version]) VALUES( @Version)

CREATE TABLE #HelpDB 
(
 [name] VARCHAR (80)
,[DB-Size]  VARCHAR (20)
,[Owner] VARCHAR (50)
,[dbid] SMALLINT
,[Created] VARCHAR (15)
,[Status] VARCHAR (400)
,[compatibility_Level] SMALLINT
)

INSERT INTO #HelpDB 
EXEC sp_helpdb

---------------------------------------------
SELECT a.[version]AS SQLVersion, b.[name]AS DatabaseName,b.[compatibility_level],b.[db-size],b.[owner],b.[created],b.[status]
FROM #SQLVersion A, #HelpDB B;

SELECT a.[version]AS SQLVersion, b.[name]AS DatabaseName,b.[compatibility_level]AS Not_latest_level,b.[status]
FROM #SQLVersion A, #HelpDB B
 WHERE
     version Like '%(80)' AND compatibility_level <>80 
  OR version Like '%(90)' AND compatibility_level <>90
  OR version Like '%(10%)' AND compatibility_level <>100
  OR version Like '%(110)' AND compatibility_level <>110
  OR version Like '%(120)' AND compatibility_level <>120
  OR version Like '%(130)' AND compatibility_level <>130
  OR version Like '%(140)' AND compatibility_level <>140
  OR version Like '%(150)' AND compatibility_level <>150
	  

DROP TABLE #SQLVersion
DROP TABLE #HelpDB


SELECT sqlserver_start_time FROM sys.dm_os_sys_info