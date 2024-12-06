USE CM_SHQ
GO

SELECT vr.name0, MU.UserName, vu.full_user_name0, SF.FileName, SF.FileVersion,
MAX(MUS.LastUsage) as LatestDate,
GETDATE() as CurrentDate,
DATEDIFF(day,MAX(MUS.LastUsage),GETDATE())
FROM v_MeteredUser MU
INNER JOIN v_MonthlyUsageSummary MUS ON MU.MeteredUserID = MUS.MeteredUserID
INNER JOIN v_GS_SoftwareFile SF ON MUS.FileID = SF.FileID
INNER JOIN v_r_system vr on mu.username=vr.user_name0
INNER JOIN v_r_user vu on mu.username=vu.user_name0

---WHERE CLAUSE TO FILTER
WHERE sf.filename in ('VISIO.exe')

GROUP BY vr.name0,MU.UserName,vu.full_user_name0, SF.FileName, SF.FileVersion

--- NUMBER OF DAYS TO FILTER I.E. > 90

HAVING (DATEDIFF(day, MAX(MUS.LastUsage), GETDATE()) >90)
ORDER BY vr.name0,MU.UserName,vu.full_user_name0

--------------------------------------------------------
