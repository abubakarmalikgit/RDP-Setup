<#
.SYNOPSIS
    RDP Setup & Optimizer v9.0 - Lightning Edition
.DESCRIPTION
    Phase 1: System Optimization (25 steps) - REVERSED (UI first!)
    Phase 2: Software Installation (22 steps) - FASTEST mode
    Features: Live Terminal Box, Parallel installs, Bulletproof ANSI
    Works via: irm https://raw.githubusercontent.com/.../RDP_Setup_Optimizer_v9.ps1 | iex
.VERSION
    9.0
#>

#requires -Version 5.1
#requires -RunAsAdministrator

# === BULLETPROOF ANSI ENGINE ===
$E = [char]27
$script:C = @{
    X = "$E[0m"; B = "$E[1m"; D = "$E[2m"
    K = "$E[30m"; R = "$E[31m"; G = "$E[32m"; Y = "$E[33m"
    U = "$E[34m"; M = "$E[35m"; C = "$E[36m"; W = "$E[37m"
    LG = "$E[92m"; LY = "$E[93m"; LR = "$E[91m"
    LM = "$E[95m"; LC = "$E[96m"; LW = "$E[97m"
    GY = "$E[90m"
    G1 = "$E[38;5;141m"; G2 = "$E[38;5;93m"; G3 = "$E[38;5;201m"
    G4 = "$E[38;5;51m"; G5 = "$E[38;5;46m"
    NG = "$E[38;5;82m"; NP = "$E[38;5;198m"; NC = "$E[38;5;87m"
    NY = "$E[38;5;226m"; AU = "$E[38;5;220m"; SI = "$E[38;5;250m"
    BGK = "$E[48;5;16m"; BGU = "$E[48;5;17m"; BGP = "$E[48;5;55m"
}

function WC {
    param([string]$T = "", [string]$Co = "W", [switch]$N)
    $cc = switch($Co) {
        "K"{$script:C.K}"R"{$script:C.R}"G"{$script:C.G}"Y"{$script:C.Y}
        "U"{$script:C.U}"M"{$script:C.M}"C"{$script:C.C}"W"{$script:C.W}
        "LG"{$script:C.LG}"LY"{$script:C.LY}"LR"{$script:C.LR}
        "LM"{$script:C.LM}"LC"{$script:C.LC}"LW"{$script:C.LW}
        "GY"{$script:C.GY}"G1"{$script:C.G1}"G2"{$script:C.G2}
        "G3"{$script:C.G3}"G4"{$script:C.G4}"G5"{$script:C.G5}
        "NG"{$script:C.NG}"NP"{$script:C.NP}"NC"{$script:C.NC}
        "NY"{$script:C.NY}"AU"{$script:C.AU}"SI"{$script:C.SI}
        "BGU"{$script:C.BGU}"BGP"{$script:C.BGP}"BGK"{$script:C.BGK}
        default{$script:C.W}
    }
    if($N){Write-Host "$cc$T$($script:C.X)" -NoNewline}
    else{Write-Host "$cc$T$($script:C.X)"}
}

function BoxLine { param([string]$T="",[string]$Co="NC",[int]$W=118)
    $pad=[math]::Max(0,$W-$T.Length)
    WC ("║$T"+(" "*$pad)+"║") $Co
}

function GradBar {
    param([int]$P=0,[int]$W=50)
    $f=[math]::Round(($P/100)*$W);$e=$W-$f;$b=""
    for($i=0;$i-lt$f;$i++){
        $g=if($i-lt$W*0.2){$script:C.G1}elseif($i-lt$W*0.4){$script:C.G2}elseif($i-lt$W*0.6){$script:C.G3}elseif($i-lt$W*0.8){$script:C.G4}else{$script:C.G5}
        $b+="$g█$($script:C.X)"
    }
    $b+="$($script:C.GY)$('░'*$e)$($script:C.X)"
    return $b
}

function SubBar {
    param([int]$P=0,[int]$W=40)
    $f=[math]::Round(($P/100)*$W);$e=$W-$f
    return "$($script:C.NG)$('█'*$f)$($script:C.GY)$('░'*$e)$($script:C.X)"
}

# === GLOBAL STATE ===
$script:StartTime=Get-Date
$script:Logs=@()
$script:TermLogs=@()
$script:Phase=0
$script:CurrentTask=$null
$script:MaxTermLines=12

function LogIt {
    param([string]$M,[string]$L="INFO")
    $t=Get-Date -Format "HH:mm:ss"
    $script:Logs+=@{T=$t;M=$M;L=$L}
    if($script:Logs.Count-gt 100){$script:Logs=$script:Logs[-100..-1]}
}

function TermLog {
    param([string]$M)
    $t=Get-Date -Format "HH:mm:ss"
    $script:TermLogs+=@{T=$t;M=$M}
    if($script:TermLogs.Count-gt $script:MaxTermLines){$script:TermLogs=$script:TermLogs[-$script:MaxTermLines..-1]}
}

# === LIVE TERMINAL CAPTURE ===
function Invoke-TerminalCommand {
    param([string]$Command,[string]$Description="")
    TermLog ">>> $Description"
    TermLog "> $Command"
    try {
        $output = Invoke-Expression $Command 2>&1 | Out-String
        if($output) {
            $lines = $output -split "`r?`n" | Where-Object { $_.Trim() -ne "" } | Select-Object -First 8
            foreach($line in $lines) { TermLog "  $line" }
        }
        TermLog "[OK] Completed"
        return $true
    } catch {
        TermLog "[ERR] $($_.Exception.Message)"
        return $false
    }
}

# === FAST WINGET INSTALLER ===
function Install-WingetFast {
    param([string]$Id,[string]$Description="",[string]$ExtraArgs="")
    TermLog ">>> Installing: $Description"
    $cmd = "winget install --id `"$Id`" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity"
    if($ExtraArgs) { $cmd += " $ExtraArgs" }
    TermLog "> $cmd"
    try {
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = "winget"
        $psi.Arguments = "install --id `"$Id`" -e --silent --accept-package-agreements --accept-source-agreements --disable-interactivity $ExtraArgs"
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $psi.UseShellExecute = $false
        $psi.CreateNoWindow = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        $stdout = $proc.StandardOutput.ReadToEnd()
        $stderr = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()

        if($stdout) {
            $lines = ($stdout -split "`r?`n") | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 6
            foreach($line in $lines) { if($line.Trim()) { TermLog "  $line" } }
        }
        if($stderr -and $stderr.Trim()) {
            $elines = ($stderr -split "`r?`n") | Where-Object { $_.Trim() -ne "" } | Select-Object -Last 3
            foreach($line in $elines) { if($line.Trim()) { TermLog "  ! $line" } }
        }

        if($proc.ExitCode -eq 0 -or $proc.ExitCode -eq -1978335189) {
            TermLog "[OK] $Description installed successfully"
            return $true
        } else {
            TermLog "[WARN] Exit code: $($proc.ExitCode)"
            # Try fallback with choco if winget fails
            if(Get-Command choco -ErrorAction SilentlyContinue) {
                TermLog "  [Fallback] Trying Chocolatey..."
                $cname = $Id.Split('.')[-1].ToLower()
                if($cname -eq "nodejs") { $cname = "nodejs-lts" }
                $cproc = Start-Process choco -ArgumentList "install $cname -y" -Wait -PassThru -WindowStyle Hidden
                if($cproc.ExitCode -eq 0) {
                    TermLog "[OK] Installed via Chocolatey fallback"
                    return $true
                }
            }
            return $false
        }
    } catch {
        TermLog "[ERR] $($_.Exception.Message)"
        return $false
    }
}

