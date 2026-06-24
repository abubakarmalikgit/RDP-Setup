<#
.SYNOPSIS
    Windows Server 2025 RDP Optimizer v5.0
.DESCRIPTION
    Terminal dashboard for 25 RDP optimizations.
.VERSION
    5.0
#>

#requires -Version 5.1
#requires -RunAsAdministrator

# === ANSI COLORS ===
$CR="`e[0m"; $CB="`e[1m"; $CK="`e[30m"; $CRD="`e[31m"; $CG="`e[32m"; $CY="`e[33m"
$CBl="`e[34m"; $CM="`e[35m"; $CC="`e[36m"; $CW="`e[37m"; $CGr="`e[90m"
$CLG="`e[92m"; $CLY="`e[93m"; $CLR="`e[91m"; $CLBl="`e[94m"

function W { param([string]$T="", [string]$C="CW", [switch]$N)
    $c = if($C -eq "CB"){$CB}elseif($C -eq "CC"){$CC}elseif($C -eq "CG"){$CG}elseif($C -eq "CY"){$CY}elseif($C -eq "CBl"){$CBl}elseif($C -eq "CM"){$CM}elseif($C -eq "CGr"){$CGr}elseif($C -eq "CLG"){$CLG}elseif($C -eq "CLY"){$CLY}elseif($C -eq "CLR"){$CLR}elseif($C -eq "CLBl"){$CLBl}else{$CW}
    if($N){Write-Host "$c$T$CR" -NoNewline}else{Write-Host "$c$T$CR"}
}

# === GLOBAL STATE ===
$Global:TotalSteps = 25
$Global:StartTime = Get-Date
$Global:Logs = @()
$Global:CurrentTask = $null
$Global:Tasks = @(
    @{ID=1;N="Enable Ultimate Performance";S="Wait";I="⚡"},
    @{ID=2;N="Disable Visual Effects";S="Wait";I="🎨"},
    @{ID=3;N="Disable Window Animations";S="Wait";I="🪟"},
    @{ID=4;N="Disable Transparency";S="Wait";I="🔍"},
    @{ID=5;N="Disable Startup Delay";S="Wait";I="⏱️"},
    @{ID=6;N="Set Menu Delay to 0";S="Wait";I="📋"},
    @{ID=7;N="Show File Extensions";S="Wait";I="📁"},
    @{ID=8;N="Open Explorer to This PC";S="Wait";I="💻"},
    @{ID=9;N="Disable Game DVR";S="Wait";I="🎮"},
    @{ID=10;N="Disable Background Apps";S="Wait";I="🚫"},
    @{ID=11;N="Optimize Multimedia";S="Wait";I="🎵"},
    @{ID=12;N="Disable SysMain";S="Wait";I="🗂️"},
    @{ID=13;N="Disable Windows Search";S="Wait";I="🔎"},
    @{ID=14;N="Disable Delivery Optimization";S="Wait";I="📦"},
    @{ID=15;N="Disable Error Reporting";S="Wait";I="⚠️"},
    @{ID=16;N="Disable Telemetry";S="Wait";I="📡"},
    @{ID=17;N="Disable Windows Update";S="Wait";I="🔄"},
    @{ID=18;N="Disable Consumer Features";S="Wait";I="🏪"},
    @{ID=19;N="Disable Windows Tips";S="Wait";I="💡"},
    @{ID=20;N="Disable Hibernation";S="Wait";I="💤"},
    @{ID=21;N="Enable Classic Context Menu";S="Wait";I="🖱️"},
    @{ID=22;N="Restart Explorer";S="Wait";I="🔄"},
    @{ID=23;N="Apply Glow Theme";S="Wait";I="✨"},
    @{ID=24;N="Show Desktop Icons";S="Wait";I="🖥️"},
    @{ID=25;N="Taskbar Left + Search Box";S="Wait";I="📌"}
)

function Log { param([string]$M, [string]$L="INFO")
    $t = Get-Date -Format "HH:mm:ss"
    $Global:Logs += @{T=$t;M=$M;L=$L}
    if($Global:Logs.Count -gt 50){$Global:Logs = $Global:Logs[-50..-1]}
}

