USE [ZZ_WalsallMiscDbMonitor]
GO
/****** Object:  StoredProcedure [dbo].[spRW_ConnectionMonitor]    Script Date: 08/01/2021 15:52:15 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


-- =============================================
-- Author:		ARW
-- Create date: 2018/11/20
-- Description:	Connection Monitor
-- =============================================
ALTER PROCEDURE [dbo].[spRW_ConnectionMonitor] 
	-- Add the parameters for the stored procedure here
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

-- Create the data table if its not already there
	IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = object_id(N'dbo.tabConnectionMonitor') and OBJECTPROPERTY(id, N'IsTable') = 1)
	BEGIN
		CREATE TABLE dbo.tabConnectionMonitor
		(
			[ID] [int]		IDENTITY(1,1) NOT NULL,
--			SessId			INT,
			LoginName		NVARCHAR(100),
			Host			NVARCHAR(100),
			ProgName		NVARCHAR(100),
			DbName			NVARCHAR(50),
			Connections		INT,
			EarliestLogin	DATETIME,
			LatestLogin		DATETIME,
			[Status]		NVARCHAR(100)
		)
	END

-- Create a temporary store for extract
	IF OBJECT_ID('tempdb..#tabConnMon') IS NULL
	BEGIN
		CREATE TABLE #tabConnMon
		(
			[ID] [int]		IDENTITY(1,1) NOT NULL,
--			SessId			INT,
			LoginName		NVARCHAR(100),
			Host			NVARCHAR(100),
			ProgName		NVARCHAR(100),
			DbName			NVARCHAR(50),
			Connections		INT,
			EarliestLogin	DATETIME,
			LatestLogin		DATETIME,
			[Status]		NVARCHAR(100)
		)
	END

-- Extract from system tables to temp table grouping by user, host, prog
	BEGIN
		INSERT INTO
			#tabConnMon
		(
--			SessId,
			LoginName,
			Host,
			ProgName,
			DbName,
			Connections,
			EarliestLogin,
			LatestLogin,
			[Status]
		)
		SELECT
--			A.spid,
			LEFT(ISNULL(A.loginame, ''), 100) AS LoginName,
			LEFT(ISNULL(A.hostname, ''), 100) AS Host,
			LEFT(ISNULL(B.program_name, ''), 100),
			DB_NAME(LEFT(ISNULL(A.dbid, ''), 50)) AS DBName, 
			COUNT(A.dbid) AS NumberOfConnections,
			MIN(A.login_time) AS EarliestLogin,
			MAX(A.login_time) AS LatestLogin,
			LEFT(A.status, 100) AS Status
		FROM
			sys.sysprocesses AS A
		LEFT OUTER JOIN
            sys.dm_exec_sessions AS B
		ON
			A.spid = B.session_id
		WHERE 
			A.dbid > 0
		GROUP BY 
--			A.spid,
			A.dbid, A.hostname, B.program_name, A.loginame, A.status
	END

-- Save results to data table without duplicating Login, Host, Prog and DbName
	BEGIN
		INSERT INTO
			dbo.tabConnectionMonitor
		(
--			SessId,
			LoginName,
			Host,
			ProgName,
			DbName,
			Connections,
			EarliestLogin,
			LatestLogin,
			[Status]
		)
		SELECT
--			#tabConnMon.SessId,
			#tabConnMon.LoginName,
			#tabConnMon.Host,
			#tabConnMon.ProgName,
			#tabConnMon.DbName,
			#tabConnMon.Connections,
			#tabConnMon.EarliestLogin,
			#tabConnMon.LatestLogin,
			#tabConnMon.[Status]
		FROM
			#tabConnMon
		LEFT OUTER JOIN
            tabConnectionMonitor
		ON
			#tabConnMon.LoginName = dbo.tabConnectionMonitor.LoginName
		AND
			#tabConnMon.Host = dbo.tabConnectionMonitor.Host
		AND 
			#tabConnMon.ProgName = dbo.tabConnectionMonitor.ProgName
		AND
			#tabConnMon.DbName = dbo.tabConnectionMonitor.DbName
		WHERE
			(dbo.tabConnectionMonitor.ID IS NULL)
	END

 -- Update latest login and status where login, host, prog and db are the same
	BEGIN
		UPDATE
			dbo.tabConnectionMonitor
		SET
			dbo.tabConnectionMonitor.LatestLogin = dbo.#tabConnMon.LatestLogin,
			dbo.tabConnectionMonitor.Status = dbo.#tabConnMon.Status
		FROM
			dbo.tabConnectionMonitor
		INNER JOIN
			dbo.#tabConnMon
		ON
			dbo.tabConnectionMonitor.LoginName = dbo.#tabConnMon.LoginName
		AND
			dbo.tabConnectionMonitor.Host = dbo.#tabConnMon.Host
		AND 
			dbo.tabConnectionMonitor.ProgName = dbo.#tabConnMon.ProgName
		AND 
			dbo.tabConnectionMonitor.DbName = dbo.#tabConnMon.DbName
	END

--SELECT * FROM dbo.tabConnectionMonitor

-- Remove temp table
	BEGIN
		IF OBJECT_ID('tempdb..#tabConnMon') IS NOT NULL DROP TABLE #tabConnMon
	END
END
