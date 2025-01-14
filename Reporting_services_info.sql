--------REPORTING SERVICES--QUERYING
---------------------------------------------------- 
SELECT
    CL.Name                     AS ReportName,
    CL.Description              AS ReportDescription,
    CL.Path                     AS ReportPath,
    CL.CreationDate             AS ReportCreationDate,
    SUM(1)                      AS TotalNumberOfTimesExecuted,
    MAX(EL.TimeStart)           AS LastTimeExecuted,
    AVG(EL.[RowCount])          AS AVG_NumberOfRows,
    AVG(EL.TimeDataRetrieval)   AS AVG_DataRetrievalTime,
    AVG(EL.TimeProcessing)      AS AVG_TimeProcessing,
    AVG(EL.TimeRendering)       AS AVG_TimeRendering
FROM ExecutionLog EL
JOIN Catalog CL
    ON CL.ItemID = EL.ReportID
WHERE 1 = 1
AND CL.Name IS NOT NULL
AND EL.Status ='rsSuccess'
GROUP BY
    CL.Name,
    CL.Path,
    CL.CreationDate,
    CL.Description
HAVING YEAR(MAX(EL.TimeStart)) = 2017
ORDER BY COUNT(EL.ReportID) DESC
-------------------------------------------------------
SELECT TOP 1000
    EL.InstanceName             AS SQLInstanceName,
    EL.UserName                 AS ExecuterUserName,
    EL.Format                   AS ReportFormat,
    EL.Parameters               AS ReportParameters,
    EL.TimeStart                AS TimeStarted,
    EL.TimeEnd                  AS TimeEnded,
    EL.TimeDataRetrieval        AS TimeDataRetrieval,
    EL.TimeProcessing           AS TimeProcessing,
    EL.TimeRendering            AS TimeRendering,
    EL2.Source                  AS Source,
    EL.ByteCount                AS ReportInBytes,
    EL.[RowCount]               AS ReportRows,
    CL.Name                     AS ReportName,
    CL.Path                     AS ReportPath,
    CL.Hidden                   AS ReportHidden,
    CL.CreationDate             AS CreationDate,
    CL.ModifiedDate             AS ModifiedDate,
    EL2.Format                  AS RenderingFormat,
    EL2.ReportAction            AS ReportAction,
    EL2.Status                  AS ExectionResult,
    DS.Name                     AS DataSourceName,
    DS.Extension                AS DataSourceExtension
FROM ExecutionLog EL
JOIN Catalog CL
    ON CL.ItemID = EL.ReportID
LEFT JOIN ExecutionLog2 EL2
    ON EL2.ReportPath = CL.Path
JOIN DataSource DS
    ON DS.ItemID = CL.ItemID
WHERE 1 = 1
AND EL.Status = 'rsSuccess'
ORDER BY EL.TimeStart DESC
----------------------------------------------
SELECT
    CASE CL.Type
        WHEN 1 THEN 'Folder'
        WHEN 2 THEN 'Report'
        WHEN 3 THEN 'Resource'
        WHEN 4 THEN 'Linked Report'
        WHEN 5 THEN 'Data Source'
    END                                 AS ObjectType,
    CP.Name                             AS ParentName,
    CL.Name                             AS Name,
    CL.Path                             AS Path,
    CU.UserName                         AS CreatedBy,
    CL.CreationDate                     AS CreationDate,
    UM.UserName                         AS ModifiedBy,
    CL.ModifiedDate                     AS ModifiedDate,
    CE.CountStart                       AS TotalExecutions,
    EL.InstanceName                     AS LastExecutedInstanceName,
    EL.UserName                         AS LastExecuter,
    EL.Format                           AS LastFormat,
    EL.TimeStart                        AS LastTimeStarted,
    EL.TimeEnd                          AS LastTimeEnded,
    EL.TimeDataRetrieval                AS LastTimeDataRetrieval,
    EL.TimeProcessing                   AS LastTimeProcessing,
    EL.TimeRendering                    AS LastTimeRendering,
    EL.Status                           AS LastResult,
    EL.ByteCount                        AS LastByteCount,
    EL.[RowCount]                       AS LastRowCount,
    SO.UserName                         AS SubscriptionOwner,
    SU.UserName                         AS SubscriptionModifiedBy,
    SS.ModifiedDate                     AS SubscriptionModifiedDate,
    SS.Description                      AS SubscriptionDescription,
    SS.LastStatus                       AS SubscriptionLastResult,
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