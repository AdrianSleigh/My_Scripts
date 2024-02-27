--------------------------------
---------------------------------
BULK INSERT dbo.MyTable
   FROM 'c:\test\test.txt'
   WITH 
      (
         FIELDTERMINATOR ='|',
         ROWTERMINATOR =' \n'
      );