---DAC connection port
-------------------------------------
DECLARE @InstanceName nvarchar(50)

DECLARE @value VARCHAR(100)

DECLARE @RegKey_InstanceName nvarchar(500)

DECLARE @RegKey nvarchar(500)


SET @InstanceName=CONVERT(nVARCHAR,isnull(SERVERPROPERTY('INSTANCENAME'),'MSSQLSERVER'))


--For SQL Server 2000

if(SELECT Convert(varchar(1),(SERVERPROPERTY('ProductVersion'))))=8

BEGIN

if @InstanceName='MSSQLSERVER'

Begin

SET @RegKey='SOFTWARE\Microsoft\'+@InstanceName+'\MSSQLServer\SuperSocketNetLib\TCP\'

END

ELSE

BEGIN

SET @RegKey='SOFTWARE\Microsoft\Microsoft SQL Server\'+@InstanceName+'\MSSQLServer\SuperSocketNetLib\TCP\'

END


EXECUTE xp_regread

  @rootkey = 'HKEY_LOCAL_MACHINE',

  @key = @RegKey,

  @value_name = 'TcpPort',

  @value = @value OUTPUT

  

Select @@SERVERNAME as ServerName,@value as DACPort

END


--For SQL Server 2005 and up

if(SELECT Convert(varchar(1),(SERVERPROPERTY('ProductVersion'))))<>8

BEGIN

SET @RegKey_InstanceName='SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL'


EXECUTE xp_regread

  @rootkey = 'HKEY_LOCAL_MACHINE',

  @key = @RegKey_InstanceName,

  @value_name = @InstanceName,

  @value = @value OUTPUT


SET @RegKey='SOFTWARE\Microsoft\Microsoft SQL Server\'+@value+'\MSSQLServer\SuperSocketNetLib\AdminConnection\TCP\'

EXECUTE xp_regread

  @rootkey = 'HKEY_LOCAL_MACHINE',

  @key = @RegKey,

  @value_name = 'TcpDynamicPorts',

  @value = @value OUTPUT

 
Select @@SERVERNAME as ServerName,@value as DACPort

END