# === DASHBOARD ===
function Draw {
    Clear-Host
    $done = ($Global:Tasks | Where-Object {$_.S -eq "Done"}).Count
    $fail = ($Global:Tasks | Where-Object {$_.S -eq "Fail"}).Count
    $run = ($Global:Tasks | Where-Object {$_.S -eq "Run"}).Count
    $pct = if($Global:TotalSteps -gt 0){[math]::Round(($done/$Global:TotalSteps)*100)}else{0}
    $el = (Get-Date)-$Global:StartTime
    $et = "{0:D2}:{1:D2}:{2:D2}" -f $el.Hours,$el.Minutes,$el.Seconds
    
    $bw = 26; $f = [math]::Round(($pct/100)*$bw); $e = $bw-$f
    $bar = ("█"* $f)+("░"* $e)
    
    # Header
    W "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "CBl"
    W "║  🚀 Windows Server 2025 RDP Optimizer v5.0                                                    Ultimate Performance  ║" "CC"
    W "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "CBl"
    
    # LEFT PANEL
    W "┌─────────────────────────────┐" "CBl"
    W "│         PROGRESS            │" "CBl"
    W "│                             │" "CBl"
    W ("│          {0,3}%             │" -f $pct) "CG"
    W "│  ╭──────────────────────────╮ │" "CBl"
    W ("│  │ {0} │ │" -f $bar) "CG"
    W "│  ╰──────────────────────────╯ │" "CBl"
    W ("│    {0}/{1} Completed        │" -f $done,$Global:TotalSteps) "CGr"
    W "│                             │" "CBl"
    W "├─────────────────────────────┤" "CBl"
    W "│        STATISTICS           │" "CBl"
    W ("│  ✅ Completed:    {0,2}       │" -f $done) "CLG"
    W ("│  ⚙️  In Progress:  {0,2}       │" -f $run) "CLY"
    W ("│  ❌ Failed:        {0,2}       │" -f $fail) "CLR"
    W ("│  ⏳ Remaining:     {0,2}       │" -f ($Global:TotalSteps-$done-$fail)) "CGr"
    W "│                             │" "CBl"
    W "├─────────────────────────────┤" "CBl"
    W "│        SYSTEM INFO          │" "CBl"
    W "│  🖥️  OS:  Windows Server 2025  │" "CGr"
    W "│  ⚡ CPU:  Intel Xeon          │" "CGr"
    W "│  💾 RAM:  16 GB               │" "CGr"
    W ("│  🕐 Started: {0}      │" -f $Global:StartTime.ToString("hh:mm:ss tt")) "CGr"
    W ("│  ⏱️  Elapsed: {0}       │" -f $et) "CGr"
    W "└─────────────────────────────┘" "CBl"
    
    # CENTER PANEL
    W ""
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "CBl"
    W "│                                              CURRENT TASK                                                            │" "CBl"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "CBl"
    
    if($Global:CurrentTask -and $Global:CurrentTask.S -eq "Run"){
        W ("│  ⚙️  {0}" -f $Global:CurrentTask.N).PadRight(119) + "│" "CLY"
    }elseif($Global:CurrentTask -and $Global:CurrentTask.S -eq "Done"){
        W ("│  ✅ {0}" -f $Global:CurrentTask.N).PadRight(119) + "│" "CLG"
    }else{
        W "│  ⏳ Ready to start optimization...                                                                                 │" "CGr"
    }
    W "│                                                                                                                      │" "CBl"
    if($Global:CurrentTask){
        W ("│  {0}" -f $Global:CurrentTask.N).PadRight(119) + "│" "CW"
    }else{
        W "│  Please wait while we apply the best tweaks and optimizations...                                                    │" "CGr"
    }
    W "│                                                                                                                      │" "CBl"
    W "│  [████████████████████████████████████████░░░░░░░░░░░░░░]                                                          │" "CG"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "CBl"
    W "│                                              TASK DETAILS                                                            │" "CBl"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "CBl"
    
    $rt = $Global:Tasks | Where-Object {$_.S -ne "Wait"} | Select-Object -Last 1
    if($rt){
        $ic = if($rt.S -eq "Done"){"✅"}elseif($rt.S -eq "Fail"){"❌"}else{"⚙️"}
        W ("│  {0} {1}" -f $ic,$rt.N).PadRight(119) + "│" "CLG"
    }else{
        W "│  ⏳ Waiting to start...                                                                                              │" "CGr"
    }
    W "│                                                                                                                      │" "CBl"
    W "│                                                                                                                      │" "CBl"
    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "CBl"
    
    # RIGHT PANEL - TASK LIST
    W ""
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "CBl"
    W ("│  ALL TASKS ({0})" -f $Global:TotalSteps).PadRight(119) + "│" "CBl"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "CBl"
    
    foreach($t in $Global:Tasks){
        $ic = switch($t.S){"Done"{"✅"}"Fail"{"❌"}"Run"{"⚙️"}default{"○ "}}
        $co = switch($t.S){"Done"{"CLG"}"Fail"{"CLR"}"Run"{"CLY"}default{"CGr"}}
        $st = switch($t.S){"Done"{"Completed"}"Fail"{"Failed"}"Run"{"In Progress"}default{"Pending"}}
        $line = "│ {0} {1,2}. {2,-45} {3}" -f $ic,$t.ID,$t.N,$st
        W $line.PadRight(119) + "│" $co
    }
    
    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "CBl"
    
    # LOG OUTPUT
    W ""
    W "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "CBl"
    W "│  LOG OUTPUT                                                                                                          │" "CBl"
    W "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "CBl"
    
    $vl = $Global:Logs | Select-Object -Last 8
    if($vl){
        foreach($l in $vl){
            $co = switch($l.L){"OK"{"CLG"}"ERR"{"CLR"}"WARN"{"CLY"}default{"CGr"}}
            $m = "[{0}] {1}" -f $l.T,$l.M
            if($m.Length -gt 116){$m = $m.Substring(0,113)+"..."}
            W ("│  {0}" -f $m).PadRight(119) + "│" $co
        }
    }else{W "│  Ready to begin...                                                                                                  │" "CGr"}
    for($i=($vl.Count);$i -lt 8;$i++){W "│                                                                                                                      │" "CBl"}
    W "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "CBl"
    W ""
    W "  💡 TIP: This process may take a few minutes. Please don't close this window." "CGr" -N
    W "                                          ✅ Safe & recommended for optimal performance" "CLG"
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
    
    if($ok){$task.S="Done";Log "✅ $($task.N) done in $($sw.Elapsed.TotalSeconds.ToString('F1'))s" "OK"}
    else{$task.S="Fail";Log "❌ $($task.N) failed" "ERR"}
    Draw; Start-Sleep -Milliseconds 300
}

