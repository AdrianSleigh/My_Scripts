--all users last boot date
----------------------------------------------
USE CM_SHQ 
GO
SELECT SYS.Name0 as [Computer Name], SYS.User_Name0 as [User Name], USR.Full_User_Name0 as [Full Name],
USR.mail0 as [Email Address], Convert(VarChar(10), os.LastBootUpTime0) [Last Restart Date],
OS.lastBootUpTime0 as [Last Restart], DATEDIFF(dd, LastBootUpTime0, GETDATE()) AS [Days Since Last Restart]
FROM v_R_System SYS
JOIN v_Gs_Operating_System OS on SYS.ResourceID = OS.ResourceID
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
WHERE SYS.Operating_System_Name_and0 like '%workstation%'
AND (DATEDIFF(dd, LastBootUpTime0, GETDATE())) >= 0
--and SYS.User_Name0 like 'brh3502020'
ORDER BY [Days Since Last Restart] DESC