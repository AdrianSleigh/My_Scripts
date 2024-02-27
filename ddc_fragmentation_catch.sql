USE [master]
GO
/****** Object:  Table [dbo].[db_Fragmentation]    Script Date: 05/07/2016 12:33:49 ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[db_Fragmentation]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[db_Fragmentation](
	[Polltime] [datetime] NOT NULL,
	[Dbname] [nvarchar](50) NOT NULL,
	[table_name] [nvarchar](50) NOT NULL,
	[Index_name] [nvarchar](50) NULL,
	[FragPCT] [decimal](6, 2) NOT NULL,
	[Page_Count] [int] NOT NULL
) ON [PRIMARY]
END
GO
-------------------------------------------------------------------------------------
INSERT
INTO  master.dbo.db_Fragmentation

SELECT	
  current_timestamp as [DATE]
  , DB_NAME() as [DATABASE]
  , OBJECT_NAME(s.[object_id])as [TABLE_NAME]
  , i.name as [INDEX_NAME]
  , ROUND(s.avg_fragmentation_in_percent,2)as [%_FRAGMENTED]
  , PAGE_COUNT 
FROM sys.dm_db_index_physical_stats(db_id(),null, null, null, null) s
INNER JOIN sys.indexes i ON s.[object_id] = i.[object_id] AND s.index_id = i.index_id
INNER JOIN sys.objects o ON i.object_id = o.object_id
 WHERE i.name IS NOT NULL
 AND PAGE_COUNT >2000 
 AND ROUND(s.avg_fragmentation_in_percent,2)>4
 ORDER BY  PAGE_COUNT DESC;