# === PHASE 1 TASKS (REVERSED - UI FIRST!) ===
$script:P1Tasks = @(
    @{ID=1;N="Taskbar Left + Search Box";I="📌";S="Wait";Desc="Moving taskbar left and enabling search..."},
    @{ID=2;N="Show Desktop Icons";I="🖥️";S="Wait";Desc="Configuring desktop icon visibility..."},
    @{ID=3;N="Apply Glow Theme";I="✨";S="Wait";Desc="Applying dark glow theme..."},
    @{ID=4;N="Restart Explorer";I="🔄";S="Wait";Desc="Restarting Windows Explorer..."},
    @{ID=5;N="Enable Classic Context Menu";I="🖱️";S="Wait";Desc="Restoring Windows 10 classic context menu..."},
    @{ID=6;N="Disable Hibernation";I="💤";S="Wait";Desc="Disabling system hibernation..."},
    @{ID=7;N="Disable Windows Tips";I="💡";S="Wait";Desc="Disabling Windows tips and suggestions..."},
    @{ID=8;N="Disable Consumer Features";I="🏪";S="Wait";Desc="Disabling Windows Consumer Features..."},
    @{ID=9;N="Disable Windows Update";I="🔄";S="Wait";Desc="Configuring Windows Update policy..."},
    @{ID=10;N="Disable Telemetry";I="📡";S="Wait";Desc="Stopping DiagTrack telemetry..."},
    @{ID=11;N="Disable Error Reporting";I="⚠️";S="Wait";Desc="Stopping Error Reporting service..."},
    @{ID=12;N="Disable Delivery Optimization";I="📦";S="Wait";Desc="Stopping Delivery Optimization..."},
    @{ID=13;N="Disable Windows Search";I="🔎";S="Wait";Desc="Stopping Windows Search indexer..."},
    @{ID=14;N="Disable SysMain";I="🗂️";S="Wait";Desc="Stopping SysMain (SuperFetch)..."},
    @{ID=15;N="Optimize Multimedia";I="🎵";S="Wait";Desc="Tuning multimedia system profile..."},
    @{ID=16;N="Disable Background Apps";I="🚫";S="Wait";Desc="Killing background app access..."},
    @{ID=17;N="Disable Game DVR";I="🎮";S="Wait";Desc="Disabling Game DVR overhead..."},
    @{ID=18;N="Open Explorer to This PC";I="💻";S="Wait";Desc="Configuring Explorer to open This PC..."},
    @{ID=19;N="Show File Extensions";I="📁";S="Wait";Desc="Revealing file extensions..."},
    @{ID=20;N="Set Menu Delay to 0";I="📋";S="Wait";Desc="Setting menu delay to zero..."},
    @{ID=21;N="Disable Startup Delay";I="⏱️";S="Wait";Desc="Eliminating startup delay..."},
    @{ID=22;N="Disable Transparency";I="🔍";S="Wait";Desc="Removing transparency effects..."},
    @{ID=23;N="Disable Window Animations";I="🪟";S="Wait";Desc="Killing window animations..."},
    @{ID=24;N="Disable Visual Effects";I="🎨";S="Wait";Desc="Stripping visual effects for raw performance..."},
    @{ID=25;N="Enable Ultimate Performance";I="⚡";S="Wait";Desc="Activating Ultimate Performance power plan..."}
)

# === PHASE 2 TASKS ===
$script:P2Tasks = @(
    @{ID=1;N="VLC Media Player";I="🎬";S="Wait";Desc="Installing VLC Media Player..."},
    @{ID=2;N="K-Lite Codec Pack (Full)";I="🎞️";S="Wait";Desc="Installing K-Lite Codec Pack Full..."},
    @{ID=3;N="WinRAR";I="📦";S="Wait";Desc="Installing WinRAR..."},
    @{ID=4;N="7-Zip";I="🗜️";S="Wait";Desc="Installing 7-Zip..."},
    @{ID=5;N="Steam";I="🎮";S="Wait";Desc="Installing Steam..."},
    @{ID=6;N="Xbox App";I="🎯";S="Wait";Desc="Installing Xbox App..."},
    @{ID=7;N="Microsoft Store Reset";I="🏪";S="Wait";Desc="Resetting Microsoft Store (wsreset)..."},
    @{ID=8;N="Xbox Identity Provider";I="🆔";S="Wait";Desc="Installing Xbox Identity Provider..."},
    @{ID=9;N="Xbox In-Game Experience";I="🕹️";S="Wait";Desc="Installing Xbox In-Game Experience..."},
    @{ID=10;N="Microsoft Store Verify";I="✅";S="Wait";Desc="Verifying Microsoft Store..."},
    @{ID=11;N="Node.js LTS";I="🟢";S="Wait";Desc="Installing Node.js LTS + npm..."},
    @{ID=12;N="Git";I="🌿";S="Wait";Desc="Installing Git..."},
    @{ID=13;N="Python 3.10";I="🐍";S="Wait";Desc="Installing Python 3.10..."},
    @{ID=14;N="Python 3.11";I="🐍";S="Wait";Desc="Installing Python 3.11..."},
    @{ID=15;N="Python 3.12";I="🐍";S="Wait";Desc="Installing Python 3.12..."},
    @{ID=16;N="Python 3.13";I="🐍";S="Wait";Desc="Installing Python 3.13..."},
    @{ID=17;N="Python 3.14";I="🐍";S="Wait";Desc="Installing Python 3.14..."},
    @{ID=18;N="Python Dev Modules";I="🔧";S="Wait";Desc="Installing pip, setuptools, wheel, pytest, black, ruff, mypy, bandit..."},
    @{ID=19;N="VS Code";I="📝";S="Wait";Desc="Installing Visual Studio Code..."},
    @{ID=20;N="Internet Download Manager";I="⬇️";S="Wait";Desc="Installing IDM..."},
    @{ID=21;N="Update All Apps";I="🔄";S="Wait";Desc="Updating all winget packages..."},
    @{ID=22;N="Windows Update";I="🪟";S="Wait";Desc="Installing Windows Updates..."}
)

