--WHAT IS HITTING CPU CURRENTLY ---LOOPS FOR 2MINS EVERY 2 SECS
--Adrian Sleigh 05/07/19
----------------------------------------------------------------
DECLARE @intflag INT
SET @intflag = 0
WHILE (@intflag <= 60)
BEGIN
select * from master..sysprocesses
where status = 'runnable' --comment this out
order by CPU
desc
select * from master..sysprocesses
order by CPU
desc
WAITFOR DELAY '00:00:02'
SET @intflag = @intflag + 1
print @intflag
END
---------------------------------------------------------------