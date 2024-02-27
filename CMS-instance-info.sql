----RUN FROM CMS TO GET SERVER INFO
----------------------------------------------------------------------
SELECT TOP (1000) a.[server_group_id]
      ,b.[server_name]
      ,a.[name]
      ,b.[name]
      ,a.[parent_id]
      ,b.[server_id]
      ,b.[description]
   
  FROM [msdb].[dbo].[sysmanagement_shared_server_groups] a
  JOIN [msdb].[dbo].[sysmanagement_shared_registered_servers] b
  ON a.[server_group_id]= b.[server_group_id]
  order by a.[server_group_id]ASC
  ----------------------------------------------------------------------