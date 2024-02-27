--FIND BAD SQL PASSWORDS
--24/03/21
-------------------------------------------------------
IF OBJECT_ID('tempdb..#weakpasswords') IS NOT NULL
	DROP TABLE #weakpasswords;
create table #weakpasswords ([ServerName] sysname
							,[LoginName] sysname
							,[Password] varchar(max)
							,default_database_name sysname
							,is_policy_checked int
							,is_expiration_checked int
							,database_owner varchar(max))

DECLARE @WeakPwdList TABLE (WeakPwd NVARCHAR(255))
--Define weak password list
--Use @@Name if users password contain their name
-- Ref: http://security.blogoverflow.com/category/password/
-- Ref: http://www.smartplanet.com/blog/business-brains/the-25-worst-passwords-of-2011-8216password-8216123456-8242/20065
INSERT INTO @WeakPwdList (WeakPwd)
SELECT * from bad_passwords

--


insert into #weakpasswords
SELECT @@servername AS [ServerName]
	,sql_logins.NAME AS [LoginName]
	,CASE 
		WHEN PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME)), password_hash) = 0
			THEN REPLACE(t2.WeakPwd, '@@Name', sql_logins.NAME)
		ELSE REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME))
		END AS [Password]
	,sql_logins.default_database_name
	,sql_logins.is_policy_checked
	,sql_logins.is_expiration_checked
	--,sql_logins.is_disabled
	,(
		SELECT suser_sname(owner_sid)
		FROM sys.databases
		WHERE databases.NAME = sql_logins.default_database_name
		) AS database_owner
FROM sys.sql_logins
INNER JOIN @WeakPwdList t2 ON (
		PWDCOMPARE(t2.WeakPwd, password_hash) = 1
		OR PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', sql_logins.NAME), password_hash) = 1
		OR PWDCOMPARE(REPLACE(t2.WeakPwd, '@@Name', REVERSE(sql_logins.NAME)), password_hash) = 1
		)
WHERE sql_logins.is_disabled = 0
ORDER BY sql_logins.NAME

--- report the weak passwords that we found
select * from #weakpasswords