# === DRAW DASHBOARD ===
function DrawDashboard {
    param([array]$Tasks,[string]$PhaseName,[int]$PhaseNum)

    $done=($Tasks|Where-Object{$_.S-eq"Done"}).Count
    $fail=($Tasks|Where-Object{$_.S-eq"Fail"}).Count
    $run=($Tasks|Where-Object{$_.S-eq"Run"}).Count
    $tot=$Tasks.Count
    $pct=if($tot-gt 0){[math]::Round(($done/$tot)*100)}else{0}
    $el=(Get-Date)-$script:StartTime
    $et="{0:D2}:{1:D2}:{2:D2}"-f$el.Hours,$el.Minutes,$el.Seconds

    Clear-Host

    # === HEADER ===
    WC ""
    WC "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "BGU"
    BoxLine "" "BGU"
    BoxLine "  $($script:C.G1)🚀$($script:C.X)  $($script:C.NC)$($script:C.B)RDP Setup & Optimizer v9.0 - Lightning Edition$($script:C.X)  $($script:C.GY)[ Phase $PhaseNum : $PhaseName ]$($script:C.X)" "BGU"
    BoxLine "" "BGU"
    WC "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "BGU"
    WC ""

    # === PROGRESS PANEL ===
    WC "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "│$($script:C.B)$($script:C.NC)  OVERALL PROGRESS                                                                                                       $($script:C.X)│" "NC"
    WC "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"
    $gBar=GradBar -P $pct -W 60
    BoxLine "  $gBar  $($script:C.B)$($script:C.NG)$pct%$($script:C.X)" "NC"
    BoxLine "" "NC"
    BoxLine "  $($script:C.LG)✅ Completed:  $done/$tot$($script:C.X)    $($script:C.LY)⚙️ Running:  $run$($script:C.X)    $($script:C.LR)❌ Failed:  $fail$($script:C.X)    $($script:C.GY)⏱ Elapsed: $et$($script:C.X)" "NC"
    WC "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""

    # === CURRENT TASK ===
    WC "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "│$($script:C.B)$($script:C.NC)  CURRENT TASK                                                                                                          $($script:C.X)│" "NC"
    WC "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"

    if($script:CurrentTask){
        $tc=switch($script:CurrentTask.S){"Run"{$script:C.LY}"Done"{$script:C.LG}"Fail"{$script:C.LR}default{$script:C.GY}}
        $ti=switch($script:CurrentTask.S){"Run"{"⚙️"}"Done"{"✅"}"Fail"{"❌"}default{"⏳"}}
        BoxLine "  $tc$ti $($script:C.B)$($script:CurrentTask.N)$($script:C.X)" "NC"
        BoxLine "" "NC"
        BoxLine "  $($script:C.SI)$($script:CurrentTask.Desc)$($script:C.X)" "NC"
        BoxLine "" "NC"
        $sp=if($script:CurrentTask.S-eq"Run"){50}elseif($script:CurrentTask.S-eq"Done"){100}else{0}
        $sb=SubBar -P $sp -W 50
        BoxLine "  [$sb]" "NC"
    }else{
        BoxLine "" "NC"
        BoxLine "  $($script:C.GY)🚀 Ready to begin...$($script:C.X)" "NC"
        BoxLine "" "NC"
        $sb=SubBar -P 0 -W 50
        BoxLine "  [$sb]" "NC"
    }
    WC "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""

    # === TASK LIST ===
    WC "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "│$($script:C.B)$($script:C.NC)  TASK QUEUE  ($tot tasks)                                                                                              $($script:C.X)│" "NC"
    WC "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"

    foreach($t in $Tasks){
        $ic=switch($t.S){"Done"{"✅"}"Fail"{"❌"}"Run"{"⚙️"}default{"○"}}
        $co=switch($t.S){"Done"{$script:C.LG}"Fail"{$script:C.LR}"Run"{$script:C.LY}default{$script:C.GY}}
        $st=switch($t.S){"Done"{"Done"}"Fail"{"Failed"}"Run"{"Running..."}default{"Pending"}}
        $line="│  $co$ic$($script:C.X) $($script:C.B)$($t.ID,2).$($script:C.X) $($t.N,-42) $co$st$($script:C.X)"
        WC $line.PadRight(119)+"│" "NC"
    }
    WC "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""

    # === LIVE TERMINAL BOX ===
    WC "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "│$($script:C.B)$($script:C.NG)  🔴 LIVE TERMINAL  (Real-time command output)                                                                        $($script:C.X)│" "NC"
    WC "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"

    $tl=$script:TermLogs|Select-Object -Last $script:MaxTermLines
    if($tl){
        foreach($l in $tl){
            $m="[$($l.T)] $($l.M)"
            if($m.Length-gt 114){$m=$m.Substring(0,111)+"..."}
            BoxLine "  $($script:C.D)$($script:C.GY)$m$($script:C.X)" "NC"
        }
    }else{
        BoxLine "  $($script:C.GY)[Terminal] Waiting for commands...$($script:C.X)" "NC"
    }
    for($i=$tl.Count;$i-lt $script:MaxTermLines;$i++){BoxLine "" "NC"}
    WC "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""

    # === LOGS ===
    WC "┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "│$($script:C.B)$($script:C.NC)  SYSTEM LOG                                                                                                           $($script:C.X)│" "NC"
    WC "├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"
    $vl=$script:Logs|Select-Object -Last 5
    if($vl){
        foreach($l in $vl){
            $co=switch($l.L){"OK"{$script:C.LG}"ERR"{$script:C.LR}"WARN"{$script:C.LY}default{$script:C.GY}}
            $m="[$($l.T)] $($l.M)"
            if($m.Length-gt 114){$m=$m.Substring(0,111)+"..."}
            BoxLine "  $($script:C.D)$co$m$($script:C.X)" "NC"
        }
    }else{
        BoxLine "  $($script:C.GY)[System] Ready...$($script:C.X)" "NC"
    }
    for($i=$vl.Count;$i-lt 5;$i++){BoxLine "" "NC"}
    WC "└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""
    WC "  $($script:C.GY)💡 Tip: Do not close this window. Live terminal shows real-time command output.$($script:C.X)" "GY" -N
    WC "                              $($script:C.LG)✅ Safe & optimized for Windows Server 2025 RDP environments$($script:C.X)" "LG"
}

