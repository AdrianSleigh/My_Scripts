--Last login and asset
--SCCM Adrian Sleigh 06/06/23

SELECT
last_logon_timestamp0,
user_name0, 
SUBSTRING(netbios_name0,5,15) AS Asset0

FROM v_R_System
WHERE SUBSTRING(netbios_name0,5,15) LIKE '91%'
and user_name0 like 'BRH3502020'
ORDER BY netbios_name0 ASC