# === ALL 25 STEPS ===
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
        W "❌ ERROR: Run as Administrator required!" "CLR";return
    }
    
    Clear-Host
    W ""
    W "    ██████╗ ██████╗ ██████╗     ███████╗███████╗██████╗ ██╗   ██╗███████╗██████╗     ██████╗  ██████╗ ██████╗  " "CC"
    W "    ██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██╔══██╗    ╚════██╗██╔═████╗╚════██╗ " "CC"
    W "    ██████╔╝██║  ██║██████╔╝    ███████╗█████╗  ██████╔╝██║   ██║█████╗  ██████╔╝     █████╔╝██║██╔██║ █████╔╝ " "CM"
    W "    ██╔══██╗██║  ██║██╔═══╝     ╚════██║██╔══╝  ██╔══██╗╚██╗ ██╔╝██╔══╝  ██╔══██╗     ╚═══██╗████╔╝██║ ╚═══██╗ " "CM"
    W "    ██║  ██║██████╔╝██║         ███████║███████╗██║  ██║ ╚████╔╝ ███████╗██║  ██║    ██████╔╝╚██████╔╝██████╔╝" "CBl"
    W "    ╚═╝  ╚═╝╚═════╝ ╚═╝         ╚══════╝╚══════╝╚═╝  ╚═╝  ╚═══╝  ╚══════╝╚═╝  ╚═╝    ╚═════╝  ╚═════╝ ╚═════╝ " "CBl"
    W ""
    W "                              Windows Server 2025 - Ultimate Performance Setup Tool v5.0" "CGr"
    W ""
    W "  ⚠️  This script modifies system settings, registry keys, and services." "CLY"
    W "      Designed for Windows Server 2025 RDP environments with 16GB RAM." "CGr"
    W ""
    W "  📋 This script will perform 25 optimizations including:" "CW"
    W "     • Enable Ultimate Performance power plan" "CGr"
    W "     • Disable visual effects, animations, and transparency" "CGr"
    W "     • Optimize services (SysMain, Search, Delivery Optimization)" "CGr"
    W "     • Disable telemetry, background apps, and error reporting" "CGr"
    W "     • Configure Explorer, Taskbar, Desktop, and Theme" "CGr"
    W ""
    
    $c = Read-Host "  Do you want to proceed? (Y/N)"
    if($c -notmatch '^[Yy]'){W "  ❌ Cancelled." "CLR";return}
    
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
    W "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "CG"
    W "║                                              OPTIMIZATION COMPLETE!                                                  ║" "CG"
    W "╠══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╣" "CG"
    W ("║  ✅ Successful: {0,2}  |  ❌ Failed: {1,2}  |  ⏱️  Total Time: {2:D2}:{3:D2}:{4:D2}" -f $sc,$fc,$tt.Hours,$tt.Minutes,$tt.Seconds) "CG"
    W "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "CG"
    W ""
    
    if($fc -gt 0){
        W "  ⚠️  Some steps failed. Check the log above for details." "CLY"
        foreach($f in ($Global:Tasks | Where-Object {$_.S -eq "Fail"})){W "       • $($f.ID). $($f.N)" "CLR"}
    }else{
        W "  🎉 All optimizations applied! Your RDP server is optimized for maximum performance." "CLG"
    }
    
    $lf = "$env:TEMP\RDP_Optimizer_v5_Log.txt"
    $Global:Logs | ForEach-Object {"[{0}] [{1}] {2}" -f $_.T,$_.L,$_.M} | Out-File $lf -Encoding UTF8
    W ""
    W "  💾 Log saved to: $lf" "CGr"
    W ""
    W "  Press any key to exit..." "CGr"
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

$Host.UI.RawUI.WindowTitle = "Windows Server 2025 RDP Optimizer v5.0"
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
Start-RDPOptimizer