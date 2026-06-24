<#
.SYNOPSIS
    Windows Server 2025 RDP Optimizer v7.0 - Bulletproof Colors Edition
.DESCRIPTION
    v5 stacked layout with dynamic ANSI codes that survive irm | iex.
    More colors, gradients, and polish. Works locally and from GitHub.
.VERSION
    7.0
#>

#requires -Version 5.1
#requires -RunAsAdministrator

# === DYNAMIC ANSI COLORS (Survives irm | iex) ===
# Using [char]27 instead of `e because `e gets corrupted when downloaded via irm
$E = [char]27
$Global:C = @{
    Reset       = "$E[0m"
    Bold        = "$E[1m"
    Dim         = "$E[2m"
    Black       = "$E[30m"
    Red         = "$E[31m"
    Green       = "$E[32m"
    Yellow      = "$E[33m"
    Blue        = "$E[34m"
    Magenta     = "$E[35m"
    Cyan        = "$E[36m"
    White       = "$E[37m"
    Gray        = "$E[90m"
    LightRed    = "$E[91m"
    LightGreen  = "$E[92m"
    LightYellow = "$E[93m"
    LightBlue   = "$E[94m"
    LightMagenta= "$E[95m"
    LightCyan   = "$E[96m"
    LightWhite  = "$E[97m"
    BgBlack     = "$E[40m"
    BgRed       = "$E[41m"
    BgGreen     = "$E[42m"
    BgYellow    = "$E[43m"
    BgBlue      = "$E[44m"
    BgMagenta   = "$E[45m"
    BgCyan      = "$E[46m"
    BgWhite     = "$E[47m"
    BgDarkBlue  = "$E[48;5;17m"
    BgDarkGray  = "$E[48;5;235m"
    BgDarkPurple= "$E[48;5;55m"
    BgNeonBlue  = "$E[48;5;27m"
    # Gradients for progress bar
    Grad1       = "$E[38;5;141m"  # Purple
    Grad2       = "$E[38;5;93m"   # Deep purple
    Grad3       = "$E[38;5;201m"  # Magenta
    Grad4       = "$E[38;5;51m"   # Cyan
    Grad5       = "$E[38;5;46m"   # Green
    NeonGreen   = "$E[38;5;82m"
    NeonPink    = "$E[38;5;198m"
    NeonCyan    = "$E[38;5;87m"
    NeonYellow  = "$E[38;5;226m"
    Gold        = "$E[38;5;220m"
    Silver      = "$E[38;5;250m"
    Bronze      = "$E[38;5;130m"
}

function W {
    param([string]$T = "", [string]$C = "White", [switch]$N)
    $colorCode = switch ($C) {
        "Black" { $Global:C.Black }
        "Red" { $Global:C.Red }
        "Green" { $Global:C.Green }
        "Yellow" { $Global:C.Yellow }
        "Blue" { $Global:C.Blue }
        "Magenta" { $Global:C.Magenta }
        "Cyan" { $Global:C.Cyan }
        "White" { $Global:C.White }
        "Gray" { $Global:C.Gray }
        "LightRed" { $Global:C.LightRed }
        "LightGreen" { $Global:C.LightGreen }
        "LightYellow" { $Global:C.LightYellow }
        "LightBlue" { $Global:C.LightBlue }
        "LightMagenta" { $Global:C.LightMagenta }
        "LightCyan" { $Global:C.LightCyan }
        "LightWhite" { $Global:C.LightWhite }
        "Grad1" { $Global:C.Grad1 }
        "Grad2" { $Global:C.Grad2 }
        "Grad3" { $Global:C.Grad3 }
        "Grad4" { $Global:C.Grad4 }
        "Grad5" { $Global:C.Grad5 }
        "NeonGreen" { $Global:C.NeonGreen }
        "NeonPink" { $Global:C.NeonPink }
        "NeonCyan" { $Global:C.NeonCyan }
        "NeonYellow" { $Global:C.NeonYellow }
        "Gold" { $Global:C.Gold }
        "Silver" { $Global:C.Silver }
        "Bronze" { $Global:C.Bronze }
        "BgDarkBlue" { $Global:C.BgDarkBlue }
        "BgDarkPurple" { $Global:C.BgDarkPurple }
        "BgNeonBlue" { $Global:C.BgNeonBlue }
        "BgGreen" { $Global:C.BgGreen }
        "BgRed" { $Global:C.BgRed }
        "BgYellow" { $Global:C.BgYellow }
        default { $Global:C.White }
    }
    $reset = $Global:C.Reset
    if ($N) { Write-Host "$colorCode$T$reset" -NoNewline }
    else { Write-Host "$colorCode$T$reset" }
}

