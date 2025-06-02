# Define variables
$SQLInstance = "Inst1"  # Default instance, update if necessary
$LogFile = "C:\software\SQLUpgrade.log"
$InstallMedia = "C:\software\setup.exe"

# Function to log messages
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Check current SQL Server version
Write-Log "Checking installed SQL Server version..."
$SQLVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" | ForEach-Object {
    Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$($_.MSSQLSERVER)\Setup"
}).Version

if ($SQLVersion -like "13.*") {
    Write-Log "SQL Server 2016 detected. Proceeding with upgrade..."
    
    # Execute SQL Server 2019 upgrade
    $UpgradeArgs = "/QUIET /ACTION=Upgrade /INSTANCENAME=$SQLInstance /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled=True"
    
    Write-Log "Starting SQL Server 2019 upgrade..."
    Start-Process -FilePath $InstallMedia -ArgumentList $UpgradeArgs -Wait -NoNewWindow
    
    Write-Log "Upgrade process completed. Check logs for any issues."
} else {
    Write-Log "SQL Server 2016 NOT found. Upgrade aborted."
}
