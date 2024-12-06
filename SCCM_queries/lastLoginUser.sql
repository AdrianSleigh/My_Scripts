--find out last login of user Adrian Sleigh 05/02/24
---------------------------------------------------
--script1 to get the computername
SELECT  
   	   A.[Model0]AS Model
      ,A.[SystemType0]AS SystemType
	  ,A.[Name0]AS ComputerName
      ,A.[UserName0]AS UserName
      ,A.[ResourceID]
	  ,B.[Full_User_Name0]AS FullName
	  ,B.[Mail0]AS Email
	  ,B.[BAEClockNumber0]AS ClockNumber
     
 FROM [CM_SHQ].[SCCM_Ext].[vex_GS_COMPUTER_SYSTEM] A
  JOIN [CM_SHQ].[dbo].[v_R_User]B
  ON A.[UserName0]=B.[Unique_User_Name0]
    WHERE A.[UserName0]
	like '%BRH6004579'

--script2 add computer name in below script
Select vrs.Name0 as 'ComputerName', vrs.Client0 as 'Client', vrs.Operating_System_Name_and0 as 'Operating System', Vad.AgentTime as 'LastHeartBeatTime' 
from v_R_System as Vrs inner join v_AgentDiscoveries as Vad on Vrs.ResourceID=Vad.ResourceId
where vad.AgentName like '%Heartbeat Discovery'
and  vrs.Name0
like 'BRHP91004003'