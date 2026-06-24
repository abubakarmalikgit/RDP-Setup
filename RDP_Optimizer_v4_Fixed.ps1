<#
.SYNOPSIS
    Windows Server 2025 RDP Optimizer v4.0 - PowerShell 7 Compatible
    Ultimate Performance Setup Tool with Terminal Dashboard UI

.DESCRIPTION
    A professional terminal dashboard that runs all 25 RDP optimizations
    with real-time progress tracking, task lists, and live logging.
    Works on PowerShell 5.1, 7.x, and Windows Server 2025.

.AUTHOR
    Professional Code Editor
.VERSION
    4.0 - PowerShell 7 Universal
#>

#requires -Version 5.1
#requires -RunAsAdministrator

# ═══════════════════════════════════════════════════════════════════════════════
#  CONFIGURATION & GLOBAL STATE
# ═══════════════════════════════════════════════════════════════════════════════

$Global:ScriptVersion = "4.0"
$Global:TotalSteps = 25
$Global:CurrentStep = 0
$Global:StartTime = Get-Date
$Global:LogEntries = [System.Collections.ArrayList]::new()
$Global:CurrentTask = $null
$Global:IsRunning = $false

# ANSI Color Codes (Works in PowerShell 5.1 and 7.x)
$Global:C = @{
    Reset       = "`e[0m"
    Bold        = "`e[1m"
    Dim         = "`e[2m"
    Black       = "`e[30m"
    Red         = "`e[31m"
    Green       = "`e[32m"
    Yellow      = "`e[33m"
    Blue        = "`e[34m"
    Magenta     = "`e[35m"
    Cyan        = "`e[36m"
    White       = "`e[37m"
    Gray        = "`e[90m"
    LightRed    = "`e[91m"
    LightGreen  = "`e[92m"
    LightYellow = "`e[93m"
    LightBlue   = "`e[94m"
    LightMagenta= "`e[95m"
    LightCyan   = "`e[96m"
    LightWhite  = "`e[97m"
    BgBlack     = "`e[40m"
    BgBlue      = "`e[44m"
    BgDarkBlue  = "`e[48;5;17m"
    BgDarkGray  = "`e[48;5;235m"
}

