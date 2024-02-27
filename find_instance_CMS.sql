---LOOK FOR AN INSTANCE RUN AGAINST CMS
----Adrian Sleigh 02/03/18
Declare
@findserver varchar (50),
@sqlversion varchar (50)
     SET @findserver =  @@servername 
        SET @sqlversion =  @@version
              
        BEGIN
        select @findserver + '   ' + @sqlversion as Instance_Version
              where @findserver like '%S01%' 
         END  