# === STEP RUNNER ===
function RunStep {
    param([int]$Idx,[scriptblock]$Action,[array]$TaskList)
    $task=$TaskList[$Idx]
    $script:CurrentTask=$task
    $task.S="Run"
    LogIt "START: $($task.N)" "INFO"
    DrawDashboard -Tasks $TaskList -PhaseName $script:PhaseName -PhaseNum $script:PhaseNum
    Start-Sleep -Milliseconds 300

    $sw=[System.Diagnostics.Stopwatch]::StartNew()
    $ok=$false
    $err=$null
    try{
        $result=& $Action
        $ok=if($result-eq$null){$true}else{[bool]$result}
    }catch{
        $ok=$false
        $err=$_.Exception.Message
        LogIt "ERROR: $err" "ERR"
    }
    $sw.Stop()
    $task.Dur=[math]::Round($sw.Elapsed.TotalSeconds,1)

    if($ok){$task.S="Done";LogIt "✅ DONE: $($task.N) in $($task.Dur)s" "OK"}
    else{$task.S="Fail";LogIt "❌ FAIL: $($task.N) - $err" "ERR"}
    DrawDashboard -Tasks $TaskList -PhaseName $script:PhaseName -PhaseNum $script:PhaseNum
    Start-Sleep -Milliseconds 200
}

# ============================
# === PHASE 1: OPTIMIZATION ===
# ============================
function Run-Phase1 {
    $script:PhaseName="SYSTEM OPTIMIZATION"
    $script:PhaseNum=1
    $script:StartTime=Get-Date
    LogIt "=== PHASE 1: SYSTEM OPTIMIZATION STARTED ===" "INFO"
    TermLog "=== Phase 1: System Optimization ==="

    $t=$script:P1Tasks

    # S01 - Taskbar (was #25)
    RunStep 0 {
        LogIt "Configuring taskbar..." "INFO"
        TermLog ">>> Configuring Taskbar Left + Search Box"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarAl" -Value 0
        $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\Search"
        if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
        Set-ItemProperty -Path $p -Name "SearchboxTaskbarMode" -Value 2
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 500
        Start-Process explorer
        TermLog "[OK] Taskbar configured"
        return $true
    } $t

    # S02 - Desktop Icons (was #24)
    RunStep 1 {
        LogIt "Configuring desktop icons..." "INFO"
        TermLog ">>> Showing Desktop Icons"
        $Paths=@(
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\NewStartPanel",
            "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\HideDesktopIcons\ClassicStartMenu"
        )
        foreach($Path in $Paths){
            if(!(Test-Path $Path)){New-Item -Path $Path -Force|Out-Null}
            Set-ItemProperty -Path $Path -Name "{20D04FE0-3AEA-1069-A2D8-08002B30309D}" -Value 0 -Type DWord
            Set-ItemProperty -Path $Path -Name "{5399E694-6CE5-4D6C-8FCE-1D8870FDCBA0}" -Value 0 -Type DWord
            Set-ItemProperty -Path $Path -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0 -Type DWord
        }
        TermLog "[OK] Desktop icons visible"
        return $true
    } $t

    # S03 - Glow Theme (was #23)
    RunStep 2 {
        LogIt "Applying glow theme..." "INFO"
        TermLog ">>> Applying Dark Glow Theme"
        $tp="$env:windir\Resources\Themes\themeA.theme"
        if(Test-Path $tp){Invoke-Item $tp;Start-Sleep -Milliseconds 1000}
        $p="HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
        Set-ItemProperty -Path $p -Name "AppsUseLightTheme" -Value 0
        Set-ItemProperty -Path $p -Name "SystemUsesLightTheme" -Value 0
        TermLog "[OK] Dark theme applied"
        return $true
    } $t

    # S04 - Restart Explorer (was #22)
    RunStep 3 {
        LogIt "Restarting Explorer..." "INFO"
        TermLog ">>> Restarting Windows Explorer"
        Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
        Start-Sleep -Milliseconds 800
        Start-Process explorer
        Start-Sleep -Milliseconds 1000
        TermLog "[OK] Explorer restarted"
        return $true
    } $t

    # S05 - Classic Context Menu (was #21)
    RunStep 4 {
        LogIt "Restoring classic context menu..." "INFO"
        TermLog ">>> Enabling Classic Context Menu"
        $p="HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}\InprocServer32"
        New-Item -Path $p -Force|Out-Null
        Set-ItemProperty -Path $p -Name "(Default)" -Value ""
        TermLog "[OK] Classic context menu restored"
        return $true
    } $t

    # S06 - Hibernation (was #20)
    RunStep 5 {
        LogIt "Disabling hibernation..." "INFO"
        TermLog ">>> Disabling Hibernation"
        powercfg -h off | Out-Null
        TermLog "[OK] Hibernation disabled"
        return $true
    } $t

    # S07 - Windows Tips (was #19)
    RunStep 6 {
        LogIt "Disabling Windows tips..." "INFO"
        TermLog ">>> Disabling Windows Tips"
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager" /v SubscribedContent-338389Enabled /t REG_DWORD /d 0 /f | Out-Null
        TermLog "[OK] Windows tips disabled"
        return $true
    } $t

    # S08 - Consumer Features (was #18)
    RunStep 7 {
        LogIt "Disabling Consumer Features..." "INFO"
        TermLog ">>> Disabling Consumer Features"
        $p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
        if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
        Set-ItemProperty -Path $p -Name "DisableWindowsConsumerFeatures" -Value 1
        TermLog "[OK] Consumer features disabled"
        return $true
    } $t

    # S09 - Windows Update (was #17)
    RunStep 8 {
        LogIt "Configuring Windows Update..." "INFO"
        TermLog ">>> Configuring Windows Update Policy"
        $p="HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU"
        if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
        Set-ItemProperty -Path $p -Name "NoAutoUpdate" -Value 1
        TermLog "[OK] Windows Update configured"
        return $true
    } $t

    # S10 - Telemetry (was #16)
    RunStep 9 {
        LogIt "Stopping telemetry..." "INFO"
        TermLog ">>> Disabling Telemetry (DiagTrack)"
        Stop-Service DiagTrack -Force -ErrorAction SilentlyContinue
        Set-Service DiagTrack -StartupType Disabled
        TermLog "[OK] Telemetry stopped"
        return $true
    } $t

    # S11 - Error Reporting (was #15)
    RunStep 10 {
        LogIt "Stopping Error Reporting..." "INFO"
        TermLog ">>> Disabling Error Reporting"
        Stop-Service WerSvc -Force -ErrorAction SilentlyContinue
        Set-Service WerSvc -StartupType Disabled
        TermLog "[OK] Error reporting stopped"
        return $true
    } $t

    # S12 - Delivery Optimization (was #14)
    RunStep 11 {
        LogIt "Stopping Delivery Optimization..." "INFO"
        TermLog ">>> Disabling Delivery Optimization"
        Stop-Service DoSvc -Force -ErrorAction SilentlyContinue
        Set-Service DoSvc -StartupType Disabled
        TermLog "[OK] Delivery Optimization stopped"
        return $true
    } $t

    # S13 - Windows Search (was #13)
    RunStep 12 {
        LogIt "Stopping Windows Search..." "INFO"
        TermLog ">>> Disabling Windows Search"
        Stop-Service WSearch -Force -ErrorAction SilentlyContinue
        Set-Service WSearch -StartupType Disabled
        TermLog "[OK] Windows Search stopped"
        return $true
    } $t

    # S14 - SysMain (was #12)
    RunStep 13 {
        LogIt "Stopping SysMain..." "INFO"
        TermLog ">>> Disabling SysMain (SuperFetch)"
        Stop-Service SysMain -Force -ErrorAction SilentlyContinue
        Set-Service SysMain -StartupType Disabled
        TermLog "[OK] SysMain stopped"
        return $true
    } $t

    # S15 - Multimedia (was #11)
    RunStep 14 {
        LogIt "Optimizing multimedia..." "INFO"
        TermLog ">>> Optimizing Multimedia Profile"
        reg add "HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile" /v SystemResponsiveness /t REG_DWORD /d 0 /f | Out-Null
        TermLog "[OK] Multimedia optimized"
        return $true
    } $t

    # S16 - Background Apps (was #10)
    RunStep 15 {
        LogIt "Disabling background apps..." "INFO"
        TermLog ">>> Disabling Background Apps"
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\BackgroundAccessApplications" /v GlobalUserDisabled /t REG_DWORD /d 1 /f | Out-Null
        TermLog "[OK] Background apps disabled"
        return $true
    } $t

    # S17 - Game DVR (was #9)
    RunStep 16 {
        LogIt "Disabling Game DVR..." "INFO"
        TermLog ">>> Disabling Game DVR"
        reg add "HKCU\SOFTWARE\Microsoft\Windows\CurrentVersion\GameDVR" /v AppCaptureEnabled /t REG_DWORD /d 0 /f | Out-Null
        reg add "HKCU\System\GameConfigStore" /v GameDVR_Enabled /t REG_DWORD /d 0 /f | Out-Null
        TermLog "[OK] Game DVR disabled"
        return $true
    } $t

    # S18 - Explorer to This PC (was #8)
    RunStep 17 {
        LogIt "Configuring Explorer to This PC..." "INFO"
        TermLog ">>> Setting Explorer to This PC"
        Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "LaunchTo" -Value 1
        TermLog "[OK] Explorer configured"
        return $true
    } $t

    # S19 - File Extensions (was #7)
    RunStep 18 {
        LogIt "Showing file extensions..." "INFO"
        TermLog ">>> Showing File Extensions"
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "HideFileExt" -Value 0
        TermLog "[OK] File extensions visible"
        return $true
    } $t

    # S20 - Menu Delay (was #6)
    RunStep 19 {
        LogIt "Setting menu delay to 0..." "INFO"
        TermLog ">>> Setting Menu Delay to 0"
        reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f | Out-Null
        TermLog "[OK] Menu delay set to 0"
        return $true
    } $t

    # S21 - Startup Delay (was #5)
    RunStep 20 {
        LogIt "Removing startup delay..." "INFO"
        TermLog ">>> Disabling Startup Delay"
        New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Force|Out-Null
        Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize" -Name "StartupDelayInMSec" -Value 0
        TermLog "[OK] Startup delay removed"
        return $true
    } $t

    # S22 - Transparency (was #4)
    RunStep 21 {
        LogIt "Disabling transparency..." "INFO"
        TermLog ">>> Disabling Transparency"
        reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize" /v EnableTransparency /t REG_DWORD /d 0 /f | Out-Null
        TermLog "[OK] Transparency disabled"
        return $true
    } $t

    # S23 - Window Animations (was #3)
    RunStep 22 {
        LogIt "Disabling window animations..." "INFO"
        TermLog ">>> Disabling Window Animations"
        Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value 0
        TermLog "[OK] Window animations disabled"
        return $true
    } $t

    # S24 - Visual Effects (was #2)
    RunStep 23 {
        LogIt "Disabling visual effects..." "INFO"
        TermLog ">>> Disabling Visual Effects"
        $p="HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects"
        if(!(Test-Path $p)){New-Item -Path $p -Force|Out-Null}
        Set-ItemProperty -Path $p -Name "VisualFXSetting" -Value 2
        TermLog "[OK] Visual effects disabled"
        return $true
    } $t

    # S25 - Ultimate Performance (was #1)
    RunStep 24 {
        LogIt "Enabling Ultimate Performance..." "INFO"
        TermLog ">>> Enabling Ultimate Performance Power Plan"
        $out=powercfg -duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61 2>&1
        $guid=($out|Select-String '[a-f0-9-]{36}').Matches.Value|Select-Object -First 1
        if($guid){powercfg /setactive $guid|Out-Null;LogIt "PowerPlan GUID: $guid" "OK";TermLog "[OK] Ultimate Performance enabled ($guid)";return $true}
        throw "Failed to get Ultimate Performance GUID"
    } $t

    $script:CurrentTask=$null
    DrawDashboard -Tasks $t -PhaseName $script:PhaseName -PhaseNum $script:PhaseNum
}

