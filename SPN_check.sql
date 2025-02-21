--Check SPN is used
SELECT auth_scheme FROM sys.dm_exec_connections WHERE session_id = @@spid ;

----determine authentication method
SELECT net_transport, auth_scheme   
FROM sys.dm_exec_connections   
WHERE session_id = @@SPID;  