# === GLOBAL STATE ===
$Global:TotalSteps = 25
$Global:StartTime = Get-Date
$Global:Logs = @()
$Global:CurrentTask = $null
$Global:Tasks = @(
    @{ID=1;N="Enable Ultimate Performance";S="Wait";I="⚡";Desc="Enabling Ultimate Performance power plan..."},
    @{ID=2;N="Disable Visual Effects";S="Wait";I="🎨";Desc="Disabling visual effects for better performance..."},
    @{ID=3;N="Disable Window Animations";S="Wait";I="🪟";Desc="Disabling window animations..."},
    @{ID=4;N="Disable Transparency";S="Wait";I="🔍";Desc="Disabling transparency effects..."},
    @{ID=5;N="Disable Startup Delay";S="Wait";I="⏱️";Desc="Removing startup delay..."},
    @{ID=6;N="Set Menu Delay to 0";S="Wait";I="📋";Desc="Setting menu delay to zero..."},
    @{ID=7;N="Show File Extensions";S="Wait";I="📁";Desc="Showing file extensions..."},
    @{ID=8;N="Open Explorer to This PC";S="Wait";I="💻";Desc="Configuring Explorer to open This PC..."},
    @{ID=9;N="Disable Game DVR";S="Wait";I="🎮";Desc="Disabling Game DVR..."},
    @{ID=10;N="Disable Background Apps";S="Wait";I="🚫";Desc="Disabling background applications..."},
    @{ID=11;N="Optimize Multimedia";S="Wait";I="🎵";Desc="Optimizing multimedia system profile..."},
    @{ID=12;N="Disable SysMain";S="Wait";I="🗂️";Desc="Stopping and disabling SysMain service..."},
    @{ID=13;N="Disable Windows Search";S="Wait";I="🔎";Desc="Stopping and disabling Windows Search..."},
    @{ID=14;N="Disable Delivery Optimization";S="Wait";I="📦";Desc="Stopping and disabling Delivery Optimization..."},
    @{ID=15;N="Disable Error Reporting";S="Wait";I="⚠️";Desc="Stopping and disabling Error Reporting..."},
    @{ID=16;N="Disable Telemetry";S="Wait";I="📡";Desc="Stopping and disabling telemetry service..."},
    @{ID=17;N="Disable Windows Update";S="Wait";I="🔄";Desc="Configuring Windows Update settings..."},
    @{ID=18;N="Disable Consumer Features";S="Wait";I="🏪";Desc="Disabling Windows Consumer Features..."},
    @{ID=19;N="Disable Windows Tips";S="Wait";I="💡";Desc="Disabling Windows tips and suggestions..."},
    @{ID=20;N="Disable Hibernation";S="Wait";I="💤";Desc="Disabling system hibernation..."},
    @{ID=21;N="Enable Classic Context Menu";S="Wait";I="🖱️";Desc="Restoring Windows 10 classic context menu..."},
    @{ID=22;N="Restart Explorer";S="Wait";I="🔄";Desc="Restarting Windows Explorer..."},
    @{ID=23;N="Apply Glow Theme";S="Wait";I="✨";Desc="Applying dark glow theme..."},
    @{ID=24;N="Show Desktop Icons";S="Wait";I="🖥️";Desc="Configuring desktop icon visibility..."},
    @{ID=25;N="Taskbar Left + Search Box";S="Wait";I="📌";Desc="Moving taskbar left and enabling search box..."}
)

function Log { param([string]$M, [string]$L="INFO")
    $t = Get-Date -Format "HH:mm:ss"
    $Global:Logs += @{T=$t;M=$M;L=$L}
    if($Global:Logs.Count -gt 50){$Global:Logs = $Global:Logs[-50..-1]}
}