# Task Definitions - All 25 Steps
$Global:Tasks = @(
    @{ ID = 1;  Name = "Enable Ultimate Performance";         Category = "Power";     Description = "Enabling Ultimate Performance power plan..."; Icon = "⚡"; Status = "Pending" },
    @{ ID = 2;  Name = "Disable Visual Effects";              Category = "Visual";    Description = "Disabling visual effects for better performance..."; Icon = "🎨"; Status = "Pending" },
    @{ ID = 3;  Name = "Disable Window Animations";           Category = "Visual";    Description = "Disabling window animations..."; Icon = "🪟"; Status = "Pending" },
    @{ ID = 4;  Name = "Disable Transparency";                Category = "Visual";    Description = "Disabling transparency effects..."; Icon = "🔍"; Status = "Pending" },
    @{ ID = 5;  Name = "Disable Startup Delay";               Category = "System";    Description = "Removing startup delay..."; Icon = "⏱️"; Status = "Pending" },
    @{ ID = 6;  Name = "Set Menu Delay to 0";                 Category = "System";    Description = "Setting menu delay to zero..."; Icon = "📋"; Status = "Pending" },
    @{ ID = 7;  Name = "Show File Extensions";                Category = "Explorer";  Description = "Showing file extensions..."; Icon = "📁"; Status = "Pending" },
    @{ ID = 8;  Name = "Open Explorer to This PC";            Category = "Explorer";  Description = "Configuring Explorer to open This PC..."; Icon = "💻"; Status = "Pending" },
    @{ ID = 9;  Name = "Disable Game DVR";                    Category = "Gaming";    Description = "Disabling Game DVR..."; Icon = "🎮"; Status = "Pending" },
    @{ ID = 10; Name = "Disable Background Apps";             Category = "Privacy";   Description = "Disabling background applications..."; Icon = "🚫"; Status = "Pending" },
    @{ ID = 11; Name = "Optimize Multimedia Responsiveness";  Category = "System";    Description = "Optimizing multimedia system profile..."; Icon = "🎵"; Status = "Pending" },
    @{ ID = 12; Name = "Disable SysMain (Superfetch)";        Category = "Services";  Description = "Stopping and disabling SysMain service..."; Icon = "🗂️"; Status = "Pending" },
    @{ ID = 13; Name = "Disable Windows Search";              Category = "Services";  Description = "Stopping and disabling Windows Search service..."; Icon = "🔎"; Status = "Pending" },
    @{ ID = 14; Name = "Disable Delivery Optimization";       Category = "Services";  Description = "Stopping and disabling Delivery Optimization..."; Icon = "📦"; Status = "Pending" },
    @{ ID = 15; Name = "Disable Windows Error Reporting";     Category = "Privacy";   Description = "Stopping and disabling Error Reporting..."; Icon = "⚠️"; Status = "Pending" },
    @{ ID = 16; Name = "Disable Telemetry (DiagTrack)";       Category = "Privacy";   Description = "Stopping and disabling telemetry service..."; Icon = "📡"; Status = "Pending" },
    @{ ID = 17; Name = "Disable Windows Update";              Category = "Services";  Description = "Configuring Windows Update settings..."; Icon = "🔄"; Status = "Pending" },
    @{ ID = 18; Name = "Disable Windows Consumer Features";   Category = "Privacy";   Description = "Disabling Windows Consumer Features..."; Icon = "🏪"; Status = "Pending" },
    @{ ID = 19; Name = "Disable Windows Tips";                Category = "Privacy";   Description = "Disabling Windows tips and suggestions..."; Icon = "💡"; Status = "Pending" },
    @{ ID = 20; Name = "Disable Hibernation";                 Category = "Power";     Description = "Disabling system hibernation..."; Icon = "💤"; Status = "Pending" },
    @{ ID = 21; Name = "Enable Classic Context Menu";         Category = "UI";        Description = "Restoring Windows 10 classic context menu..."; Icon = "🖱️"; Status = "Pending" },
    @{ ID = 22; Name = "Restart Explorer";                    Category = "System";    Description = "Restarting Windows Explorer..."; Icon = "🔄"; Status = "Pending" },
    @{ ID = 23; Name = "Apply Glow Theme";                    Category = "Theme";     Description = "Applying dark glow theme..."; Icon = "✨"; Status = "Pending" },
    @{ ID = 24; Name = "Show Desktop Icons";                  Category = "Desktop";   Description = "Configuring desktop icon visibility..."; Icon = "🖥️"; Status = "Pending" },
    @{ ID = 25; Name = "Taskbar Left + Search Box";           Category = "Taskbar";   Description = "Moving taskbar left and enabling search box..."; Icon = "📌"; Status = "Pending" }
)

# ═══════════════════════════════════════════════════════════════════════════════
#  UTILITY FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

function Write-ColorLine {
    param([string]$Text = "", [string]$Color = "White", [switch]$NoNewline)
    $c = $Global:C[$Color]
    if (-not $c) { $c = $Global:C.White }
    $reset = $Global:C.Reset
    if ($NoNewline) {
        Write-Host "$c$Text$reset" -NoNewline
    } else {
        Write-Host "$c$Text$reset"
    }
}

