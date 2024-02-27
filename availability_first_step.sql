--put first step in availability jobs to determin whether or not to continue
---------------------------------------------------------------------------
IF (SELECT ars.role_desc
    FROM sys.dm_hadr_availability_replica_states ars
    INNER JOIN sys.availability_groups ag
    ON ars.group_id = ag.group_id
    AND ars.is_local = 1) <> 'PRIMARY'
BEGIN
   --We're on the secondary node, throw an error
   THROW 50001, 'Unable to execute job on secondary node',1
END