#get SQL version installed 
# Define the registry path for SSRS
$regPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\"

# Get all installed instances
$instances = Get-ChildItem -Path $regPath -Name

# Iterate through each instance to find SSRS
foreach ($instance in $instances) {
    $ssrsRegPath = "HKLM:\SOFTWARE\Microsoft\Microsoft SQL Server\$instance\Setup"
    if (Test-Path $ssrsRegPath) {
        $ssrsVersion = Get-ItemProperty -Path $ssrsRegPath -Name Version
        Write-Host "SSRS Instance: $instance, Version: $($ssrsVersion.Version)"
    }
}
