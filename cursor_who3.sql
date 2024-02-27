---------------------------------------------------------
--   MONITOR INSTANCE ACTIVITY OVER PERIOD
--1. SET @time BELOW ENTER FOR NUMBER OF SECONDS
--2. CHANGE WAITFOR DELAY HR:min:secs FOR SNAPSHOT TIMES
-----i.e every 20 secs would be '00:00:20' 
---------------------------------------------------------
SET NOCOUNT ON;
 DECLARE @time INT;
 SET @time = 0;
     -----set @time number of seconds required to run query
     WHILE (@time < = 1000)
 BEGIN
      WAITFOR DELAY '00:00:20'
     BEGIN TRANSACTION;

---sp_who3------------------------------------------
----------------------------------------------------
BEGIN TRANSACTION 
CREATE TABLE #sp_who3 (SPID VARCHAR(255), Status VARCHAR(255), Login VARCHAR(255), HostName VARCHAR(255), BlockedBy VARCHAR(255), DBName VARCHAR(255), Command VARCHAR(255), CPUTime INT, DiskIO INT, ActiveTime VARCHAR(1024), CurrentSQL VARCHAR(4444), SPID2 INT, REQUESTID INT)
INSERT INTO #sp_who3 EXEC sp_who2 active

UPDATE #sp_who3 SET ActiveTime = CONVERT(VARCHAR(8), GETDATE() - SUBSTRING(ActiveTime,7,14), 108), CurrentSQL = '-'

--------------------------------------------------------------------------------------
DECLARE @SpidActual VARCHAR(255)
DECLARE cursorwho3 CURSOR FOR (SELECT DISTINCT SPID FROM #sp_who3 WHERE (ActiveTime > '00:00:07') AND (Login <> 'sa') )

OPEN cursorwho3
FETCH NEXT FROM cursorwho3 INTO @SpidActual

	WHILE @@FETCH_STATUS = 0
	BEGIN
	CREATE TABLE #inputbufferTable (myEventType nvarchar(256), myParameters int, myEventInfo nvarchar(4000) )
	INSERT INTO #inputbufferTable EXEC(' BEGIN TRY
	DBCC INPUTBUFFER(' + @SpidActual + ')
	END TRY
	BEGIN CATCH
	END CATCH ' )
	UPDATE #sp_who3 SET CurrentSQL = (SELECT myEventInfo FROM #inputbufferTable) WHERE SPID = @SpidActual
	DROP TABLE #inputbufferTable
	FETCH NEXT FROM cursorwho3 INTO @SpidActual
	END

CLOSE cursorwho3
DEALLOCATE cursorwho3

------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------
SELECT getdate()as Time_stamp,ActiveTime, SPID, Login, BlockedBy, CurrentSQL, Status, Command, DBName, CPUTime, DiskIO, HostName
FROM #sp_who3
WHERE (Login <> 'sa') AND (CurrentSQL IS NOT NULL)
ORDER BY ActiveTime DESC

DROP TABLE #sp_who3
ROLLBACK TRANSACTION

   SET @time = @time + 1
  
 END
 ----------------------------------------------------------------------------------------
 ---------END----------------------------------------------------------------------------
