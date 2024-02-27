--FIND ALL INSTANCES ON SERVER
--APS 11/01/21
------------------------------
Set NoCount On
Declare @CurrID int,@ExistValue int, @MaxID int, @SQL nvarchar(1000)
Declare @TCPPorts Table (PortType nvarchar(180), Port int)
Declare @SQLInstances Table (InstanceID int identity(1, 1) not null primary key,
                                          InstName nvarchar(180),
                                          Folder nvarchar(50),
                                          StaticPort int null,
                                          DynamicPort int null,
                                          Platform int null);
Declare @Plat Table (Id int,Name varchar(180),InternalValue varchar(50), Charactervalue varchar (50))
Declare @Platform varchar(100)
Insert into @Plat exec xp_msver platform
select @Platform = (select 1 from @plat where charactervalue like '%86%')
If @Platform is NULL
Begin
Insert Into @SQLInstances (InstName, Folder)
Exec xp_regenumvalues N'HKEY_LOCAL_MACHINE',
                             N'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL';
Update @SQLInstances set Platform=64
End
else
Begin
Insert Into @SQLInstances (InstName, Folder)
Exec xp_regenumvalues N'HKEY_LOCAL_MACHINE',
                             N'SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL';
Update @SQLInstances Set Platform=32
End  
 
Declare @Keyexist Table (Keyexist int)
Insert into @Keyexist
Exec xp_regread'HKEY_LOCAL_MACHINE',
                              N'SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\Instance Names\SQL';
select @ExistValue= Keyexist from @Keyexist
If @ExistValue=1
Insert Into @SQLInstances (InstName, Folder)
Exec xp_regenumvalues N'HKEY_LOCAL_MACHINE',
                              N'SOFTWARE\Wow6432Node\Microsoft\Microsoft SQL Server\Instance Names\SQL';
Update @SQLInstances Set Platform =32 where Platform is NULL
 
Select @MaxID = MAX(InstanceID), @CurrID = 1
From @SQLInstances
While @CurrID <= @MaxID
  Begin
      Delete From @TCPPorts
     
      Select @SQL = 'Exec xp_instance_regread N''HKEY_LOCAL_MACHINE'',
                              N''SOFTWARE\Microsoft\\Microsoft SQL Server\' + Folder + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'',
                              N''TCPDynamicPorts'''
      From @SQLInstances
      Where InstanceID = @CurrID
     
      Insert Into @TCPPorts
      Exec sp_executesql @SQL
     
      Select @SQL = 'Exec xp_instance_regread N''HKEY_LOCAL_MACHINE'',
                              N''SOFTWARE\Microsoft\\Microsoft SQL Server\' + Folder + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'',
                              N''TCPPort'''
      From @SQLInstances
      Where InstanceID = @CurrID
     
 
      Insert Into @TCPPorts
      Exec sp_executesql @SQL
 
      Select @SQL = 'Exec xp_instance_regread N''HKEY_LOCAL_MACHINE'',
                              N''SOFTWARE\Wow6432Node\Microsoft\\Microsoft SQL Server\' + Folder + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'',
                              N''TCPDynamicPorts'''
      From @SQLInstances
      Where InstanceID = @CurrID
     
      Insert Into @TCPPorts
      Exec sp_executesql @SQL
     
      Select @SQL = 'Exec xp_instance_regread N''HKEY_LOCAL_MACHINE'',
                              N''SOFTWARE\Wow6432Node\Microsoft\\Microsoft SQL Server\' + Folder + '\MSSQLServer\SuperSocketNetLib\Tcp\IPAll'',
                              N''TCPPort'''
      From @SQLInstances
      Where InstanceID = @CurrID
     
 
      Insert Into @TCPPorts
      Exec sp_executesql @SQL
 
     
      Update SI
      Set StaticPort = P.Port,
            DynamicPort = DP.Port
      From @SQLInstances SI
      Inner Join @TCPPorts DP On DP.PortType = 'TCPDynamicPorts'
      Inner Join @TCPPorts P On P.PortType = 'TCPPort'
      Where InstanceID = @CurrID;
     
      Set @CurrID = @CurrID + 1
  End
 
Select serverproperty('ComputerNamePhysicalNetBIOS') as ServerName, InstName, StaticPort, DynamicPort,Platform
From @SQLInstances
Set NoCount Off