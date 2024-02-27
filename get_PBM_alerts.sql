---PBM ALERTS LAST 4 HOURS
--Adrian Sleigh 22/04/20
------------------------------

SELECT 

 Pol.name AS Policy,   
--Cond.name AS Condition,   
PolHistDet.target_query_expression,   
PolHistDet.execution_date,   
PolHistDet.result,   
--PolHistDet.result_detail,   
PolHistDet.exception_message,   
PolHistDet.exception   
FROM msdb.dbo.syspolicy_policies AS Pol  
JOIN msdb.dbo.syspolicy_conditions AS Cond  
    ON Pol.condition_id = Cond.condition_id  
JOIN msdb.dbo.syspolicy_policy_execution_history AS PolHist  
    ON Pol.policy_id = PolHist.policy_id  
JOIN msdb.dbo.syspolicy_policy_execution_history_details AS PolHistDet  
    ON PolHist.history_id = PolHistDet.history_id  
WHERE PolHistDet.result = 0  
AND PolHistDet.execution_date >= DATEADD(HOUR, -4, GETDATE())

ORDER BY PolHistDet.execution_date DESC

--------------------------------END----------------------------------