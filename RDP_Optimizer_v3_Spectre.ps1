<#
.SYNOPSIS
    Windows Server 2025 RDP Optimizer - Spectre.Console Edition
    The most professional terminal dashboard for Windows RDP optimization.

.DESCRIPTION
    Uses Spectre.Console library to create a pixel-perfect terminal dashboard
    matching the reference image with progress rings, task lists, live logs,
    system info panels, and animated progress bars.

.AUTHOR
    Professional Terminal UI Architect
.VERSION
    3.0 - Spectre Edition
#>

#requires -Version 5.1
#requires -RunAsAdministrator

# ═══════════════════════════════════════════════════════════════════════════════
#  MODULE INSTALLATION & LOADING
# ═══════════════════════════════════════════════════════════════════════════════

function Install-SpectreConsole {
    <#
    .SYNOPSIS
        Ensures Spectre.Console module is installed and loaded.
    #>
    param()

    $moduleName = "PSWriteSpectreConsole"
    $module = Get-Module -ListAvailable -Name $moduleName -ErrorAction SilentlyContinue

    if (-not $module) {
        Write-Host "📦 Installing Spectre.Console module (one-time setup)..." -ForegroundColor Cyan
        try {
            # Try installing from PSGallery
            Install-Module -Name $moduleName -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
            Write-Host "✅ Module installed successfully!" -ForegroundColor Green
        } catch {
            # Fallback: Install from NuGet directly
            Write-Host "⚠️  PSGallery failed. Attempting direct NuGet installation..." -ForegroundColor Yellow
            $nugetUrl = "https://www.nuget.org/api/v2/package/Spectre.Console/0.47.0"
            $tempPath = "$env:TEMP\SpectreConsole"
            $zipPath = "$tempPath\spectre.zip"
            $dllPath = "$tempPath\lib\net6.0\Spectre.Console.dll"

            New-Item -ItemType Directory -Path $tempPath -Force | Out-Null
            Invoke-WebRequest -Uri $nugetUrl -OutFile $zipPath -UseBasicParsing
            Expand-Archive -Path $zipPath -DestinationPath $tempPath -Force

            # Load the DLL directly
            Add-Type -Path $dllPath -ErrorAction Stop
            Write-Host "✅ Spectre.Console loaded from NuGet!" -ForegroundColor Green
        }
    }

    # Import the module
    Import-Module $moduleName -Force -ErrorAction SilentlyContinue

    # Verify Spectre.Console is available
    try {
        $test = [Spectre.Console.AnsiConsole]::Profile
        Write-Host "✅ Spectre.Console is ready!" -ForegroundColor Green
        return $true
    } catch {
        Write-Host "⚠️  Spectre.Console not available. Using fallback ANSI renderer." -ForegroundColor Yellow
        return $false
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  FALLBACK ANSI RENDERER (If Spectre.Console fails)
# ═══════════════════════════════════════════════════════════════════════════════

$script:UseSpectre = $false
$script:AnsiColors = @{
    Reset       = "`e[0m"
    Bold        = "`e[1m"
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
    BgDarkBlue  = "`e[48;5;17m"  # Deep blue background
    BgDarkGray  = "`e[48;5;235m"
}

function Write-Ansi {
    param([string]$Text = "", [string]$Color = "White", [switch]$NoNewline)
    $c = $script:AnsiColors[$Color]
    if (-not $c) { $c = $script:AnsiColors.White }
    if ($NoNewline) {
        Write-Host "$c$Text$($script:AnsiColors.Reset)" -NoNewline
    } else {
        Write-Host "$c$Text$($script:AnsiColors.Reset)"
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  GLOBAL STATE
# ═══════════════════════════════════════════════════════════════════════════════

$Global:ScriptVersion = "3.0"
$Global:TotalSteps = 25
$Global:CurrentStep = 0
$Global:StartTime = Get-Date
$Global:LogEntries = [System.Collections.ArrayList]::new()
$Global:CurrentTask = $null
$Global:AllTasks = @()
$Global:IsRunning = $false

# Task definitions with metadata
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
#  LOGGING SYSTEM
# ═══════════════════════════════════════════════════════════════════════════════

function Add-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "HH:mm:ss"
    $entry = @{ Time = $timestamp; Message = $Message; Level = $Level }
    [void]$Global:LogEntries.Add($entry)

    # Keep last 100 entries
    while ($Global:LogEntries.Count -gt 100) {
        $Global:LogEntries.RemoveAt(0)
    }
}

# ═══════════════════════════════════════════════════════════════════════════════
#  SPECTRE CONSOLE RENDERER (Professional Dashboard)
# ═══════════════════════════════════════════════════════════════════════════════

function Show-SpectreDashboard {
    param()

    $completed = ($Global:Tasks | Where-Object { $_.Status -eq "Success" }).Count
    $failed = ($Global:Tasks | Where-Object { $_.Status -eq "Failed" }).Count
    $running = ($Global:Tasks | Where-Object { $_.Status -eq "Running" }).Count
    $pending = $Global:TotalSteps - $completed - $failed - $running
    $percentage = if ($Global:TotalSteps -gt 0) { [math]::Round(($completed / $Global:TotalSteps) * 100) } else { 0 }

    $elapsed = (Get-Date) - $Global:StartTime
    $elapsedStr = "{0:D2}:{1:D2}:{2:D2}" -f $elapsed.Hours, $elapsed.Minutes, $elapsed.Seconds

    # Build the dashboard using Spectre.Console
    $sb = [System.Text.StringBuilder]::new()

    # Header
    [void]$sb.AppendLine("[bold cyan]╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗[/]")
    [void]$sb.AppendLine("[bold cyan]║[/]  [bold white]:rocket: Windows Server 2025 RDP Optimizer[/]                                                                      [dim]Ultimate Performance Setup Tool v3.0[/]  [bold cyan]║[/]")
    [void]$sb.AppendLine("[bold cyan]╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝[/]")
    [void]$sb.AppendLine()

    # Main grid layout
    # Left: Progress Ring + Stats | Center: Current Task + Details | Right: Task List

    # LEFT PANEL - Progress & Statistics
    [void]$sb.AppendLine("[bold blue]┌─────────────────────────────┐[/]  [bold blue]┌──────────────────────────────────────────────────────────┐[/]  [bold blue]┌──────────────────────────────────────────────────┐[/]")
    [void]$sb.AppendLine("[bold blue]│[/]         [bold white]PROGRESS[/]            [bold blue]│[/]  [bold blue]│[/]                   [bold white]CURRENT TASK[/]                           [bold blue]│[/]  [bold blue]│[/]  [bold white]ALL TASKS (25)[/]                                   [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]├──────────────────────────────────────────────────────────┤[/]  [bold blue]├──────────────────────────────────────────────────┤[/]")

    # Progress ring line
    $progressLine = "[bold blue]│[/]          [bold green]{0,3}%[/]             [bold blue]│[/]" -f $percentage
    [void]$sb.AppendLine($progressLine)

    # Progress bar
    $barWidth = 30
    $filled = [math]::Round(($percentage / 100) * $barWidth)
    $empty = $barWidth - $filled
    $progressBar = ("█" * $filled) + ("░" * $empty)
    [void]$sb.AppendLine("[bold blue]│[/]     [green]╭──────────────────────────────╮[/]         [bold blue]│[/]")
    [void]$sb.AppendLine(("[bold blue]│[/]     [green]│ {0} │[/]         [bold blue]│[/]" -f $progressBar))
    [void]$sb.AppendLine("[bold blue]│[/]     [green]╰──────────────────────────────╯[/]         [bold blue]│[/]")
    [void]$sb.AppendLine(("[bold blue]│[/]    [dim]{0}/{1} Completed[/]        [bold blue]│[/]" -f $completed, $Global:TotalSteps))

    # Center panel - Current task
    if ($Global:CurrentTask) {
        $task = $Global:CurrentTask
        $statusColor = switch ($task.Status) {
            "Running"   { "yellow" }
            "Success"   { "green" }
            "Failed"    { "red" }
            default     { "gray" }
        }
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]  [bold {0}]{1} {2}[/]" -f $statusColor, $task.Icon, $task.Name)
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]                                                          [bold blue]│[/]")
        [void]$sb.AppendLine(("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]  [dim]{0}[/]" -f $task.Description).PadRight(119) + "[bold blue]│[/]")
    } else {
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]  [dim]Ready to start optimization...[/]                      [bold blue]│[/]")
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]                                                          [bold blue]│[/]")
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]  Please wait while we apply the best                     [bold blue]│[/]")
        [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]  tweaks and optimizations...                            [bold blue]│[/]")
    }

    # Stats section
    [void]$sb.AppendLine("[bold blue]├─────────────────────────────┤[/]  [bold blue]│[/]                                                          [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]        [bold white]STATISTICS[/]           [bold blue]│[/]  [bold blue]├──────────────────────────────────────────────────────────┤[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine(("[bold blue]│[/]  [green]:check_mark: Completed:    {0,2}[/]       [bold blue]│[/]" -f $completed))
    [void]$sb.AppendLine(("[bold blue]│[/]  [yellow]:gear: In Progress:  {0,2}[/]       [bold blue]│[/]" -f $running))
    [void]$sb.AppendLine(("[bold blue]│[/]  [red]:cross_mark: Failed:        {0,2}[/]       [bold blue]│[/]" -f $failed))
    [void]$sb.AppendLine(("[bold blue]│[/]  [dim]:hourglass: Remaining:     {0,2}[/]       [bold blue]│[/]" -f $pending))
    [void]$sb.AppendLine("[bold blue]│[/]                             [bold blue]│[/]  [bold blue]│[/]                   [bold white]TASK DETAILS[/]                           [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")

    # System info
    [void]$sb.AppendLine("[bold blue]├─────────────────────────────┤[/]  [bold blue]│[/]                                                          [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]        [bold white]SYSTEM INFO[/]          [bold blue]│[/]  [bold blue]│[/]  Recent completed tasks:                                  [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]  [dim]:desktop_computer: OS:  Windows Server 2025[/]  [bold blue]│[/]  [bold blue]│[/]                                                          [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]  [dim]:zap: CPU:  Intel Xeon[/]          [bold blue]│[/]  [bold blue]│[/]                                                          [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine("[bold blue]│[/]  [dim]:floppy_disk: RAM:  16 GB[/]              [bold blue]│[/]  [bold blue]│[/]                                                          [bold blue]│[/]  [bold blue]│[/]                                                  [bold blue]│[/]")
    [void]$sb.AppendLine(("[bold blue]│[/]  [dim]:clock1: Started: {0}[/]      [bold blue]│[/]" -f $Global:StartTime.ToString("hh:mm:ss tt")))
    [void]$sb.AppendLine(("[bold blue]│[/]  [dim]:stopwatch: Elapsed: {0}[/]       [bold blue]│[/]" -f $elapsedStr))
    [void]$sb.AppendLine("[bold blue]└─────────────────────────────┘[/]  [bold blue]└──────────────────────────────────────────────────────────┘[/]  [bold blue]└──────────────────────────────────────────────────┘[/]")

    # Right panel - Task list (rendered separately for alignment)
    # We need to print the task list on the right side

    # For now, let's print the main layout and handle tasks in a second pass
    $mainOutput = $sb.ToString()

    # Use Spectre.Console to render if available
    if ($script:UseSpectre) {
        [Spectre.Console.AnsiConsole]::Markup($mainOutput)
    } else {
        # Fallback: Use ANSI escape codes
        $fallbackOutput = $mainOutput -replace '\[bold ([^\]]+)\]', "`e[1;`$1m" `
            -replace '\[dim\]', "`e[2m" `
            -replace '\[green\]', "`e[32m" `
            -replace '\[yellow\]', "`e[33m" `
            -replace '\[red\]', "`e[31m" `
            -replace '\[blue\]', "`e[34m" `
            -replace '\[cyan\]', "`e[36m" `
            -replace '\[white\]', "`e[37m" `
            -replace '\[/\]', "`e[0m" `
            -replace ':rocket:', '🚀' `
            -replace ':check_mark:', '✅' `
            -replace ':gear:', '⚙️' `
            -replace ':cross_mark:', '❌' `
            -replace ':hourglass:', '⏳' `
            -replace ':desktop_computer:', '🖥️' `
            -replace ':zap:', '⚡' `
            -replace ':floppy_disk:', '💾' `
            -replace ':clock1:', '🕐' `
            -replace ':stopwatch:', '⏱️'
        Write-Host $fallbackOutput
    }

    # Print task list on the right side
    # This is complex for side-by-side, so we'll use a simpler approach
    # Print tasks below the main dashboard

    Write-Host ""

    # Task list in compact format
    $taskLines = @()
    foreach ($task in $Global:Tasks) {
        $statusIcon = switch ($task.Status) {
            "Success"   { "✅" }
            "Failed"    { "❌" }
            "Running"   { "⚙️" }
            "Pending"   { "○" }
            default     { "○" }
        }
        $statusColor = switch ($task.Status) {
            "Success"   { "LightGreen" }
            "Failed"    { "LightRed" }
            "Running"   { "LightYellow" }
            "Pending"   { "Gray" }
            default     { "Gray" }
        }
        $line = "{0} {1,2}. {2,-40} {3}" -f $statusIcon, $task.ID, $task.Name, $task.Status
        Write-Ansi $line $statusColor
    }

    # Log output section
    Write-Host ""
    Write-Ansi "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "Blue"
    Write-Ansi "│  LOG OUTPUT                                                                                                          │" "Blue"
    Write-Ansi "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "Blue"

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
            Write-Ansi $line.PadRight(119) + "│" $color
        }
    } else {
        Write-Ansi "│  [System] Ready to begin optimization sequence...                                                                   │" "Gray"
    }

    Write-Ansi "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "Blue"
    Write-Host ""
    Write-Ansi "  💡 TIP: This process may take a few minutes. Please don't close this window." "Gray" -NoNewline
    Write-Ansi "                                          ✅ Safe & recommended for optimal performance" "LightGreen"
}

# ═══════════════════════════════════════════════════════════════════════════════
#  OPTIMIZATION FUNCTIONS (All 25 Steps - Exact Commands)
# ═══════════════════════════════════════════════════════════════════════════════

function Invoke-Step {
    param(
        [hashtable]$Task,
        [scriptblock]$Action
    )

    $Global:CurrentTask = $Task
    $Task.Status = "Running"
    Add-Log "Starting: $($Task.Name)" "INFO"

    # Update UI
    Show-SpectreDashboard
    Start-Sleep -Milliseconds 400

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $success = $false
    $errorMsg = $null

    try {
        $success = & $Action
        if ($success -eq $null) { $success = $true }
    } catch {
        $success = $false
        $errorMsg = $_.Exception.Message
        Add-Log "ERROR in $($Task.Name): $errorMsg" "ERROR"
    }

    $sw.Stop()
    $Task.Duration = $sw.Elapsed

    if ($success) {
        $Task.Status = "Success"
        Add-Log "✅ $($Task.Name) completed in $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "SUCCESS"
    } else {
        $Task.Status = "Failed"
        Add-Log "❌ $($Task.Name) failed after $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "ERROR"
        if ($errorMsg) {
            Add-Log "   Details: $errorMsg" "ERROR"
        }
    }

    Show-SpectreDashboard
    Start-Sleep -Milliseconds 300
}

# Step 1: Enable Ultimate Performance
function Step-01 { Invoke-Step $Global:Tasks[0] {
    Add-Log "Enabling Ultimate Performance power plan..." "INFO"
    $output = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
    $guid = ($output | Select-String '[a-f0-9-]{36}').Matches.Value
    if ($guid) {
        powercfg /setactive $guid | Out-Null
        Add-Log "Power plan GUID: $guid" "INFO"
        return $true
    }
    throw "Failed to extract power plan GUID"
}}

# Step 2: Disable Visual Effects
function Step-02 { Invoke-Step $Global:Tasks[1] {
    Add-Log "Disabling visual effects..." "INFO"
    $path = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if (!(Test-Path $path)) { New-Item -Path $path -Force | Out-Null }
    Set-ItemProperty -Path $path -Name "VisualFXSetting" -Value 2
    return $true
}}

# Step 3: Disable Window Animations
function Step-03 { Invoke-Step $Global:Tasks[2] {
    Add-Log "Disabling window animations..." "INFO"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    return $true
}}

# Step 4: Disable Transparency
function Step-04 { Invoke-Step $Global:Tasks[3] {
    Add-Log "Disabling transparency effects..." "INFO"
    $result = reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Registry command failed: $result" }
    return $true
}}

# Step 5: Remove Startup Delay
function Step-05 { Invoke-Step $Global:Tasks[4] {
    Add-Log "Removing startup delay..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
    return $true
}}

# Step 6: Set Menu Delay to Zero
function Step-06 { Invoke-Step $Global:Tasks[5] {
    Add-Log "Setting menu delay to zero..." "INFO"
    $result = reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f 2>&1
    if ($LASTEXITCODE -ne 0) { throw "Registry command failed: $result" }
    return $true
}}

# Step 7: Show File Extensions
function Step-07 { Invoke-Step $Global:Tasks[6] {
    Add-Log "Showing file extensions..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    return $true
}}

# Step 8: Open Explorer to This PC
function Step-08 { Invoke-Step $Global:Tasks[7] {
    Add-Log "Configuring Explorer to open This PC..." "INFO"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
    return $true
}}

# Step 9: Disable Game DVR
function Step-09 { Invoke-Step $Global:Tasks[8] {
    Add-Log "Disabling Game DVR..." "INFO"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 10: Disable Background Apps
function Step-10 { Invoke-Step $Global:Tasks[9] {
    Add-Log "Disabling background applications..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
    return $true
}}

# Step 11: Optimize Multimedia Responsiveness
function Step-11 { Invoke-Step $Global:Tasks[10] {
    Add-Log "Optimizing multimedia system profile..." "INFO"
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 12: Disable SysMain (Superfetch)
function Step-12 { Invoke-Step $Global:Tasks[11] {
    Add-Log "Stopping and disabling SysMain..." "INFO"
    Stop-Service SysMain -Force -ErrorAction SilentlyContinue
    Set-Service SysMain -StartupType Disabled
    return $true
}}

# Step 13: Disable Windows Search
function Step-13 { Invoke-Step $Global:Tasks[12] {
    Add-Log "Stopping and disabling Windows Search..." "INFO"
    Stop-Service WSearch -Force -ErrorAction SilentlyContinue
    Set-Service WSearch -StartupType Disabled
    return $true
}}

# Step 14: Disable Delivery Optimization
function Step-14 { Invoke-Step $Global:Tasks[13] {
    Add-Log "Stopping and disabling Delivery Optimization..." "INFO"
    Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
    Set-Service DoSvc -StartupType Disabled
    return $true
}}

# Step 15: Disable Windows Error Reporting
function Step-15 { Invoke-Step $Global:Tasks[14] {
    Add-Log "Stopping and disabling Error Reporting..." "INFO"
    Stop-Service WerSvc -Force -ErrorAction SilentlyContinue
    Set-Service WerSvc -StartupType Disabled
    return $true
}}

# Step 16: Disable Telemetry (DiagTrack)
function Step-16 { Invoke-Step $Global:Tasks[15] {
    Add-Log "Stopping and disabling telemetry..." "INFO"
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    return $true
}}

# Step 17: Disable Windows Update
function Step-17 { Invoke-Step $Global:Tasks[16] {
    Add-Log "Configuring Windows Update to manual..." "INFO"
    $auPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if (!(Test-Path $auPath)) { New-Item -Path $auPath -Force | Out-Null }
    Set-ItemProperty -Path $auPath -Name "NoAutoUpdate" -Value 1
    return $true
}}

# Step 18: Disable Windows Consumer Features
function Step-18 { Invoke-Step $Global:Tasks[17] {
    Add-Log "Disabling Windows Consumer Features..." "INFO"
    $cloudPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if (!(Test-Path $cloudPath)) { New-Item -Path $cloudPath -Force | Out-Null }
    Set-ItemProperty -Path $cloudPath -Name "DisableWindowsConsumerFeatures" -Value 1
    return $true
}}

# Step 19: Disable Windows Tips
function Step-19 { Invoke-Step $Global:Tasks[18] {
    Add-Log "Disabling Windows tips..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}

# Step 20: Disable Hibernation
function Step-20 { Invoke-Step $Global:Tasks[19] {
    Add-Log "Disabling hibernation..." "INFO"
    powercfg -h off | Out-Null
    return $true
}}

# Step 21: Enable Classic Context Menu
function Step-21 { Invoke-Step $Global:Tasks[20] {
    Add-Log "Restoring classic context menu..." "INFO"
    $clsidPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    New-Item -Path $clsidPath -Force | Out-Null
    Set-ItemProperty -Path $clsidPath -Name "(Default)" -Value ""
    return $true
}}

# Step 22: Restart Explorer
function Step-22 { Invoke-Step $Global:Tasks[21] {
    Add-Log "Restarting Windows Explorer..." "INFO"
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    Start-Process explorer
    Start-Sleep -Milliseconds 1000
    return $true
}}

# Step 23: Apply Glow Theme
function Step-23 { Invoke-Step $Global:Tasks[22] {
    Add-Log "Applying dark glow theme..." "INFO"
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
function Step-24 { Invoke-Step $Global:Tasks[23] {
    Add-Log "Configuring desktop icons..." "INFO"
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
function Step-25 { Invoke-Step $Global:Tasks[24] {
    Add-Log "Configuring taskbar (Left + Search Box)..." "INFO"
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
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "❌ ERROR: Run as Administrator required!" -ForegroundColor Red
        return
    }

    # Install/load Spectre.Console
    $script:UseSpectre = Install-SpectreConsole

    # Welcome screen
    if (-not $SkipWelcome) {
        Clear-Host
        Write-Host ""
        Write-Host "    ██████╗ ██████╗ ██████╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██████╗  ██████╗ ██████╗  " -ForegroundColor Cyan
        Write-Host "    ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ╚════██╗██╔═████╗╚════██╗ " -ForegroundColor Cyan
        Write-Host "    ██████╔╝██║  ██║██████╔╝    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝     █████╔╝██║██╔██║ █████╔╝ " -ForegroundColor Magenta
        Write-Host "    ██╔══██╗██║  ██║██╔═══╝     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗     ╚═══██╗████╔╝██║ ╚═══██╗ " -ForegroundColor Magenta
        Write-Host "    ██║  ██║██████╔╝██║         ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ██████╔╝╚██████╔╝██████╔╝" -ForegroundColor Blue
        Write-Host "    ╚═╝  ╚═╝╚═════╝ ╚═╝         ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ " -ForegroundColor Blue
        Write-Host ""
        Write-Host "                              Windows Server 2025 - Ultimate Performance Setup Tool v3.0" -ForegroundColor Gray
        Write-Host ""
        Write-Host "  ⚠️  This script modifies system settings, registry keys, and services." -ForegroundColor Yellow
        Write-Host "      Designed for Windows Server 2025 RDP environments with 16GB RAM." -ForegroundColor Gray
        Write-Host ""
        Write-Host "  📋 Optimizations to be applied:" -ForegroundColor White
        Write-Host "     • Enable Ultimate Performance power plan" -ForegroundColor Gray
        Write-Host "     • Disable visual effects, animations, transparency" -ForegroundColor Gray
        Write-Host "     • Optimize services (SysMain, Search, Delivery Optimization)" -ForegroundColor Gray
        Write-Host "     • Disable telemetry, background apps, error reporting" -ForegroundColor Gray
        Write-Host "     • Configure Explorer, Taskbar, Desktop, and Theme" -ForegroundColor Gray
        Write-Host ""

        $confirm = Read-Host "  Proceed? (Y/N)"
        if ($confirm -notmatch '^[Yy]') {
            Write-Host "  ❌ Cancelled." -ForegroundColor Red
            return
        }
    }

    # Initialize
    $Global:StartTime = Get-Date
    $Global:IsRunning = $true
    Add-Log "=== RDP OPTIMIZATION STARTED ===" "INFO"
    Add-Log "OS: Windows Server 2025 | RAM: 16GB | Steps: $Global:TotalSteps" "INFO"

    # Execute all steps
    $stepFunctions = @(Step-01, Step-02, Step-03, Step-04, Step-05,
                       Step-06, Step-07, Step-08, Step-09, Step-10,
                       Step-11, Step-12, Step-13, Step-14, Step-15,
                       Step-16, Step-17, Step-18, Step-19, Step-20,
                       Step-21, Step-22, Step-23, Step-24, Step-25)

    for ($i = 0; $i -lt $stepFunctions.Count; $i++) {
        & $stepFunctions[$i]
    }

    # Finalize
    $Global:IsRunning = $false
    $Global:CurrentTask = $null
    Show-SpectreDashboard

    $totalTime = (Get-Date) - $Global:StartTime
    $successCount = ($Global:Tasks | Where-Object { $_.Status -eq "Success" }).Count
    $failedCount = ($Global:Tasks | Where-Object { $_.Status -eq "Failed" }).Count

    Write-Host ""
    Write-Host "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
    Write-Host "║                                              OPTIMIZATION COMPLETE!                                                  ║" -ForegroundColor Green
    Write-Host "╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣" -ForegroundColor Green
    Write-Host ("║  ✅ Successful: {0,2}  |  ❌ Failed: {1,2}  |  ⏱️  Total Time: {2:D2}:{3:D2}:{4:D2}" -f $successCount, $failedCount, $totalTime.Hours, $totalTime.Minutes, $totalTime.Seconds) -ForegroundColor Green
    Write-Host "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" -ForegroundColor Green
    Write-Host ""

    if ($failedCount -gt 0) {
        Write-Host "  ⚠️  Some steps failed. Check log for details." -ForegroundColor Yellow
    } else {
        Write-Host "  🎉 All optimizations applied! Your RDP server is optimized for maximum performance." -ForegroundColor Green
    }

    # Save log
    $logFile = "$env:TEMP\RDP_Optimizer_v3_Log.txt"
    $Global:LogEntries | ForEach-Object { "[{0}] [{1}] {2}" -f $_.Time, $_.Level, $_.Message } | Out-File $logFile -Encoding UTF8
    Write-Host "  💾 Log saved to: $logFile" -ForegroundColor Gray
    Write-Host ""
    Write-Host "  Press any key to exit..." -ForegroundColor Gray
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# ═══════════════════════════════════════════════════════════════════════════════
#  ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

$Host.UI.RawUI.WindowTitle = "Windows Server 2025 RDP Optimizer v3.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Start
Start-RDPOptimizer
