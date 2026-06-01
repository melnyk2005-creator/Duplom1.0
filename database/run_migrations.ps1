# Run all migrations, triggers, procedures, functions, events (PowerShell).
# Usage: .\run_migrations.ps1 -Server "localhost" -User "root" -Database "ecommerce" -Password ""
# If mysql is not in PATH: .\run_migrations.ps1 -MySqlPath "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe"

param(
    [string]$Server = "localhost",
    [string]$User = "root",
    [string]$Database = "ecommerce",
    [string]$Password = "",
    [string]$MySqlPath = ""
)

$ErrorActionPreference = "Stop"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Resolve mysql executable
if ($MySqlPath -and (Test-Path $MySqlPath)) {
    $mysqlExe = $MySqlPath
} else {
    $mysqlExe = $null
    try { if (Get-Command mysql -ErrorAction Stop) { $mysqlExe = "mysql" } } catch { }
    if (-not $mysqlExe) {
        $commonPaths = @(
            "C:\Program Files\MySQL\MySQL Server 8.0\bin\mysql.exe",
            "C:\Program Files\MySQL\MySQL Server 8.4\bin\mysql.exe",
            "C:\xampp\mysql\bin\mysql.exe"
        )
        foreach ($p in $commonPaths) {
            if (Test-Path $p) { $mysqlExe = $p; break }
        }
    }
}
if (-not $mysqlExe) {
    Write-Error "mysql not found. Install MySQL client or run with -MySqlPath 'C:\path\to\mysql.exe'"
    exit 1
}

function Run-Sql {
    param([string]$Path)
    $args = @("-h", $Server, "-u", $User)
    if ($Password) { $args += "-p$Password" }
    $args += $Database
    Get-Content $Path -Raw | & $mysqlExe $args
}

# Migrations V001..V012
Get-ChildItem -Path "$scriptDir\migrations" -Filter "V*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Running $($_.Name)..."
    Run-Sql $_.FullName
}

# Triggers (history)
Write-Host "Running triggers_history_all.sql..."
Run-Sql "$scriptDir\triggers\triggers_history_all.sql"

# Seed test data
$seedPath = "$scriptDir\seed\seed_test_data.sql"
if (Test-Path $seedPath) {
    Write-Host "Running seed_test_data.sql..."
    Run-Sql $seedPath
} else {
    Write-Host "Seed file not found, skipping."
}

# Procedures and functions (run with delimiter; mysql may need delimiter $$ when file contains ;)
# If you get 1419/1227: enable log_bin_trust_function_creators. AWS RDS: Parameter Groups -> your group -> Edit -> log_bin_trust_function_creators = 1 -> Save, reboot instance if needed.
Get-ChildItem -Path "$scriptDir\procedures" -Filter "*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Running procedure $($_.Name)..."
    Run-Sql $_.FullName
}
Get-ChildItem -Path "$scriptDir\functions" -Filter "*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Running function $($_.Name)..."
    Run-Sql $_.FullName
}

# Events
Get-ChildItem -Path "$scriptDir\events" -Filter "*.sql" | Sort-Object Name | ForEach-Object {
    Write-Host "Running event $($_.Name)..."
    Run-Sql $_.FullName
}

Write-Host "Done."
