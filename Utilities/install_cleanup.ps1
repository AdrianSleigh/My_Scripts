# -------------------------------
# SSMS 2025 Offline Install Cleanup Script
# Safe for SQL Server 2019
# -------------------------------

Write-Host "Starting SSMS cleanup..." -ForegroundColor Cyan

# 1. Uninstall all SSMS versions
$ssms = Get-WmiObject -Class Win32_Product | Where-Object {
    $_.Name -like "SQL Server Management Studio*" -or
    $_.Name -like "Microsoft SQL Server Management Studio*"
}

foreach ($app in $ssms) {
    Write-Host "Uninstalling: $($app.Name)" -ForegroundColor Yellow
    $app.Uninstall() | Out-Null
}

# 2. Uninstall Visual Studio Installer (SSMS channel only)
$vsInstaller = Get-WmiObject -Class Win32_Product | Where-Object {
    $_.Name -eq "Microsoft Visual Studio Installer"
}

foreach ($app in $vsInstaller) {
    Write-Host "Removing Visual Studio Installer..." -ForegroundColor Yellow
    $app.Uninstall() | Out-Null
}

# 3. Remove Visual Studio Shell components used by older SSMS
$vsShells = Get-WmiObject -Class Win32_Product | Where-Object {
    $_.Name -like "Microsoft Visual Studio * Shell*" -or
    $_.Name -like "Microsoft Visual Studio Setup Bootstrapper*"
}

foreach ($app in $vsShells) {
    Write-Host "Removing VS Shell component: $($app.Name)" -ForegroundColor Yellow
    $app.Uninstall() | Out-Null
}

# 4. Clear Visual Studio Installer caches
$paths = @(
    "C:\ProgramData\Microsoft\VisualStudio\Packages",
    "C:\ProgramData\Microsoft\VisualStudio\Setup",
    "C:\Program Files (x86)\Microsoft Visual Studio\Installer"
)

foreach ($path in $paths) {
    if (Test-Path $path) {
        Write-Host "Deleting: $path" -ForegroundColor Yellow
        Remove-Item -Recurse -Force $path
    }
}

Write-Host "Cleanup complete. Reboot recommended." -ForegroundColor Green
