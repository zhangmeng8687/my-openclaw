<#
.SYNOPSIS
    ACE (AntiCheatExpert) Comprehensive Monitor
.DESCRIPTION
    Monitors all ACE activities and logs to a single file.
    Run as Administrator.
#>

$LogFile = "C:\Users\Administrator\.openclaw\workspace\ace_monitor.log"
$CheckInterval = 10  # seconds

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $ts = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $line = "[$ts] [$Level] $Message"
    Add-Content -Path $LogFile -Value $line -Encoding UTF8
    Write-Host $line
}

Write-Log "========== ACE Monitor Started =========="
Write-Log "Log file: $LogFile"
Write-Log "Check interval: ${CheckInterval}s"

# Snapshot states for change detection
$prevProcesses = @()
$prevServices = @{}
$prevDrivers = @{}
$lastEventId = 0

# ACE related names
$aceProcessNames = @('ACE', 'AntiCheat', 'TenProtect', 'SGuard', 'ace_guard')
$aceServiceNames = @('AntiCheatExpert Protection', 'AntiCheatExpert Service', 'ACE-SSC-DRV64')
$aceDriverNames = @('ACE-ADVT', 'ACE-BOOT', 'ACE-CORE102706', 'ACE-CORE202706', 'ACE-CORE302706', 'ACE-GAME', 'ACE-SSC-DRV64')
$acePaths = @(
    'C:\Program Files\AntiCheatExpert',
    'C:\Program Files\Common Files\Tencent',
    'C:\Program Files (x86)\Common Files\Tencent',
    'C:\ProgramData\AntiCheatExpert',
    'C:\ProgramData\Tencent'
)

# File system watcher for ACE directories
$watchers = @()
foreach ($path in $acePaths) {
    if (Test-Path $path) {
        try {
            $watcher = New-Object System.IO.FileSystemWatcher
            $watcher.Path = $path
            $watcher.IncludeSubdirectories = $true
            $watcher.EnableRaisingEvents = $true
            $watcher.NotifyFilter = [System.IO.NotifyFilters]::FileName -bor [System.IO.NotifyFilters]::LastWrite -bor [System.IO.NotifyFilters]::Size

            $action = {
                $details = $Event.SourceEventArgs
                $type = $details.ChangeType
                $file = $details.FullPath
                Write-Log "FILE_$type : $file" "WATCH"
            }

            Register-ObjectEvent $watcher "Created" -Action $action | Out-Null
            Register-ObjectEvent $watcher "Changed" -Action $action | Out-Null
            Register-ObjectEvent $watcher "Deleted" -Action $action | Out-Null
            Register-ObjectEvent $watcher "Renamed" -Action $action | Out-Null
            $watchers += $watcher
            Write-Log "Watching directory: $path"
        } catch {
            Write-Log "Failed to watch: $path - $_" "WARN"
        }
    }
}

# ACE event log provider names to watch
$aceProviders = @('ACE', 'AntiCheatExpert', 'ACE-BOOT', 'ACE-CORE', 'ACE-GAME', 'ACE-SSC-DRV64')

Write-Log "Monitoring started. Press Ctrl+C to stop."

while ($true) {
    try {
        # 1. Check Processes
        $currentProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
            $name = $_.ProcessName
            $aceProcessNames | Where-Object { $name -match $_ }
        } | ForEach-Object { "$($_.Id):$($_.ProcessName)" }

        $newProcs = $currentProcs | Where-Object { $_ -notin $prevProcesses }
        $goneProcs = $prevProcesses | Where-Object { $_ -notin $currentProcs }

        foreach ($p in $newProcs) { Write-Log "PROCESS_STARTED : $p" "CHANGE" }
        foreach ($p in $goneProcs) { Write-Log "PROCESS_ENDED   : $p" "CHANGE" }
        $prevProcesses = $currentProcs

        # 2. Check Services
        $currentSvcs = Get-Service -ErrorAction SilentlyContinue | Where-Object {
            $aceServiceNames -contains $_.Name -or $_.Name -match 'ACE|AntiCheat'
        }
        foreach ($svc in $currentSvcs) {
            $prev = $prevServices[$svc.Name]
            if ($null -eq $prev) {
                Write-Log "SERVICE_INIT : $($svc.Name) = $($svc.Status)" "INFO"
            } elseif ($prev -ne $svc.Status) {
                Write-Log "SERVICE_CHANGE: $($svc.Name) $prev -> $($svc.Status)" "CHANGE"
            }
            $prevServices[$svc.Name] = $svc.Status
        }

        # 3. Check Drivers
        $currentDrivers = Get-WmiObject Win32_SystemDriver -ErrorAction SilentlyContinue | Where-Object {
            $aceDriverNames -contains $_.Name
        }
        foreach ($drv in $currentDrivers) {
            $prev = $prevDrivers[$drv.Name]
            if ($null -eq $prev) {
                Write-Log "DRIVER_INIT : $($drv.Name) = $($drv.State)" "INFO"
            } elseif ($prev -ne $drv.State) {
                Write-Log "DRIVER_CHANGE: $($drv.Name) $prev -> $($drv.State)" "CHANGE"
            }
            $prevDrivers[$drv.Name] = $drv.State
        }

        # 4. Check Event Logs (System + Application)
        $events = Get-WinEvent -FilterHashtable @{LogName='System'; StartTime=(Get-Date).AddSeconds(-($CheckInterval + 5))} -MaxEvents 50 -ErrorAction SilentlyContinue
        $events += Get-WinEvent -FilterHashtable @{LogName='Application'; StartTime=(Get-Date).AddSeconds(-($CheckInterval + 5))} -MaxEvents 50 -ErrorAction SilentlyContinue

        $aceEvents = $events | Where-Object {
            $_.ProviderName -match 'ACE|AntiCheat' -or $_.Message -match 'ACE|AntiCheatExpert|AntiCheat'
        } | Sort-Object RecordId

        foreach ($evt in $aceEvents) {
            if ($evt.RecordId -gt $lastEventId) {
                $level = switch ($evt.LevelDisplayName) {
                    "Error" { "ERROR" }
                    "Warning" { "WARN" }
                    default { "EVENT" }
                }
                Write-Log "EVENT_LOG : [$($evt.ProviderName)] ID=$($evt.Id) | $($evt.Message)" $level
                $lastEventId = $evt.RecordId
            }
        }

        # 5. Check disk activity (perf counter - ACE related IO)
        $aceProcs = Get-Process -ErrorAction SilentlyContinue | Where-Object {
            $name = $_.ProcessName
            $aceProcessNames | Where-Object { $name -match $_ }
        }
        foreach ($ap in $aceProcs) {
            $io = $ap.IO
            if ($io) {
                Write-Log "PROCESS_IO : $($ap.ProcessName) PID=$($ap.Id) ReadBytes=$($io.ReadBytes) WriteBytes=$($io.WriteBytes) ReadOps=$($io.ReadOperations) WriteOps=$($io.WriteOperations)" "METRIC"
            }
        }

    } catch {
        Write-Log "Monitor error: $_" "ERROR"
    }

    Start-Sleep -Seconds $CheckInterval
}
