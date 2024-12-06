---SCCM users [CM_SHQ]
SELECT SYS.User_Name0 as Login, USR.Mail0 as 'EMail ID', SYS.Netbios_Name0 as Machine,
Operating_System_Name_and0 as OS FROM v_R_System SYS
JOIN v_R_User USR on USR.User_Name0 = SYS.User_Name0
--WHERE SYS.User_Name0 LIKE 'Username'
ORDER BY SYS.User_Name0, SYS.Netbios_Name0


---SCCM info [CM_SHQ]
SELECT DISTINCT
SYS.Netbios_Name0,
SYS.User_Name0,OPSYS.InstallDate0 as InitialInstall, BIOS.SerialNumber0,
CSYS.Model0,
MEM.TotalPhysicalMemory0, HWSCAN.LastHWScan,
ASSG.SMS_Installed_Sites0,
MAX(IPSub.IP_Subnets0) as 'Subnet',
OPSYS.Caption0 as 'OS Name',
MAX(SYSOU.System_OU_Name0) as 'OU'

FROM v_R_System as SYS
JOIN v_RA_System_SMSInstalledSites as ASSG on SYS.ResourceID=ASSG.ResourceID
LEFT JOIN v_RA_System_IPSubnets IPSub on SYS.ResourceID = IPSub.ResourceID
LEFT JOIN v_GS_X86_PC_MEMORY MEM on SYS.ResourceID = MEM.ResourceID
LEFT JOIN v_GS_COMPUTER_SYSTEM CSYS on SYS.ResourceID = CSYS.ResourceID
LEFT JOIN v_GS_PROCESSOR Processor on Processor.ResourceID = SYS.ResourceID
LEFT JOIN v_GS_OPERATING_SYSTEM OPSYS on SYS.ResourceID=OPSYS.ResourceID
LEFT JOIN v_GS_WORKSTATION_STATUS HWSCAN on SYS.ResourceID = HWSCAN.ResourceID
LEFT JOIN v_GS_LastSoftwareScan SWSCAN on SYS.ResourceID = SWSCAN.ResourceID
LEFT JOIN v_GS_PC_BIOS BIOS on SYS.ResourceID = BIOS.ResourceID
LEFT JOIN v_RA_System_SystemOUName SYSOU on SYS.ResourceID=SYSOU.ResourceID
LEFT JOIN v_R_User USR on SYS.User_Name0 = USR.User_Name0
LEFT JOIN v_FullCollectionMembership FCM on FCM.ResourceID = SYS.ResourceID
WHERE SYS.Obsolete0 = 0
--AND FCM.CollectionID = 'Collection ID'
GROUP BY SYS.Netbios_Name0, SYS.Obsolete0,SYS.Resource_Domain_OR_Workgr0,
CSYS.Manufacturer0, CSYS.Model0, BIOS.SerialNumber0,OPSYS.InstallDate0,HWSCAN.LastHWScan, MEM.TotalPhysicalMemory0,
SYS.User_Name0, SYS.User_Domain0,
ASSG.SMS_Installed_Sites0, SYS.Client_Version0, OPSYS.Caption0
ORDER BY OPSYS.InstallDate0 DESC