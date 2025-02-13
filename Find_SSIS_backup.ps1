# Define the backup directory
$backupDirectory = "D:\SSIS_Backups"

# Ensure backup directory exists
if (-Not (Test-Path -Path $backupDirectory)) {
    New-Item -Path $backupDirectory -ItemType Directory
}

# Function to search for SSIS packages on all drives and back them up
function Backup-SSISPackagesOnAllDrives {
    # Get all drives with the FileSystem provider
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -ne $null }
    $totalFilesCopied = 0

    foreach ($drive in $drives) {
        $searchPath = "$($drive.Root)"
        Write-Output "Searching for SSIS packages in ${searchPath}"

        try {
            # Get all .dtsx files in the drive and its subdirectories, excluding the backup directory
            $ssisPackages = Get-ChildItem -Path $searchPath -Filter *.dtsx -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.FullName -notlike "$backupDirectory\*" }

            if ($ssisPackages) {
                Write-Output "Found SSIS packages in ${searchPath}:"
                $filesCopiedThisDrive = 0
                foreach ($package in $ssisPackages) {
                    $destinationPath = Join-Path -Path $backupDirectory -ChildPath $package.Name

                    # Check for duplicate names and append _1 if needed
                    $i = 1
                    while (Test-Path -Path $destinationPath) {
                        $baseName = [System.IO.Path]::GetFileNameWithoutExtension($package.Name)
                        $extension = [System.IO.Path]::GetExtension($package.Name)
                        $newName = "${baseName}_$i$extension"
                        $destinationPath = Join-Path -Path $backupDirectory -ChildPath $newName
                        $i++
                    }

                    Write-Output "Backing up ${package.FullName} to ${destinationPath}"
                    Copy-Item -Path $package.FullName -Destination $destinationPath -Force
                    $totalFilesCopied++
                    $filesCopiedThisDrive++
                }
                Write-Output "Number of SSIS packages backed up from ${searchPath}: $filesCopiedThisDrive"
            } else {
                Write-Output "No SSIS packages found in ${searchPath}."
            }
        } catch {
            Write-Output "Failed to search in ${searchPath}: $_"
        }
    }

    Write-Output "Total number of SSIS packages backed up: $totalFilesCopied"
}

# Call the function to search for SSIS packages on all drives and back them up
Backup-SSISPackagesOnAllDrives