# === GRADIENT PROGRESS BAR BUILDER ===
function Get-GradientBar {
    param([int]$Percent, [int]$Width = 40)
    $filled = [math]::Round(($Percent / 100) * $Width)
    $empty = $Width - $filled
    $bar = ""
    for($i=0; $i -lt $filled; $i++){
        $grad = switch($i){
            {$_ -lt $Width*0.2} { $Global:C.Grad1 }
            {$_ -lt $Width*0.4} { $Global:C.Grad2 }
            {$_ -lt $Width*0.6} { $Global:C.Grad3 }
            {$_ -lt $Width*0.8} { $Global:C.Grad4 }
            default { $Global:C.Grad5 }
        }
        $bar += "$grad█$($Global:C.Reset)"
    }
    $bar += "$($Global:C.Gray)$('░' * $empty)$($Global:C.Reset)"
    return $bar
}

# === MAIN DASHBOARD (v5 Stacked Layout + Better Colors) ===
function Draw {
    Clear-Host
    $done = ($Global:Tasks | Where-Object {$_.S -eq "Done"}).Count
    $fail = ($Global:Tasks | Where-Object {$_.S -eq "Fail"}).Count
    $run = ($Global:Tasks | Where-Object {$_.S -eq "Run"}).Count
    $pct = if($Global:TotalSteps -gt 0){[math]::Round(($done/$Global:TotalSteps)*100)}else{0}
    $el = (Get-Date)-$Global:StartTime
    $et = "{0:D2}:{1:D2}:{2:D2}" -f $el.Hours,$el.Minutes,$el.Seconds

    $gBar = Get-GradientBar -Percent $pct -Width 40

    # === HEADER WITH NEON GRADIENT ===
    W "" "Black"
    W "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "BgDarkBlue"
    W "║                                                                                                                      ║" "BgDarkBlue"
    W "║  $([char]27)[38;5;141m🚀$([char]27)[0m$([char]27)[38;5;87m Windows Server 2025 RDP Optimizer v7.0$([char]27)[0m$([char]27)[90m                                    Ultimate Performance Setup Tool$([char]27)[0m  ║" "BgDarkBlue"
    W "║                                                                                                                      ║" "BgDarkBlue"
    W "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "BgDarkBlue"
    W "" "Black"

    # === LEFT PANEL: PROGRESS + STATS + SYSTEM INFO ===
    W "┌─────────────────────────────┐" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.NeonCyan)         PROGRESS            $($Global:C.Reset)│" "NeonCyan"
    W "│                             │" "NeonCyan"
    W ("│$($Global:C.Bold)$($Global:C.NeonGreen)          {0,3}%             $($Global:C.Reset)│" -f $pct) "NeonCyan"
    W "│  ╭──────────────────────────╮ │" "NeonCyan"
    W ("│  │ {0} │ │" -f $gBar) "NeonCyan"
    W "│  ╰──────────────────────────╯ │" "NeonCyan"
    W ("│$($Global:C.Gray)    {0}/{1} Completed        $($Global:C.Reset)│" -f $done,$Global:TotalSteps) "NeonCyan"
    W "│                             │" "NeonCyan"
    W "├─────────────────────────────┤" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.NeonPink)        STATISTICS           $($Global:C.Reset)│" "NeonCyan"
    W ("│$($Global:C.LightGreen)  ✅ Completed:    {0,2}       $($Global:C.Reset)│" -f $done) "NeonCyan"
    W ("│$($Global:C.LightYellow)  ⚙️  In Progress:  {0,2}       $($Global:C.Reset)│" -f $run) "NeonCyan"
    W ("│$($Global:C.LightRed)  ❌ Failed:        {0,2}       $($Global:C.Reset)│" -f $fail) "NeonCyan"
    W ("│$($Global:C.Gray)  ⏳ Remaining:     {0,2}       $($Global:C.Reset)│" -f ($Global:TotalSteps-$done-$fail)) "NeonCyan"
    W "│                             │" "NeonCyan"
    W "├─────────────────────────────┤" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.Gold)        SYSTEM INFO          $($Global:C.Reset)│" "NeonCyan"
    W "│$($Global:C.Silver)  🖥️  OS:  Windows Server 2025  $($Global:C.Reset)│" "NeonCyan"
    W "│$($Global:C.Silver)  ⚡ CPU:  Intel Xeon          $($Global:C.Reset)│" "NeonCyan"
    W "│$($Global:C.Silver)  💾 RAM:  16 GB               $($Global:C.Reset)│" "NeonCyan"
    W ("│$($Global:C.Silver)  🕐 Started: {0}      $($Global:C.Reset)│" -f $Global:StartTime.ToString("hh:mm:ss tt")) "NeonCyan"
    W ("│$($Global:C.Silver)  ⏱️  Elapsed: {0}       $($Global:C.Reset)│" -f $et) "NeonCyan"
    W "└─────────────────────────────┘" "NeonCyan"

    # === CENTER PANEL: CURRENT TASK ===
    W "" "Black"
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.NeonCyan)                                              CURRENT TASK                                                            $($Global:C.Reset)│" "NeonCyan"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NeonCyan"

    if($Global:CurrentTask){
        $tc = switch($Global:CurrentTask.S){
            "Run" { $Global:C.LightYellow }
            "Done" { $Global:C.LightGreen }
            "Fail" { $Global:C.LightRed }
            default { $Global:C.Gray }
        }
        $ti = switch($Global:CurrentTask.S){
            "Run" { "⚙️" }
            "Done" { "✅" }
            "Fail" { "❌" }
            default { "⏳" }
        }
        W ("│  {0}{1} {2}{3}" -f $tc,$ti,$Global:CurrentTask.N,$Global:C.Reset).PadRight(119) + "│" "NeonCyan"
        W "│                                                                                                                      │" "NeonCyan"
        W ("│$($Global:C.White)  {0}{1}" -f $Global:CurrentTask.Desc,$Global:C.Reset).PadRight(119) + "│" "NeonCyan"
    } else {
        W "│                                                                                                                      │" "NeonCyan"
        W "│$($Global:C.Gray)                              🚀 Ready to start optimization...                                       $($Global:C.Reset)│" "NeonCyan"
        W "│                                                                                                                      │" "NeonCyan"
        W "│$($Global:C.Gray)         Please wait while we apply the best tweaks and optimizations...                           $($Global:C.Reset)│" "NeonCyan"
    }
    W "│                                                                                                                      │" "NeonCyan"

    # Animated sub-progress bar for current task
    $subWidth = 50
    $subFilled = if($Global:CurrentTask -and $Global:CurrentTask.S -eq "Run"){25}elseif($Global:CurrentTask -and $Global:CurrentTask.S -eq "Done"){50}else{0}
    $subEmpty = $subWidth - $subFilled
    $subBar = "$($Global:C.NeonGreen)$('█' * $subFilled)$($Global:C.Gray)$('░' * $subEmpty)$($Global:C.Reset)"
    W ("│  [{0}]$($Global:C.Reset)                                                          │" -f $subBar) "NeonCyan"

    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.NeonPink)                                              TASK DETAILS                                                            $($Global:C.Reset)│" "NeonCyan"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NeonCyan"

    $rt = $Global:Tasks | Where-Object {$_.S -ne "Wait"} | Select-Object -Last 1
    if($rt){
        $ric = switch($rt.S){"Done"{"✅"}"Fail"{"❌"}"Run"{"⚙️"}default{"⏳"}}
        $rco = switch($rt.S){"Done"{$Global:C.LightGreen}"Fail"{$Global:C.LightRed}"Run"{$Global:C.LightYellow}default{$Global:C.Gray}}
        W ("│  {0}{1} {2} - {3}s{4}" -f $rco,$ric,$rt.N,$rt.Dur,$Global:C.Reset).PadRight(119) + "│" "NeonCyan"
    } else {
        W "│$($Global:C.Gray)  ⏳ Waiting to start...                                                                                              $($Global:C.Reset)│" "NeonCyan"
    }
    W "│                                                                                                                      │" "NeonCyan"
    W "│                                                                                                                      │" "NeonCyan"
    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NeonCyan"

    # === RIGHT PANEL: ALL TASKS ===
    W "" "Black"
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NeonCyan"
    W ("│$($Global:C.Bold)$($Global:C.NeonCyan)  ALL TASKS ({0}){1}" -f $Global:TotalSteps,$Global:C.Reset).PadRight(119) + "│" "NeonCyan"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NeonCyan"

    foreach($t in $Global:Tasks){
        $ic = switch($t.S){
            "Done" { "✅" }
            "Fail" { "❌" }
            "Run" { "⚙️" }
            default { "○" }
        }
        $co = switch($t.S){
            "Done" { $Global:C.LightGreen }
            "Fail" { $Global:C.LightRed }
            "Run" { $Global:C.LightYellow }
            default { $Global:C.Gray }
        }
        $st = switch($t.S){
            "Done" { "Completed" }
            "Fail" { "Failed" }
            "Run" { "In Progress" }
            default { "Pending" }
        }
        $line = "│ {0}{1} {2,2}. {3,-45} {4}{5}" -f $co,$ic,$t.ID,$t.N,$st,$Global:C.Reset
        W $line.PadRight(119) + "│" "NeonCyan"
    }

    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NeonCyan"

    # === LOG OUTPUT ===
    W "" "Black"
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NeonCyan"
    W "│$($Global:C.Bold)$($Global:C.NeonCyan)  LOG OUTPUT                                                                                                          $($Global:C.Reset)│" "NeonCyan"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NeonCyan"

    $vl = $Global:Logs | Select-Object -Last 10
    if($vl){
        foreach($l in $vl){
            $co = switch($l.L){
                "OK" { $Global:C.LightGreen }
                "ERR" { $Global:C.LightRed }
                "WARN" { $Global:C.LightYellow }
                default { $Global:C.Gray }
            }
            $m = "[{0}] {1}" -f $l.T,$l.M
            if($m.Length -gt 116){$m = $m.Substring(0,113)+"..."}
            W ("│$($Global:C.Dim)  {0}{1}{2}" -f $co,$m,$Global:C.Reset).PadRight(119) + "│" "NeonCyan"
        }
    } else {
        W "│$($Global:C.Gray)  [System] Ready to begin optimization sequence...                                                                   $($Global:C.Reset)│" "NeonCyan"
    }
    for($i=($vl.Count);$i -lt 10;$i++){W "│                                                                                                                      │" "NeonCyan"}
    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NeonCyan"
    W "" "Black"
    W "  💡 TIP: This process may take a few minutes. Please don't close this window." "Gray" -N
    W "                                          ✅ Safe & recommended for optimal performance" "LightGreen"
}

