USE [ZZ_WalsallMiscDbMonitor]
GO

/****** Object:  Table [dbo].[tabConnectionMonitor]    Script Date: 08/01/2021 15:55:41 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE TABLE [dbo].[tabConnectionMonitor](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoginName] [nvarchar](100) NULL,
	[Host] [nvarchar](100) NULL,
	[ProgName] [nvarchar](100) NULL,
	[DbName] [nvarchar](50) NULL,
	[Connections] [int] NULL,
	[EarliestLogin] [datetime] NULL,
	[LatestLogin] [datetime] NULL,
	[Status] [nvarchar](100) NULL
) ON [PRIMARY]
GO

