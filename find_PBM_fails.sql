
----FIND PBM FAILS-------------------------------------------------
----Adrian Sleigh 30/04/20-----------------------------------------
USE MSDB
GO
SELECT DISTINCT
 a.[policy_id],a.[condition_id],a.[name],a.[description],a.[is_enabled],
 b.[start_date],b.[result]AS 'Failed PBM',
 c.[target_query_expression],c.[target_query_expression_with_id],a.[date_created]
 
 FROM syspolicy_policies a
 JOIN syspolicy_policy_execution_history b
 ON a.[policy_id] = b.[policy_id]
 JOIN syspolicy_system_health_state c
 ON b.[policy_id] = c.[policy_id]

 WHERE is_enabled =1 
 AND b.[result] = 0
 GROUP BY a.[policy_id],a.[condition_id],a.[name],a.[description],a.[is_enabled],b.[start_date],
          b.[result],a.[date_created],c.[target_query_expression],c.[target_query_expression_with_id]
 ORDER BY start_date DESC
-----------------------------------------------------------------------------