# === STEP RUNNER ===
function RunStep {
    param([int]$Idx, [scriptblock]$Action)
    $task = $Global:Tasks[$Idx]
    $Global:CurrentTask = $task
    $task.S = "Run"
    Log "Starting: $($task.N)" "INFO"
    Draw; Start-Sleep -Milliseconds 400

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $ok = $false
    try {
        $result = & $Action
        $ok = if($result -eq $null){$true}else{[bool]$result}
    } catch {
        $ok = $false
        Log "ERROR: $($_.Exception.Message)" "ERR"
    }
    $sw.Stop()
    $task.Dur = $sw.Elapsed.TotalSeconds

    if($ok){$task.S="Done";Log "✅ $($task.N) done in $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "OK"}
    else{$task.S="Fail";Log "❌ $($task.N) failed" "ERR"}
    Draw; Start-Sleep -Milliseconds 300
}

# === ALL 25 STEPS (Exact Commands) ===
function S01 { RunStep 0 {
    Log "Enabling Ultimate Performance..." "INFO"
    $out = powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
    $guid = ($out | Select-String '[a-f0-9-]{36}').Matches.Value
    if($guid){powercfg /setactive $guid | Out-Null;Log "GUID: $guid" "INFO";return $true}
    throw "No GUID found"
}}
function S02 { RunStep 1 {
    Log "Disabling visual effects..." "INFO"
    $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
    if(!(Test-Path $p)){New-Item -Path $p -Force | Out-Null}
    Set-ItemProperty -Path $p -Name "VisualFXSetting" -Value 2
    return $true
}}
function S03 { RunStep 2 {
    Log "Disabling window animations..." "INFO"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
    return $true
}}
function S04 { RunStep 3 {
    Log "Disabling transparency..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}
function S05 { RunStep 4 {
    Log "Removing startup delay..." "INFO"
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force | Out-Null
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
    return $true
}}
function S06 { RunStep 5 {
    Log "Setting menu delay to 0..." "INFO"
    reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f | Out-Null
    return $true
}}
function S07 { RunStep 6 {
    Log "Showing file extensions..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
    return $true
}}
function S08 { RunStep 7 {
    Log "Configuring Explorer to This PC..." "INFO"
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
    return $true
}}
function S09 { RunStep 8 {
    Log "Disabling Game DVR..." "INFO"
    reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
    reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}
function S10 { RunStep 9 {
    Log "Disabling background apps..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
    return $true
}}
function S11 { RunStep 10 {
    Log "Optimizing multimedia..." "INFO"
    reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}
function S12 { RunStep 11 {
    Log "Stopping SysMain..." "INFO"
    Stop-Service SysMain -Force -ErrorAction SilentlyContinue
    Set-Service SysMain -StartupType Disabled
    return $true
}}
function S13 { RunStep 12 {
    Log "Stopping Windows Search..." "INFO"
    Stop-Service WSearch -Force -ErrorAction SilentlyContinue
    Set-Service WSearch -StartupType Disabled
    return $true
}}
function S14 { RunStep 13 {
    Log "Stopping Delivery Optimization..." "INFO"
    Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
    Set-Service DoSvc -StartupType Disabled
    return $true
}}
function S15 { RunStep 14 {
    Log "Stopping Error Reporting..." "INFO"
    Stop-Service WerSvc -Force -ErrorAction SilentlyContinue
    Set-Service WerSvc -StartupType Disabled
    return $true
}}
function S16 { RunStep 15 {
    Log "Stopping telemetry..." "INFO"
    Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
    Set-Service DiagTrack -StartupType Disabled
    return $true
}}
function S17 { RunStep 16 {
    Log "Configuring Windows Update..." "INFO"
    $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
    if(!(Test-Path $p)){New-Item -Path $p -Force | Out-Null}
    Set-ItemProperty -Path $p -Name "NoAutoUpdate" -Value 1
    return $true
}}
function S18 { RunStep 17 {
    Log "Disabling Consumer Features..." "INFO"
    $p = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
    if(!(Test-Path $p)){New-Item -Path $p -Force | Out-Null}
    Set-ItemProperty -Path $p -Name "DisableWindowsConsumerFeatures" -Value 1
    return $true
}}
function S19 { RunStep 18 {
    Log "Disabling Windows tips..." "INFO"
    reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Null
    return $true
}}
function S20 { RunStep 19 {
    Log "Disabling hibernation..." "INFO"
    powercfg -h off | Out-Null
    return $true
}}
function S21 { RunStep 20 {
    Log "Restoring classic context menu..." "INFO"
    $p = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
    New-Item -Path $p -Force | Out-Null
    Set-ItemProperty -Path $p -Name "(Default)" -Value ""
    return $true
}}
function S22 { RunStep 21 {
    Log "Restarting Explorer..." "INFO"
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 800
    Start-Process explorer
    Start-Sleep -Milliseconds 1000
    return $true
}}
function S23 { RunStep 22 {
    Log "Applying glow theme..." "INFO"
    $tp = "$env:windir\Resources\Themes\themeA.theme"
    if(Test-Path $tp){Invoke-Item $tp;Start-Sleep -Milliseconds 1000}
    $p = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
    if(!(Test-Path $p)){New-Item -Path $p -Force | Out-Null}
    Set-ItemProperty -Path $p -Name "AppsUseLightTheme" -Value 0
    Set-ItemProperty -Path $p -Name "SystemUsesLightTheme" -Value 0
    return $true
}}
function S24 { RunStep 23 {
    Log "Configuring desktop icons..." "INFO"
    $Paths = @(
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
        "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
    )
    foreach($Path in $Paths){
        if(!(Test-Path $Path)){New-Item -Path $Path -Force | Out-Null}
        Set-ItemProperty -Path $Path -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Type DWord
        Set-ItemProperty -Path $Path -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0 -Type DWord
        Set-ItemProperty -Path $Path -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type DWord
    }
    return $true
}}
function S25 { RunStep 24 {
    Log "Configuring taskbar..." "INFO"
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
    $p = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
    if(!(Test-Path $p)){New-Item -Path $p -Force | Out-Null}
    Set-ItemProperty -Path $p -Name "SearchboxTaskbarMode" -Value 2
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 500
    Start-Process explorer
    return $true
}}

# === MAIN ===
function Start-RDPOptimizer {
    $id = [Security.Principal.WindowsIdentity]::GetCurrent()
    $pr = [Security.Principal.WindowsPrincipal]$id
    if(-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
        W "❌ ERROR: Run as Administrator required!" "LightRed";return
    }

    Clear-Host
    W ""
    W "    ██████╗ ██████╗ ██████╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██████╗  ██████╗ ██████╗  " "Cyan"
    W "    ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ╚════██╗██╔═████╗╚════██╗ " "Cyan"
    W "    ██████╔╝██║  ██║██████╔╝    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝     █████╔╝██║██╔██║ █████╔╝ " "Magenta"
    W "    ██╔══██╗██║  ██║██╔═══╝     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗     ╚═══██╗████╔╝██║ ╚═══██╗ " "Magenta"
    W "    ██║  ██║██████╔╝██║         ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ██████╔╝╚██████╔╝██████╔╝" "Blue"
    W "    ╚═╝  ╚═╝╚═════╝ ╚═╝         ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ " "Blue"
    W ""
    W "                              Windows Server 2025 - Ultimate Performance Setup Tool v7.0" "Gray"
    W ""
    W "  ⚠️  This script modifies system settings, registry keys, and services." "LightYellow"
    W "      Designed for Windows Server 2025 RDP environments with 16GB RAM." "Gray"
    W ""
    W "  📋 This script will perform 25 optimizations including:" "White"
    W "     • Enable Ultimate Performance power plan" "Gray"
    W "     • Disable visual effects, animations, and transparency" "Gray"
    W "     • Optimize services (SysMain, Search, Delivery Optimization)" "Gray"
    W "     • Disable telemetry, background apps, and error reporting" "Gray"
    W "     • Configure Explorer, Taskbar, Desktop, and Theme" "Gray"
    W ""

    $c = Read-Host "  Do you want to proceed? (Y/N)"
    if($c -notmatch '^[Yy]'){W "  ❌ Cancelled." "LightRed";return}

    $Global:StartTime = Get-Date
    $Global:IsRunning = $true
    Log "=== RDP OPTIMIZATION STARTED ===" "INFO"
    Log "OS: Windows Server 2025 | RAM: 16GB | Steps: $Global:TotalSteps" "INFO"

    S01; S02; S03; S04; S05; S06; S07; S08; S09; S10
    S11; S12; S13; S14; S15; S16; S17; S18; S19; S20
    S21; S22; S23; S24; S25

    $Global:IsRunning = $false
    $Global:CurrentTask = $null
    Draw

    $tt = (Get-Date)-$Global:StartTime
    $sc = ($Global:Tasks | Where-Object {$_.S -eq "Done"}).Count
    $fc = ($Global:Tasks | Where-Object {$_.S -eq "Fail"}).Count

    W ""
    W "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "Green"
    W "║                                              OPTIMIZATION COMPLETE!                                                  ║" "Green"
    W "╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣" "Green"
    W ("║  ✅ Successful: {0,2}  |  ❌ Failed: {1,2}  |  ⏱️  Total Time: {2:D2}:{3:D2}:{4:D2}" -f $sc,$fc,$tt.Hours,$tt.Minutes,$tt.Seconds) "Green"
    W "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "Green"
    W ""

    if($fc -gt 0){
        W "  ⚠️  Some steps failed. Check the log above for details." "LightYellow"
        foreach($f in ($Global:Tasks | Where-Object {$_.S -eq "Fail"})){W "       • $($f.ID). $($f.N)" "LightRed"}
    }else{
        W "  🎉 All optimizations applied! Your RDP server is optimized for maximum performance." "LightGreen"
    }

    $lf = "$env:TEMP\RDP_Optimizer_v7_Log.txt"
    $Global:Logs | ForEach-Object {"[{0}] [{1}] {2}" -f $_.T,$_.L,$_.M} | Out-File $lf -Encoding UTF8
    W ""
    W "  💾 Log saved to: $lf" "Gray"
    W ""
    W "  Press any key to exit..." "Gray"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$Host.UI.RawUI.WindowTitle = "Windows Server 2025 RDP Optimizer v7.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Start-RDPOptimizer
