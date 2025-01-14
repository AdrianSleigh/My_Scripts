----SCCM query find all SQL instances and version
SELECT DISTINCT
                      v_R_System_Valid.Netbios_Name0 AS [Computer Name], v_GS_OPERATING_SYSTEM.Caption0 AS [Operating System],
                      v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName AS [Product Name],
                      CASE WHEN (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedPublisher IS NULL OR
                      v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedPublisher = '-1')
                      THEN 'Unknown' ELSE v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedPublisher END AS Publisher,
                      CASE WHEN (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedVersion IS NULL OR
                      v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedVersion = '-1')
                      THEN 'Unknown' ELSE v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedVersion END AS Version,
                      CASE WHEN (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallDate0 IS NULL)
                      THEN 'Unknown' ELSE CAST(v_GS_INSTALLED_SOFTWARE_CATEGORIZED.InstallDate0 AS varchar) END AS [Install Date]
FROM         v_GS_INSTALLED_SOFTWARE_CATEGORIZED INNER JOIN
                      v_R_System_Valid ON v_R_System_Valid.ResourceID = v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID INNER JOIN
                      v_GS_OPERATING_SYSTEM ON v_GS_INSTALLED_SOFTWARE_CATEGORIZED.ResourceID = v_GS_OPERATING_SYSTEM.ResourceID
WHERE     (v_GS_OPERATING_SYSTEM.Caption0 LIKE '%server%') AND (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName LIKE '%SQL%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%arcserve%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%hotfix%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%books%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%Tools%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%Compatibility%') AND
                      (v_GS_INSTALLED_SOFTWARE_CATEGORIZED.NormalizedName NOT LIKE '%setup support%')
ORDER BY [Computer Name], [Product Name], Publisher, Version

-------------------------------------------------------------------------------------
--Get user assets
-------------------------------------------------------------------------------------
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
    WHERE A.[UserName0] IS NOT NULL AND [Model0] LIKE '%HP%'