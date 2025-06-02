# Define variables
$SQLInstance = "MSSQLSERVER"
$AGName = "YourAvailabilityGroupName"
$LogFile = "C:\software\SQLUpgrade.log"
$InstallMedia = "C:\software\setup.exe"

# Function to log messages
function Write-Log {
    param ([string]$Message)
    $TimeStamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "$TimeStamp - $Message" | Out-File -Append -FilePath $LogFile
}

# Function to execute SQL commands with error handling
function Execute-SqlCmd {
    param ([string]$Query)
    try {
        Invoke-Sqlcmd -ServerInstance $SQLInstance -Query $Query -ErrorAction Stop
    } catch {
        Write-Log "ERROR: SQL command failed - $($_.Exception.Message)"
        throw $_.Exception.Message
    }
}

# Check SQL Server version
Write-Log "Checking installed SQL Server version..."
try {
    $SQLVersion = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\Instance Names\SQL" | ForEach-Object {
        Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$($_.MSSQLSERVER)\Setup"
    }).Version
} catch {
    Write-Log "ERROR: Unable to fetch SQL Server version - $($_.Exception.Message)"
    exit 1
}

if ($SQLVersion -like "13.*") {
    Write-Log "SQL Server 2016 detected. Proceeding with AG checks..."

    # Check Availability Group status
    Write-Log "Checking Availability Group status..."
    try {
        $AGInfo = Execute-SqlCmd -Query "SELECT replica_server_name, role_desc, synchronization_state_desc FROM sys.dm_hadr_availability_replica_states WHERE group_id = (SELECT group_id FROM sys.availability_groups WHERE name = '$AGName');"
    } catch {
        Write-Log "ERROR: Unable to fetch Availability Group information."
        exit 1
    }

    $PrimaryReplica = $AGInfo | Where-Object { $_.role_desc -eq "PRIMARY" }
    $SecondaryReplica = $AGInfo | Where-Object { $_.role_desc -eq "SECONDARY" -and $_.synchronization_state_desc -eq "SYNCHRONIZED" }

    if ($PrimaryReplica -and $SecondaryReplica) {
        Write-Log "Primary replica is '$($PrimaryReplica.replica_server_name)', failover is possible."

        # Perform failover to secondary replica
        Write-Log "Failing over to secondary replica '$($SecondaryReplica.replica_server_name)'..."
        try {
            Execute-SqlCmd -Query "ALTER AVAILABILITY GROUP [$AGName] FAILOVER;"
            Write-Log "Failover successful."
        } catch {
            Write-Log "ERROR: Failover failed."
            exit 1
        }

        # Execute SQL Server 2019 upgrade
        Write-Log "Starting SQL Server 2019 upgrade..."
        try {
            Start-Process -FilePath $InstallMedia -ArgumentList "/QUIET /ACTION=Upgrade /INSTANCENAME=$SQLInstance /IACCEPTSQLSERVERLICENSETERMS /UpdateEnabled=True" -Wait -NoNewWindow
            Write-Log "Upgrade process completed successfully."
        } catch {
            Write-Log "ERROR: SQL Server upgrade failed."
            exit 1
        }
    } else {
        Write-Log "Availability Group failover not possible. Upgrade aborted."
        exit 1
    }
} else {
    Write-Log "SQL Server 2016 NOT found. Upgrade aborted."
    exit 1
}
