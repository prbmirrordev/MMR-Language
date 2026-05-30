$ErrorActionPreference = "Stop"

Write-Host "Installing MRR Language Settings..." -ForegroundColor Cyan

# Get current script directory
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$binDir = Join-Path $scriptDir "bin"
$mrrBat = Join-Path $binDir "mrr.bat"
$iconPath = Join-Path $scriptDir "assets\mrr.ico"

# 1. Update PATH
$userPath = [Environment]::GetEnvironmentVariable("PATH", "User")
if ($userPath -notlike "*$binDir*") {
    Write-Host "Adding MRR bin directory to User PATH..."
    $newPath = $userPath + ";" + $binDir
    [Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
} else {
    Write-Host "MRR bin directory is already in User PATH."
}

# 2. Update PATHEXT for executable
$userPathExt = [Environment]::GetEnvironmentVariable("PATHEXT", "User")
if (-not $userPathExt) {
    # If not set in User, grab from Machine
    $userPathExt = [Environment]::GetEnvironmentVariable("PATHEXT", "Machine")
}
if ($userPathExt -notlike "*.MRR*") {
    Write-Host "Adding .MRR to PATHEXT..."
    $newPathExt = $userPathExt + ";.MRR"
    [Environment]::SetEnvironmentVariable("PATHEXT", $newPathExt, "User")
} else {
    Write-Host ".MRR is already in PATHEXT."
}

# 3. File Associations and Icons in Registry
Write-Host "Configuring Registry for .mrr file association and Pentagram Icon..."

# .mrr Extension
$extKeyPath = "HKCU:\Software\Classes\.mrr"
if (-not (Test-Path $extKeyPath)) { New-Item -Path $extKeyPath -Force | Out-Null }
Set-ItemProperty -Path $extKeyPath -Name "(default)" -Value "mrr_auto_file"

# mrr_auto_file configuration
$autoFileKeyPath = "HKCU:\Software\Classes\mrr_auto_file"
if (-not (Test-Path $autoFileKeyPath)) { New-Item -Path $autoFileKeyPath -Force | Out-Null }
Set-ItemProperty -Path $autoFileKeyPath -Name "(default)" -Value "MRR Source File"

# Icon
$iconKeyPath = "HKCU:\Software\Classes\mrr_auto_file\DefaultIcon"
if (-not (Test-Path $iconKeyPath)) { New-Item -Path $iconKeyPath -Force | Out-Null }
Set-ItemProperty -Path $iconKeyPath -Name "(default)" -Value "$iconPath,0"

# Command
$cmdKeyPath = "HKCU:\Software\Classes\mrr_auto_file\shell\open\command"
if (-not (Test-Path $cmdKeyPath)) { New-Item -Path $cmdKeyPath -Force | Out-Null }
Set-ItemProperty -Path $cmdKeyPath -Name "(default)" -Value "`"$mrrBat`" `"%1`""

Write-Host "Restarting Windows Explorer to apply icon changes..."
Stop-Process -Name explorer -Force

Write-Host "==================================================" -ForegroundColor Green
Write-Host "MRR Installation Complete!" -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
Write-Host "1. .mrr files will now have a Pentagram icon."
Write-Host "2. You can run 'mrr <file>' from any command prompt."
Write-Host "3. You can execute '.mrr' files directly by typing their name if they are in PATHEXT."
Write-Host "Note: You might need to restart VS Code or your terminal to see PATH changes."
