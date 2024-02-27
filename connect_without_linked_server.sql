---CONNECT WITHOUT LINKED SERVER
---SET SECURITY REMOVE ADHOC QUERY
---------------------------------------------------
EXEC SP_configure 'Ad Hoc Distributed Queries','1'
RECONFIGURE

---QUERYY HERE---------------------------------
SELECT  * 
 FROM    OPENROWSET ('SQLOLEDB','Server=sqltest64\test2,22005;UID=topdog;PWD=topdog',
   'SELECT  @@servername as server_name') 
 AS tbl

 --RESET SECURITY DENY ADHOC QUERY
 EXEC SP_configure 'Ad Hoc Distributed Queries','0'
RECONFIGURE