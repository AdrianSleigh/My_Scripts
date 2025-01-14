--------REPORTING SERVICES--QUERYING
---------------------------------------------------- 
SET NOCOUNT ON
/****** LOCATION OF REPORTS  ******/

PRINT 'SSRS REPORT----------------------------------------------------------------'
SELECT  GEtdate()AS Date_Ran,
    SUBSTRING([MachineName],1,30) AS SSRS_Source,
	SUBSTRING([InstanceName],1,20)AS Instance_name
    FROM [ReportServer].[dbo].[Keys]
	WHERE [MachineName]
	IS NOT NULL
----------------------------------------------------
SELECT
    CASE CL.Type
        WHEN 1 THEN 'Folder'
        WHEN 2 THEN 'Report'
        WHEN 3 THEN 'Resource'
        WHEN 4 THEN 'Linked Report'
        WHEN 5 THEN 'Data Source'
    END                                 AS ObjectType,
    SUBSTRING(CP.Name,1,10)             AS ParentName,
    SUBSTRING(CL.Name,1,50)             AS Name,
    SUBSTRING(CL.Path,1,80)             AS Path,
    SUBSTRING(CU.UserName,1,20)         AS CreatedBy,
    CL.CreationDate                     AS CreationDate,
    SUBSTRING(UM.UserName,1,20)         AS ModifiedBy,
    CL.ModifiedDate                     AS ModifiedDate,
    CE.CountStart                       AS TotalExecutions,
    SUBSTRING(EL.UserName,1,30)         AS LastExecuter,
    EL.Format                           AS LastFormat,
    EL.TimeStart                        AS LastTimeStarted,
    EL.TimeEnd                          AS LastTimeEnded,
    EL.TimeDataRetrieval                AS LastTimeDataRetrieval,
    EL.TimeProcessing                   AS LastTimeProcessing,
    EL.TimeRendering                    AS LastTimeRendering,
    EL.Status                           AS LastResult,
    EL.ByteCount                        AS LastByteCount,
    EL.[RowCount]                       AS LastRowCount,
    SUBSTRING(SO.UserName,1,30)         AS SubscriptionOwner,
    SUBSTRING(SU.UserName,1,30)         AS SubscriptionModifiedBy,
    SS.ModifiedDate                     AS SubscriptionModifiedDate,
    SUBSTRING(SS.Description,1,90)      AS SubscriptionDescription,
    SUBSTRING(SS.LastStatus,1,90)       AS SubscriptionLastResult,
    SS.LastRunTime                      AS SubscriptionLastRunTime
FROM Catalog CL
JOIN Catalog CP
    ON CP.ItemID = CL.ParentID
JOIN Users CU
    ON CU.UserID = CL.CreatedByID
JOIN Users UM
    ON UM.UserID = CL.ModifiedByID
LEFT JOIN ( SELECT
                ReportID,
                MAX(TimeStart) LastTimeStart
            FROM ExecutionLog
            GROUP BY ReportID) LE
    ON LE.ReportID = CL.ItemID
LEFT JOIN ( SELECT
                ReportID,
                COUNT(TimeStart) CountStart
            FROM ExecutionLog
            GROUP BY ReportID) CE
    ON CE.ReportID = CL.ItemID
LEFT JOIN ExecutionLog EL
    ON EL.ReportID = LE.ReportID
    AND EL.TimeStart = LE.LastTimeStart
LEFT JOIN Subscriptions SS
    ON SS.Report_OID = CL.ItemID
LEFT JOIN Users SO
    ON SO.UserID = SS.OwnerID
LEFT JOIN Users SU
    ON SU.UserID = SS.ModifiedByID
WHERE 1 = 1
ORDER BY CP.Name, CL.Name ASC

----------------------------------------------------------