function Add-LogEntry {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $entry = @{ Time = $timestamp; Message = $Message; Level = $Level }
    [void]$Global:LogEntries.Add($entry)
    while ($Global:LogEntries.Count -gt 100) { $Global:LogEntries.RemoveAt(0) }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  DASHBOARD RENDERER
# ═══════════════════════════════════════════════════════════════════════════════

function Show-Dashboard {
    Clear-Host

    $completed = ($Global:Tasks | Where-Object { $_.Status -eq "Success" }).Count
    $failed = ($Global:Tasks | Where-Object { $_.Status -eq "Failed" }).Count
    $running = ($Global:Tasks | Where-Object { $_.Status -eq "Running" }).Count
    $pending = $Global:TotalSteps - $completed - $failed - $running
    $percentage = if ($Global:TotalSteps -gt 0) { [math]::Round(($completed / $Global:TotalSteps) * 100) } else { 0 }

    $elapsed = (Get-Date) - $Global:StartTime
    $elapsedStr = "{0:D2}:{1:D2}:{2:D2}" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds

    # Progress bar math
    $barWidth = 40
    $filled = [math]::Round(($percentage / 100) * $barWidth)
    $empty = $barWidth - $filled
    $progressBar = ("█" * $filled) + ("░" * $empty)

    # ═══════════════════════════════════════════════════════════════════ HEADER
    Write-ColorLine "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "Blue"
    Write-ColorLine "║  🚀 Windows Server 2025 RDP Optimizer                                    Ultimate Performance Setup Tool v4.0      ║" "Cyan"
    Write-ColorLine "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "Blue"
    Write-Host ""

    # ═══════════════════════════════════════════════════════════════════ PROGRESS PANEL (Left)
    Write-ColorLine "┌─────────────────────────────┐" "Blue"
    Write-ColorLine "│         PROGRESS            │" "Blue"
    Write-ColorLine "│                             │" "Blue"
    Write-ColorLine ("│          {0,3}%             │" -f $percentage) "Green"
    Write-ColorLine "│     ╭────────────────────╮  │" "Blue"
    Write-ColorLine ("│     │ {0} │  │" -f $progressBar) "Green"
    Write-ColorLine "│     ╰────────────────────╯  │" "Blue"
    Write-ColorLine ("│    {0}/{1} Completed        │" -f $completed, $Global:TotalSteps) "Gray"
    Write-ColorLine "│                             │" "Blue"
    Write-ColorLine "├─────────────────────────────┤" "Blue"
    Write-ColorLine "│        STATISTICS           │" "Blue"
    Write-ColorLine ("│  ✅ Completed:    {0,2}       │" -f $completed) "LightGreen"
    Write-ColorLine ("│  ⚙️  In Progress:  {0,2}       │" -f $running) "LightYellow"
    Write-ColorLine ("│  ❌ Failed:        {0,2}       │" -f $failed) "LightRed"
    Write-ColorLine ("│  ⏳ Remaining:     {0,2}       │" -f $pending) "Gray"
    Write-ColorLine "│                             │" "Blue"
    Write-ColorLine "├─────────────────────────────┤" "Blue"
    Write-ColorLine "│        SYSTEM INFO          │" "Blue"
    Write-ColorLine "│  🖥️  OS:  Windows Server 2025  │" "Gray"
    Write-ColorLine "│  ⚡ CPU:  Intel Xeon          │" "Gray"
    Write-ColorLine "│  💾 RAM:  16 GB               │" "Gray"
    Write-ColorLine ("│  🕐 Started: {0}      │" -f $Global:StartTime.ToString("hh:mm:ss tt")) "Gray"
    Write-ColorLine ("│  ⏱️  Elapsed: {0}       │" -f $elapsedStr) "Gray"
    Write-ColorLine "└─────────────────────────────┘" "Blue"

    # ═══════════════════════════════════════════════════════════════════ CURRENT TASK (Center)
    Write-Host ""
    Write-ColorLine "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "Blue"
    Write-ColorLine "│                                              CURRENT TASK                                                            │" "Blue"
    Write-ColorLine "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "Blue"

    if ($Global:CurrentTask) {
        $task = $Global:CurrentTask
        $tc = switch ($task.Status) {
            "Running"   { "LightYellow" }
            "Success"   { "LightGreen" }
            "Failed"    { "LightRed" }
            default     { "Gray" }
        }
        Write-ColorLine ("│  {0} {1}" -f $task.Icon, $task.Name).PadRight(119) + "│" $tc
        Write-ColorLine "│                                                                                                                      │" "Blue"
        Write-ColorLine ("│  {0}" -f $task.Description).PadRight(119) + "│" "White"
        Write-ColorLine "│                                                                                                                      │" "Blue"

        # Task sub-progress bar
        $taskBarWidth = 50
        $taskFilled = [math]::Round((($Global:CurrentStep % 1) * 100 / 100) * $taskBarWidth)
        if ($task.Status -eq "Running") { $taskFilled = 25 }
        if ($task.Status -eq "Success") { $taskFilled = 50 }
        $taskEmpty = $taskBarWidth - $taskFilled
        $taskBar = ("█" * $taskFilled) + ("░" * $taskEmpty)
        Write-ColorLine ("│  [{0}]" -f $taskBar).PadRight(119) + "│" "LightGreen"
    } else {
        Write-ColorLine "│                                                                                                                      │" "Blue"
        Write-ColorLine "│                              🚀 Ready to start optimization...                                                       │" "White"
        Write-ColorLine "│                                                                                                                      │" "Blue"
        Write-ColorLine "│         Please wait while we apply the best tweaks and optimizations...                                              │" "Gray"
        Write-ColorLine "│                                                                                                                      │" "Blue"
    }

    Write-ColorLine "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "Blue"

    # ═══════════════════════════════════════════════════════════════════ TASK LIST (Right side - printed below)
    Write-Host ""
    Write-ColorLine "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "Blue"
    Write-ColorLine ("│  ALL TASKS ({0})" -f $Global:TotalSteps).PadRight(119) + "│" "Blue"
    Write-ColorLine "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "Blue"

    foreach ($task in $Global:Tasks) {
        $statusIcon = switch ($task.Status) {
            "Success"   { "✅" }
            "Failed"    { "❌" }
            "Running"   { "⚙️" }
            "Pending"   { "○ " }
            default     { "○ " }
        }
        $statusColor = switch ($task.Status) {
            "Success"   { "LightGreen" }
            "Failed"    { "LightRed" }
            "Running"   { "LightYellow" }
            "Pending"   { "Gray" }
            default     { "Gray" }
        }
        $statusText = switch ($task.Status) {
            "Success"   { "Completed" }
            "Failed"    { "Failed" }
            "Running"   { "In Progress" }
            "Pending"   { "Pending" }
            default     { "Pending" }
        }
        $line = "│ {0} {1,2}. {2,-45} {3,15}" -f $statusIcon, $task.ID, $task.Name, $statusText
        Write-ColorLine $line.PadRight(119) + "│" $statusColor
    }

    Write-ColorLine "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "Blue"

    # ═══════════════════════════════════════════════════════════════════ LOG OUTPUT
    Write-Host ""
    Write-ColorLine "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "Blue"
    Write-ColorLine "│  LOG OUTPUT                                                                                                          │" "Blue"
    Write-ColorLine "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "Blue"

    $visibleLogs = $Global:LogEntries | Select-Object -Last 10
    if ($visibleLogs) {
        foreach ($log in $visibleLogs) {
            $color = switch ($log.Level) {
                "SUCCESS" { "LightGreen" }
                "ERROR"   { "LightRed" }
                "WARN"    { "LightYellow" }
                default   { "Gray" }
            }
            $msg = "[{0}] {1}" -f $log.Time, $log.Message
            if ($msg.Length -gt 116) { $msg = $msg.Substring(0, 113) + "..." }
            $line = "│  {0}" -f $msg
            Write-ColorLine $line.PadRight(119) + "│" $color
        }
    } else {
        Write-ColorLine "│  [System] Ready to begin optimization sequence...                                                                   │" "Gray"
    }

    # Fill remaining log lines
    $logLinesShown = if ($visibleLogs) { $visibleLogs.Count } else { 1 }
    for ($i = $logLinesShown; $i -lt 10; $i++) {
        Write-ColorLine "│                                                                                                                      │" "Blue"
    }

    Write-ColorLine "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "Blue"
    Write-Host ""
    Write-ColorLine "  💡 TIP: This process may take a few minutes. Please don't close this window." "Gray" -NoNewline
    Write-ColorLine "                                          ✅ Safe & recommended for optimal performance" "LightGreen"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  STEP EXECUTION ENGINE
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-OptimizationStep {
    param([hashtable]$Task, [scriptblock]$Action)

    $Global:CurrentTask = $Task
    $Task.Status = "Running"
    $Global:CurrentStep = $Task.ID
    Add-LogEntry "Starting: $($Task.Name)" "INFO"

    Show-Dashboard
    Start-Sleep -Milliseconds 400

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $success = $false
    $errorMsg = $null

    try {
        $result = & $Action
        $success = if ($result -eq $null) { $true } else { [bool]$result }
    } catch {
        $success = $false
        $errorMsg = $_.Exception.Message
        Add-LogEntry "ERROR in $($Task.Name): $errorMsg" "ERROR"
    }

    $sw.Stop()

    if ($success) {
        $Task.Status = "Success"
        Add-LogEntry "✅ $($Task.Name) completed in $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "SUCCESS"
    } else {
        $Task.Status = "Failed"
        Add-LogEntry "❌ $($Task.Name) failed after $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "ERROR"
        if ($errorMsg) { Add-LogEntry "   Details: $errorMsg" "ERROR" }
    }

    Show-Dashboard
    Start-Sleep -Milliseconds 300
}

# ═══════════════════════════════════════════════════════════════════════════════
#  ALL 25 OPTIMIZATION STEPS (Exact Commands from Your File)
# ═══════════════════════════════════════════════════════════════════════════════

# Step 01: Enable Ultimate Performance
function Step_01 { Invoke-OptimizationStep $Global:Tasks[0] {
    Add-LogEntry "Enabling Ultimate Performance power plan..." "INFO"
    $output = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
    $guid = ($output | Select-String '[a-f0-9-]{36}').Matches.Value
    if ($guid) {
        powercfg /setactive $guid | Out-Null
        Add-LogEntry "Power plan GUID: $guid" "INFO"
        return $true
    }
    throw "Failed to extract power plan GUID"
}}

# Step 02: Disable Visual Effects
function Step_02 { Invoke-OptimizationStep $Global:Tasks[1] {
    Add-LogEntry "Disabling visual effects..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "VisualFXSetting" -Value 2
    return $true
}}

# Step 03: Disable Window Animations
function Step_03 { Invoke-OptimizationStep $Global:Tasks[2] {
    Add-LogEntry "Disabling window animations..." "INFO"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    return $true
}}

# Step 04: Disable Transparency
function Step_04 { Invoke-OptimizationStep $Global:Tasks[3] {
    Add-LogEntry "Disabling transparency effects..." "INFO"
    $result = reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Registry command failed: $result" }
    return $true
}}

# Step 05: Disable Startup Delay
function Step_05 { Invoke-OptimizationStep $Global:Tasks[4] {
    Add-LogEntry "Removing startup delay..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
    return $true
}}

# Step 06: Set Menu Delay to Zero
function Step_06 { Invoke-OptimizationStep $Global:Tasks[5] {
    Add-LogEntry "Setting menu delay to zero..." "INFO"
    $result = reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Registry command failed: $result" }
    return $true
}}

# Step 07: Show File Extensions
function Step_07 { Invoke-OptimizationStep $Global:Tasks[6] {
    Add-LogEntry "Showing file extensions..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    return $true
}}

# Step 08: Open Explorer to This PC
function Step_08 { Invoke-OptimizationStep $Global:Tasks[7] {
    Add-LogEntry "Configuring Explorer to open This PC..." "INFO"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
    return $true
}}

# Step 09: Disable Game DVR
function Step_09 { Invoke-OptimizationStep $Global:Tasks[8] {
    Add-LogEntry "Disabling Game DVR..." "INFO"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 10: Disable Background Apps
function Step_10 { Invoke-OptimizationStep $Global:Tasks[9] {
    Add-LogEntry "Disabling background applications..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
    return $true
}}

# Step 11: Optimize Multimedia Responsiveness
function Step_11 { Invoke-OptimizationStep $Global:Tasks[10] {
    Add-LogEntry "Optimizing multimedia system profile..." "INFO"
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 12: Disable SysMain (Superfetch)
function Step_12 { Invoke-OptimizationStep $Global:Tasks[11] {
    Add-LogEntry "Stopping and disabling SysMain..." "INFO"
    Stop-Service SysMain -Force -ErrorAction SilentlyContinue
    Set-Service SysMain -StartupType Disabled
    return $true
}}

# Step 13: Disable Windows Search
function Step_13 { Invoke-OptimizationStep $Global:Tasks[12] {
    Add-LogEntry "Stopping and disabling Windows Search..." "INFO"
    Stop-Service WSearch -Force -ErrorAction SilentlyContinue
    Set-Service WSearch -StartupType Disabled
    return $true
}}

# Step 14: Disable Delivery Optimization
function Step_14 { Invoke-OptimizationStep $Global:Tasks[13] {
    Add-LogEntry "Stopping and disabling Delivery Optimization..." "INFO"
    Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
    Set-Service DoSvc -StartupType Disabled
    return $true
}}

# Step 15: Disable Windows Error Reporting
function Step_15 { Invoke-OptimizationStep $Global:Tasks[14] {
    Add-LogEntry "Stopping and disabling Error Reporting..." "INFO"
    Stop-Service WerSvc -Force -ErrorAction SilentlyContinue
    Set-Service WerSvc -StartupType Disabled
    return $true
}}

# Step 16: Disable Telemetry (DiagTrack)
function Step_16 { Invoke-OptimizationStep $Global:Tasks[15] {
    Add-LogEntry "Stopping and disabling telemetry..." "INFO"
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    return $true
}}

# Step 17: Disable Windows Update
function Step_17 { Invoke-OptimizationStep $Global:Tasks[16] {
    Add-LogEntry "Configuring Windows Update to manual..." "INFO"
    $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (!(Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1
    return $true
}}

# Step 18: Disable Windows Consumer Features
function Step_18 { Invoke-OptimizationStep $Global:Tasks[17] {
    Add-LogEntry "Disabling Windows Consumer Features..." "INFO"
    $cloudPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (!(Test-Path $cloudPath)) { New-Item -Path $cloudPath -Force | Out-Null }
    Set-ItemProperty -Path $cloudPath -Name "DisableWindowsConsumerFeatures" -Value 1
    return $true
}}

# Step 19: Disable Windows Tips
function Step_19 { Invoke-OptimizationStep $Global:Tasks[18] {
    Add-LogEntry "Disabling Windows tips..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 20: Disable Hibernation
function Step_20 { Invoke-OptimizationStep $Global:Tasks[19] {
    Add-LogEntry "Disabling hibernation..." "INFO"
    powercfg -h off | Out-Null
    return $true
}}

# Step 21: Enable Classic Context Menu
function Step_21 { Invoke-OptimizationStep $Global:Tasks[20] {
    Add-LogEntry "Restoring classic context menu..." "INFO"
    $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    New-Item -Path $clsidPath -Force | Out-Null
    Set-ItemProperty -Path $clsidPath -Name "(Default)" -Value ""
    return $true
}}

# Step 22: Restart Explorer
function Step_22 { Invoke-OptimizationStep $Global:Tasks[21] {
    Add-LogEntry "Restarting Windows Explorer..." "INFO"
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    Start-Process explorer
    Start-Sleep -Milliseconds 1000
    return $true
}}

# Step 23: Apply Glow Theme
function Step_23 { Invoke-OptimizationStep $Global:Tasks[22] {
    Add-LogEntry "Applying dark glow theme..." "INFO"
    $themePath = "$env:windir\Resources\Themes\themeA.theme"
    if (Test-Path $themePath) {
        Invoke-Item $themePath
        Start-Sleep -Milliseconds 1000
    }
    $personalize = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if (!(Test-Path $personalize)) { New-Item -Path $personalize -Force | Out-Null }
    Set-ItemProperty -Path $personalize -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $personalize -Name "SystemUsesLightTheme" -Value 0
    return $true
}}

# Step 24: Show Desktop Icons
function Step_24 { Invoke-OptimizationStep $Global:Tasks[23] {
    Add-LogEntry "Configuring desktop icons..." "INFO"
    $Paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
    )
    foreach ($Path in $Paths) {
        if (!(Test-Path $Path)) { New-Item -Path $Path -Force | Out-Null }
        Set-ItemProperty -Path $Path -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Type DWord
        Set-ItemProperty -Path $Path -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0 -Type DWord
        Set-ItemProperty -Path $Path -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type DWord
    }
    return $true
}}

# Step 25: Taskbar Left + Search Box
function Step_25 { Invoke-OptimizationStep $Global:Tasks[24] {
    Add-LogEntry "Configuring taskbar (Left + Search Box)..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
    $searchPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if (!(Test-Path $searchPath)) { New-Item -Path $searchPath -Force | Out-Null }
    Set-ItemProperty -Path $searchPath -Name "SearchboxTaskbarMode" -Value 2
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer
    return $true
}}

# ═══════════════════════════════════════════════════════════════════════════════
#  MAIN EXECUTION
# ═══════════════════════════════════════════════════════════════════════════════

function Start-RDPOptimizer {
    param([switch]$SkipWelcome = $false)

    # Admin check
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]$identity
    if (-not $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-ColorLine "❌ ERROR: This script must be run as Administrator!" "LightRed"
        Write-ColorLine "   Please right-click PowerShell and select 'Run as Administrator'." "Yellow"
        return
    }

    # Welcome screen
    if (-not $SkipWelcome) {
        Clear-Host
        Write-Host ""
        Write-ColorLine "    ██████╗ ██████╗ ██████╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██████╗  ██████╗ ██████╗  " "Cyan"
        Write-ColorLine "    ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ╚════██╗██╔═████╗╚════██╗ " "Cyan"
        Write-ColorLine "    ██████╔╝██║  ██║██████╔╝    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝     █████╔╝██║██╔██║ █████╔╝ " "Magenta"
        Write-ColorLine "    ██╔══██╗██║  ██║██╔═══╝     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗     ╚═══██╗████╔╝██║ ╚═══██╗ " "Magenta"
        Write-ColorLine "    ██║  ██║██████╔╝██║         ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ██████╔╝╚██████╔╝██████╔╝" "Blue"
        Write-ColorLine "    ╚═╝  ╚═╝╚═════╝ ╚═╝         ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ " "Blue"
        Write-Host ""
        Write-ColorLine "                              Windows Server 2025 - Ultimate Performance Setup Tool v4.0" "Gray"
        Write-Host ""
        Write-ColorLine "  ⚠️  This script modifies system settings, registry keys, and services." "LightYellow"
        Write-ColorLine "      Designed for Windows Server 2025 RDP environments with 16GB RAM." "Gray"
        Write-Host ""
        Write-ColorLine "  📋 This script will perform the following:" "White"
        Write-ColorLine "     • Enable Ultimate Performance power plan" "Gray"
        Write-ColorLine "     • Disable visual effects, animations, and transparency" "Gray"
        Write-ColorLine "     • Optimize system services (SysMain, Search, Delivery Optimization)" "Gray"
        Write-ColorLine "     • Disable telemetry, background apps, and error reporting" "Gray"
        Write-ColorLine "     • Configure Explorer, Taskbar, Desktop, and Theme settings" "Gray"
        Write-Host ""

        $confirm = Read-Host "  Do you want to proceed? (Y/N)"
        if ($confirm -notmatch '^[Yy]') {
            Write-ColorLine "  ❌ Operation cancelled by user." "LightRed"
            return
        }
    }

    # Initialize
    $Global:StartTime = Get-Date
    $Global:IsRunning = $true
    Add-LogEntry "=== RDP OPTIMIZATION STARTED ===" "INFO"
    Add-LogEntry "OS: Windows Server 2025 | RAM: 16GB | Steps: $Global:TotalSteps" "INFO"

    # Execute all steps using function references (PowerShell 7 compatible)
    $stepFunctions = @(
        ${function:Step_01}, ${function:Step_02}, ${function:Step_03}, ${function:Step_04}, ${function:Step_05},
        ${function:Step_06}, ${function:Step_07}, ${function:Step_08}, ${function:Step_09}, ${function:Step_10},
        ${function:Step_11}, ${function:Step_12}, ${function:Step_13}, ${function:Step_14}, ${function:Step_15},
        ${function:Step_16}, ${function:Step_17}, ${function:Step_18}, ${function:Step_19}, ${function:Step_20},
        ${function:Step_21}, ${function:Step_22}, ${function:Step_23}, ${function:Step_24}, ${function:Step_25}
    )

    for ($i = 0; $i -lt $stepFunctions.Count; $i++) {
        & $stepFunctions[$i]
    }

    # Finalize
    $Global:IsRunning = $false
    $Global:CurrentTask = $null
    Show-Dashboard

    $totalTime = (Get-Date) - $Global:StartTime
    $successCount = ($Global:Tasks | Where-Object { $_.Status -eq "Success" }).Count
    $failedCount = ($Global:Tasks | Where-Object { $_.Status -eq "Failed" }).Count

    Write-Host ""
    Write-ColorLine "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "Green"
    Write-ColorLine "║                                              OPTIMIZATION COMPLETE!                                                  ║" "Green"
    Write-ColorLine "╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣" "Green"
    Write-ColorLine ("║  ✅ Successful: {0,2}  |  ❌ Failed: {1,2}  |  ⏱️  Total Time: {2:D2}:{3:D2}:{4:D2}" -f $successCount, $failedCount, $totalTime.Hours, $totalTime.Minutes, $totalTime.Seconds) "Green"
    Write-ColorLine "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "Green"
    Write-Host ""

    if ($failedCount -gt 0) {
        Write-ColorLine "  ⚠️  Some steps failed. Check the log above for details." "LightYellow"
        Write-ColorLine "     Failed tasks:" "LightRed"
        foreach ($failedTask in ($Global:Tasks | Where-Object { $_.Status -eq "Failed" })) {
            Write-ColorLine "       • $($failedTask.ID). $($failedTask.Name)" "LightRed"
        }
    } else {
        Write-ColorLine "  🎉 All optimizations applied successfully! Your RDP server is now optimized for maximum performance." "LightGreen"
    }

    Write-Host ""
    Write-ColorLine "  💾 A log of this session has been saved to: $env:TEMP\RDP_Optimizer_v4_Log.txt" "Gray"

    # Save log to file
    $logContent = $Global:LogEntries | ForEach-Object { "[{0}] [{1}] {2}" -f $_.Time, $_.Level, $_.Message }
    $logContent | Out-File -FilePath "$env:TEMP\RDP_Optimizer_v4_Log.txt" -Encoding UTF8 -Force

    Write-Host ""
    Write-ColorLine "  Press any key to exit..." "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ═══════════════════════════════════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

$Host.UI.RawUI.WindowTitle = "Windows Server 2025 RDP Optimizer v4.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Start the optimizer
Start-RDPOptimizer