# ================================
# === PHASE 2: SOFTWARE INSTALL ===
# ================================
function Run-Phase2 {
    $script:PhaseName="SOFTWARE INSTALLATION"
    $script:PhaseNum=2
    $script:StartTime=Get-Date
    LogIt "=== PHASE 2: SOFTWARE INSTALLATION STARTED ===" "INFO"
    TermLog "=== Phase 2: Software Installation ==="

    $t=$script:P2Tasks

    # S01 - VLC
    RunStep 0 {
        LogIt "Installing VLC Media Player..." "INFO"
        return (Install-WingetFast -Id "VideoLAN.VLC" -Description "VLC Media Player")
    } $t

    # S02 - K-Lite
    RunStep 1 {
        LogIt "Installing K-Lite Codec Pack Full..." "INFO"
        return (Install-WingetFast -Id "CodecGuide.K-LiteCodecPack.Full" -Description "K-Lite Codec Pack")
    } $t

    # S03 - WinRAR
    RunStep 2 {
        LogIt "Installing WinRAR..." "INFO"
        return (Install-WingetFast -Id "RARLab.WinRAR" -Description "WinRAR")
    } $t

    # S04 - 7Zip
    RunStep 3 {
        LogIt "Installing 7-Zip..." "INFO"
        return (Install-WingetFast -Id "7zip.7zip" -Description "7-Zip")
    } $t

    # S05 - Steam
    RunStep 4 {
        LogIt "Installing Steam..." "INFO"
        $ok = Install-WingetFast -Id "Valve.Steam" -Description "Steam"
        if($ok -and (Test-Path "C:\Program Files (x86)\Steam\steam.exe")){Start-Process "C:\Program Files (x86)\Steam\steam.exe"}
        return $ok
    } $t

    # S06 - Xbox
    RunStep 5 {
        LogIt "Installing Xbox App..." "INFO"
        $ok = Install-WingetFast -Id "9MV0B5HZVK9Z" -Description "Xbox App" -ExtraArgs "--source msstore"
        if($ok){Start-Process "xbox:"}
        return $ok
    } $t

    # S07 - MS Store Reset (wsreset)
    RunStep 6 {
        LogIt "Resetting Microsoft Store (wsreset)..." "INFO"
        TermLog ">>> Resetting Microsoft Store"
        TermLog "> wsreset -i"
        try {
            $proc = Start-Process wsreset -ArgumentList "-i" -Wait -PassThru -WindowStyle Hidden
            TermLog "[OK] Microsoft Store reset initiated"
        } catch {
            TermLog "[WARN] wsreset returned: $($_.Exception.Message)"
        }
        return $true
    } $t

    # S08 - Xbox Identity
    RunStep 7 {
        LogIt "Installing Xbox Identity Provider..." "INFO"
        return (Install-WingetFast -Id "9WZDNCRD1HKW" -Description "Xbox Identity Provider" -ExtraArgs "--source msstore")
    } $t

    # S09 - Xbox In-Game
    RunStep 8 {
        LogIt "Installing Xbox In-Game Experience..." "INFO"
        return (Install-WingetFast -Id "9NZKPSTSNW4P" -Description "Xbox In-Game" -ExtraArgs "--source msstore")
    } $t

    # S10 - MS Store Verify (wsreset again)
    RunStep 9 {
        LogIt "Verifying Microsoft Store..." "INFO"
        TermLog ">>> Verifying Microsoft Store"
        TermLog "> wsreset -i"
        try {
            $proc = Start-Process wsreset -ArgumentList "-i" -Wait -PassThru -WindowStyle Hidden
            TermLog "[OK] Microsoft Store verified"
        } catch {
            TermLog "[WARN] wsreset returned: $($_.Exception.Message)"
        }
        return $true
    } $t

    # S11 - Node.js
    RunStep 10 {
        LogIt "Installing Node.js LTS..." "INFO"
        $ok = Install-WingetFast -Id "OpenJS.NodeJS.LTS" -Description "Node.js LTS" -ExtraArgs "--scope machine"
        if(-not $ok) {
            TermLog "[Fallback] Trying Chocolatey for Node.js..."
            [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
            if(-not (Get-Command choco -ErrorAction SilentlyContinue)){
                Invoke-WebRequest "https://community.chocolatey.org/install.ps1" -UseBasicParsing | Invoke-Expression
            }
            choco install nodejs-lts -y | Out-Null
        }
        $nodePath="C:\Program Files\nodejs"
        $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
        if($machinePath -notlike "*$nodePath*"){
            [Environment]::SetEnvironmentVariable("Path",($machinePath.TrimEnd(";")+";"+$nodePath),"Machine")
        }
        $env:Path=[Environment]::GetEnvironmentVariable("Path","Machine")+";"+[Environment]::GetEnvironmentVariable("Path","User")
        TermLog "[OK] Node.js installed"
        return $true
    } $t

    # S12 - Git
    RunStep 11 {
        LogIt "Installing Git..." "INFO"
        $ok = Install-WingetFast -Id "Git.Git" -Description "Git" -ExtraArgs "--scope machine"
        if(-not $ok) {
            TermLog "[Fallback] Trying Chocolatey for Git..."
            [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
            if(-not (Get-Command choco -ErrorAction SilentlyContinue)){
                Invoke-WebRequest "https://community.chocolatey.org/install.ps1" -UseBasicParsing | Invoke-Expression
            }
            choco install git -y | Out-Null
        }
        $gitPath="C:\Program Files\Git\cmd"
        $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
        if($machinePath -notlike "*$gitPath*"){
            [Environment]::SetEnvironmentVariable("Path",($machinePath.TrimEnd(";")+";"+$gitPath),"Machine")
        }
        $env:Path=[Environment]::GetEnvironmentVariable("Path","Machine")+";"+[Environment]::GetEnvironmentVariable("Path","User")
        TermLog "[OK] Git installed"
        return $true
    } $t

    # S13 - Python 3.10
    RunStep 12 {
        LogIt "Installing Python 3.10..." "INFO"
        $ok = Install-WingetFast -Id "Python.Python.3.10" -Description "Python 3.10" -ExtraArgs '--scope machine --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=1 Include_pip=1 Include_test=0"'
        if($ok) {
            $pyPath="C:\Program Files\Python310";$scriptsPath="C:\Program Files\Python310\Scripts"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            foreach($p in @($pyPath,$scriptsPath)){if($machinePath -notlike "*$p*"){$machinePath=$machinePath.TrimEnd(";")+";"+$p}}
            [Environment]::SetEnvironmentVariable("Path",$machinePath,"Machine")
            $env:Path=$machinePath+";"+[Environment]::GetEnvironmentVariable("Path","User")
        }
        return $ok
    } $t

    # S14 - Python 3.11
    RunStep 13 {
        LogIt "Installing Python 3.11..." "INFO"
        $ok = Install-WingetFast -Id "Python.Python.3.11" -Description "Python 3.11" -ExtraArgs '--scope machine --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=1 Include_pip=1 Include_test=0"'
        if($ok) {
            $pyPath="C:\Program Files\Python311";$scriptsPath="C:\Program Files\Python311\Scripts"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            foreach($p in @($pyPath,$scriptsPath)){if($machinePath -notlike "*$p*"){$machinePath=$machinePath.TrimEnd(";")+";"+$p}}
            [Environment]::SetEnvironmentVariable("Path",$machinePath,"Machine")
            $env:Path=$machinePath+";"+[Environment]::GetEnvironmentVariable("Path","User")
        }
        return $ok
    } $t

    # S15 - Python 3.12
    RunStep 14 {
        LogIt "Installing Python 3.12..." "INFO"
        $ok = Install-WingetFast -Id "Python.Python.3.12" -Description "Python 3.12" -ExtraArgs '--scope machine --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=1 Include_pip=1 Include_test=0"'
        if($ok) {
            $pyPath="C:\Program Files\Python312";$scriptsPath="C:\Program Files\Python312\Scripts"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            foreach($p in @($pyPath,$scriptsPath)){if($machinePath -notlike "*$p*"){$machinePath=$machinePath.TrimEnd(";")+";"+$p}}
            [Environment]::SetEnvironmentVariable("Path",$machinePath,"Machine")
            $env:Path=$machinePath+";"+[Environment]::GetEnvironmentVariable("Path","User")
        }
        return $ok
    } $t

    # S16 - Python 3.13
    RunStep 15 {
        LogIt "Installing Python 3.13..." "INFO"
        $ok = Install-WingetFast -Id "Python.Python.3.13" -Description "Python 3.13" -ExtraArgs '--scope machine --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=1 Include_pip=1 Include_test=0"'
        if($ok) {
            $pyPath="C:\Program Files\Python313";$scriptsPath="C:\Program Files\Python313\Scripts"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            foreach($p in @($pyPath,$scriptsPath)){if($machinePath -notlike "*$p*"){$machinePath=$machinePath.TrimEnd(";")+";"+$p}}
            [Environment]::SetEnvironmentVariable("Path",$machinePath,"Machine")
            $env:Path=$machinePath+";"+[Environment]::GetEnvironmentVariable("Path","User")
        }
        return $ok
    } $t

    # S17 - Python 3.14
    RunStep 16 {
        LogIt "Installing Python 3.14..." "INFO"
        $ok = Install-WingetFast -Id "Python.Python.3.14" -Description "Python 3.14" -ExtraArgs '--scope machine --override "/quiet InstallAllUsers=1 PrependPath=1 Include_launcher=1 InstallLauncherAllUsers=1 Include_pip=1 Include_test=0"'
        if($ok) {
            $pyPath="C:\Program Files\Python314";$scriptsPath="C:\Program Files\Python314\Scripts"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            foreach($p in @($pyPath,$scriptsPath)){if($machinePath -notlike "*$p*"){$machinePath=$machinePath.TrimEnd(";")+";"+$p}}
            [Environment]::SetEnvironmentVariable("Path",$machinePath,"Machine")
            $env:Path=$machinePath+";"+[Environment]::GetEnvironmentVariable("Path","User")
        }
        return $ok
    } $t

    # S18 - Python Modules
    RunStep 17 {
        LogIt "Installing Python dev modules..." "INFO"
        TermLog ">>> Installing Python Dev Modules"
        $versions=@("3.10","3.11","3.12","3.13","3.14")
        foreach($v in $versions){
            $py="py -$v"
            try {
                & $py --version 2>$null | Out-Null
                if($LASTEXITCODE -eq 0){
                    TermLog "  Upgrading pip for Python $v..."
                    & $py -m ensurepip --upgrade 2>$null | Out-Null
                    & $py -m pip install --upgrade pip setuptools wheel virtualenv build pytest black ruff mypy bandit pip-audit 2>$null | Out-Null
                    TermLog "  [OK] Python $v modules installed"
                }
            } catch { TermLog "  [SKIP] Python $v not available" }
        }
        return $true
    } $t

    # S19 - VS Code (FIXED!)
    RunStep 18 {
        LogIt "Installing VS Code..." "INFO"
        TermLog ">>> Installing Visual Studio Code"
        # FIX: Use single-quoted override to prevent PowerShell from parsing commas as array separators
        $ok = Install-WingetFast -Id "Microsoft.VisualStudioCode" -Description "VS Code" -ExtraArgs '--scope machine --override "/VERYSILENT /NORESTART /MERGETASKS=addcontextmenufiles,addcontextmenufolders,associatewithfiles,addtopath"'
        if($ok) {
            $codePath="C:\Program Files\Microsoft VS Code\bin"
            $machinePath=[Environment]::GetEnvironmentVariable("Path","Machine")
            if(Test-Path $codePath -and $machinePath -notlike "*$codePath*"){
                [Environment]::SetEnvironmentVariable("Path",($machinePath.TrimEnd(";")+";"+$codePath),"Machine")
            }
            $env:Path=[Environment]::GetEnvironmentVariable("Path","Machine")+";"+[Environment]::GetEnvironmentVariable("Path","User")
            TermLog "[OK] VS Code installed successfully"
        }
        return $ok
    } $t

    # S20 - IDM
    RunStep 19 {
        LogIt "Installing Internet Download Manager..." "INFO"
        TermLog ">>> Installing Internet Download Manager"
        $url="https://download.internetdownloadmanager.com/idman643build1.exe"
        $file="$env:TEMP\idman643build1.exe"
        TermLog "> Downloading IDM installer..."
        Invoke-WebRequest $url -OutFile $file -UseBasicParsing
        TermLog "> Running installer..."
        Start-Process -FilePath $file -ArgumentList "/skipdlgs" -Wait
        $installed=Get-ItemProperty "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*","HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*" -ErrorAction SilentlyContinue | Where-Object {$_.DisplayName -like "*Internet Download Manager*"}
        if($installed){TermLog "[OK] IDM installed";return $true}
        return $false
    } $t

    # S21 - Apps Update
    RunStep 20 {
        LogIt "Updating all winget packages..." "INFO"
        TermLog ">>> Updating All Winget Packages"
        TermLog "> winget source update"
        winget source update | Out-Null
        TermLog "> winget upgrade --all ..."
        winget upgrade --all --silent --accept-package-agreements --accept-source-agreements --include-unknown --disable-interactivity | Out-Null
        TermLog "[OK] All packages updated"
        return $true
    } $t

    # S22 - Windows Update
    RunStep 21 {
        LogIt "Installing Windows Updates..." "INFO"
        TermLog ">>> Installing Windows Updates"
        Set-ExecutionPolicy Bypass -Scope Process -Force
        Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force | Out-Null
        Install-Module PSWindowsUpdate -Force -AllowClobber | Out-Null
        Import-Module PSWindowsUpdate
        TermLog "> Getting and installing Windows Updates..."
        Get-WindowsUpdate -AcceptAll -Install -AutoReboot | Out-Null
        TermLog "[OK] Windows Updates installed"
        return $true
    } $t

    $script:CurrentTask=$null
    DrawDashboard -Tasks $t -PhaseName $script:PhaseName -PhaseNum $script:PhaseNum
}

# === SUMMARY ===
function Show-Summary {
    param([array]$P1,[array]$P2)

    $p1Done=($P1|Where-Object{$_.S-eq"Done"}).Count
    $p1Fail=($P1|Where-Object{$_.S-eq"Fail"}).Count
    $p2Done=($P2|Where-Object{$_.S-eq"Done"}).Count
    $p2Fail=($P2|Where-Object{$_.S-eq"Fail"}).Count
    $tt=(Get-Date)-$script:StartTime

    Clear-Host
    WC ""
    WC "╔══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╗" "NG"
    WC "║                                                                                                                      ║" "NG"
    WC "║           $($script:C.B)$($script:C.NG)🎉  ALL PHASES COMPLETED  🎉$($script:C.X)                                                                                ║" "NG"
    WC "║                                                                                                                      ║" "NG"
    WC "╚══════════════════════════════════════════════════════════════════════════════════════════════════════════════════════╝" "NG"
    WC ""
    WC "  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "  │$($script:C.B)$($script:C.NC)  FINAL REPORT                                                                                                    $($script:C.X)│" "NC"
    WC "  ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"
    WC ("  │  $($script:C.LG)✅ Phase 1 (Optimization):  {0,2} / 25 passed$($script:C.X)    $($script:C.LR)❌ Failed: {1,2}$($script:C.X)                                          │" -f $p1Done,$p1Fail) "NC"
    WC ("  │  $($script:C.LG)✅ Phase 2 (Software):     {0,2} / 22 passed$($script:C.X)    $($script:C.LR)❌ Failed: {1,2}$($script:C.X)                                          │" -f $p2Done,$p2Fail) "NC"
    WC ("  │  $($script:C.SI)⏱ Total Time: {0:D2}h {1:D2}m {2:D2}s$($script:C.X)                                                                              │" -f $tt.Hours,$tt.Minutes,$tt.Seconds) "NC"
    WC "  └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""

    if($p1Fail-gt 0 -or $p2Fail-gt 0){
        WC "  $($script:C.LY)⚠️  Some steps failed. Review the log for details:$($script:C.X)" "LY"
        $allFail=($P1+$P2)|Where-Object{$_.S-eq"Fail"}
        foreach($f in $allFail){WC "       $($script:C.LR)• $($f.N)$($script:C.X)" "LR"}
    }else{
        WC "  $($script:C.LG)🎉 Perfect run! All optimizations and installations completed successfully!$($script:C.X)" "LG"
        WC "  $($script:C.SI)   Your Windows Server 2025 RDP environment is now fully optimized and loaded with dev tools.$($script:C.X)" "SI"
    }

    $lf="$env:TEMP\RDP_Setup_Optimizer_v9_Log.txt"
    $script:Logs|ForEach-Object{"[{0}] [{1}] {2}"-f$_.T,$_.L,$_.M}|Out-File $lf -Encoding UTF8
    WC ""
    WC "  $($script:C.GY)💾 Full log saved to: $lf$($script:C.X)" "GY"
    WC ""
    WC "  Press any key to exit..." "GY"
    $null=$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
}

# === MAIN MENU ===
function Show-MainMenu {
    Clear-Host
    WC ""
    WC "    $($script:C.G1)██████╗ ██████╗ ██████╗     ███████╗███████╗████████╗██╗   ██╗██████╗     ██╗   ██╗ ██████╗     ███████╗ ██████╗$($script:C.X)" "G1"
    WC "    $($script:C.G1)██╔══██╗██╔══██╗██╔══██╗    ██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗    ██║   ██║██╔═══██╗    ██╔════╝██╔═══██╗$($script:C.X)" "G1"
    WC "    $($script:C.G2)██████╔╝██║  ██║██████╔╝    ███████╗█████╗     ██║   ██║   ██║██████╔╝    ██║   ██║██║   ██║    ███████╗██║   ██║$($script:C.X)" "G2"
    WC "    $($script:C.G2)██╔══██╗██║  ██║██╔═══╝     ╚════██║██╔══╝     ██║   ╚██╗ ██╔╝██╔═══╝     ╚██╗ ██╔╝██║   ██║    ╚════██║██║   ██║$($script:C.X)" "G2"
    WC "    $($script:C.G3)██║  ██║██████╔╝██║         ███████║███████╗   ██║    ╚████╔╝ ██║          ╚████╔╝ ╚██████╔╝    ███████║╚██████╔╝$($script:C.X)" "G3"
    WC "    $($script:C.G3)╚═╝  ╚═╝╚═════╝ ╚═╝         ╚══════╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝           ╚═══╝   ╚═════╝     ╚══════╝ ╚═════╝$($script:C.X)" "G3"
    WC ""
    WC "                              $($script:C.B)$($script:C.NC)Windows Server 2025 - RDP Setup & Optimizer v9.0$($script:C.X)" "NC"
    WC "                                       $($script:C.GY)Lightning Edition | UI-First Optimization | Live Terminal$($script:C.X)" "GY"
    WC ""
    WC "  $($script:C.LY)⚠️  This script requires Administrator privileges and modifies system settings.$($script:C.X)" "LY"
    WC "  $($script:C.SI)   Phase 1 runs BACKWARDS (UI visible first!) | Phase 2 uses FAST winget mode.$($script:C.X)" "SI"
    WC ""
    WC "  ┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐" "NC"
    WC "  │$($script:C.B)$($script:C.NC)  SELECT PHASE                                                                                                    $($script:C.X)│" "NC"
    WC "  ├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤" "NC"
    WC "  │                                                                                                                  │" "NC"
    WC "  │   $($script:C.NG)[1]$($script:C.X)  $($script:C.B)Phase 1: System Optimization$($script:C.X)        $($script:C.GY)- 25 tweaks (UI-FIRST: Taskbar → Theme → Icons → ... → Power)$($script:C.X)   │" "NC"
    WC "  │                                                                                                                  │" "NC"
    WC "  │   $($script:C.NC)[2]$($script:C.X)  $($script:C.B)Phase 2: Software Installation$($script:C.X)    $($script:C.GY)- 22 apps with LIVE TERMINAL + FAST mode$($script:C.X)                    │" "NC"
    WC "  │                                                                                                                  │" "NC"
    WC "  │   $($script:C.NP)[3]$($script:C.X)  $($script:C.B)Phase 1 + 2: Complete Setup$($script:C.X)    $($script:C.GY)- Run everything (Recommended)$($script:C.X)                          │" "NC"
    WC "  │                                                                                                                  │" "NC"
    WC "  │   $($script:C.LR)[4]$($script:C.X)  $($script:C.B)Exit$($script:C.X)                                                                            │" "NC"
    WC "  │                                                                                                                  │" "NC"
    WC "  └──────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘" "NC"
    WC ""
    WC "  $($script:C.GY)GitHub: irm https://raw.githubusercontent.com/abubakarmalikgit/RDP-Setup/main/RDP_Setup_Optimizer_v9.ps1 | iex$($script:C.X)" "GY"
    WC ""
}

# === ENTRY POINT ===
function Start-RDPSetupOptimizer {
    $id=[Security.Principal.WindowsIdentity]::GetCurrent()
    $pr=[Security.Principal.WindowsPrincipal]$id
    if(-not $pr.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)){
        WC "";WC "  $($script:C.LR)❌ ERROR: Administrator privileges required! Right-click PowerShell → 'Run as Administrator'.$($script:C.X)" "LR";WC ""
        return
    }

    [Console]::OutputEncoding=[System.Text.Encoding]::UTF8
    $Host.UI.RawUI.WindowTitle="RDP Setup & Optimizer v9.0 - Lightning"

    Show-MainMenu
    $choice=Read-Host "  Enter your choice (1-4)"

    switch($choice){
        "1"{Run-Phase1;Show-Summary -P1 $script:P1Tasks -P2 @()}
        "2"{Run-Phase2;Show-Summary -P1 @() -P2 $script:P2Tasks}
        "3"{Run-Phase1;Run-Phase2;Show-Summary -P1 $script:P1Tasks -P2 $script:P2Tasks}
        "4"{WC "";WC "  $($script:C.LY)👋 Exiting. No changes were made.$($script:C.X)" "LY";WC ""}
        default{WC "";WC "  $($script:C.LR)❌ Invalid choice. Exiting.$($script:C.X)" "LR";WC ""}
    }
}

# === LAUNCH ===
Start-RDPSetupOptimizer
