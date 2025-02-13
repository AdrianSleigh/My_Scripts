# Adrian Sleigh 31/01/2025 Function to search for SSIS packages on all drives
function Search-SSISPackagesOnAllDrives {
    # Get all drives with the FileSystem provider
    $drives = Get-PSDrive -PSProvider FileSystem | Where-Object { $_.Root -ne $null }
    
    foreach ($drive in $drives) {
        $searchPath = "$($drive.Root)"
        Write-Output "Searching for SSIS packages in ${searchPath}"
        
        try {
            # Get all .dtsx files in the drive and its subdirectories
            $ssisPackages = Get-ChildItem -Path $searchPath -Filter *.dtsx -Recurse -ErrorAction SilentlyContinue
            
            if ($ssisPackages) {
                Write-Output "Found SSIS packages in ${searchPath}:"
                foreach ($package in $ssisPackages) {
                    Write-Output $package.FullName
                }
            } else {
                Write-Output "No SSIS packages found in ${searchPath}."
            }
        } catch {
            Write-Output "Failed to search in ${searchPath}: $_"
        }
    }
}

# Call the function to search for SSIS packages on all drives
Search-SSISPackagesOnAllDrives
