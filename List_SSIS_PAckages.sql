__LIST ALL SSIS PACKAGES
----------------------------------------

-- List all SSIS packages stored in msdb database. 
SELECT PCK.name AS PackageName 
      ,PCK.[description] AS [Description] 
      ,FLD.foldername AS FolderName 
      ,CASE PCK.packagetype 
            WHEN 0 THEN 'Default client' 
            WHEN 1 THEN 'I/O Wizard' 
            WHEN 2 THEN 'DTS Designer' 
            WHEN 3 THEN 'Replication' 
            WHEN 5 THEN 'SSIS Designer' 
            WHEN 6 THEN 'Maintenance Plan' 
            ELSE 'Unknown' END AS PackageTye 
      ,LG.name AS OwnerName 
      ,PCK.isencrypted AS IsEncrypted 
      ,PCK.createdate AS CreateDate 
      ,CONVERT(varchar(10), vermajor) 
       + '.' + CONVERT(varchar(10), verminor) 
       + '.' + CONVERT(varchar(10), verbuild) AS Version 
      ,PCK.vercomments AS VersionComment 
      ,DATALENGTH(PCK.packagedata) AS PackageSize 

 FROM msdb.dbo.sysssispackages

 AS PCK 
     INNER JOIN msdb.dbo.sysssispackagefolders AS FLD 
         ON PCK.folderid = FLD.folderid 
     INNER JOIN sys.syslogins AS LG 
	          ON PCK.ownersid = LG.sid 
ORDER BY PCK.name;