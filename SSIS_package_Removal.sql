 ------------TO DELETE OLD SSIS PACKAGES------------
 -----RUN BELOW TO GET NAME OF PACKAGE TO REMOVE
 --1.-------------------------------------------------
 SELECT * from msdb.dbo.sysssispackages
 --2.-------------------------------------------------
 ---- copy unwanted package namw below <Package_name_here>
SELECT 
    P.name
,   P.folderid
,   'EXECUTE msdb.dbo.sp_ssis_deletepackage @name = ''' + P.name + ''', @folderid = ''' + CAST(P.folderid as varchar(50)) + '''' AS run_me
FROM 
    dbo.sysssispackages AS P
WHERE

                 ----Enter name of package to delete below
    P.name = '<package_name_here>'

 --3.
 ----- Will generated code to delete copy\paste and run
 ------------------------------------------------------------------