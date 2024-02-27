---get_disabled_logins
------------------------------------------------
SELECT name, type_desc, is_disabled

FROM sys.server_principals where is_disabled = 1