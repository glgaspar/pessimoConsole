<#
.SYNOPSIS
    PessimoConsole Automated Provisioning Script
    Developed by PessimaIdeia Inc. (https://corporate.pessimaideia.com/)
    Target: Samsung Expert X51 Couch Console Setup

    Options Included:
    - 1: High Performance Power & Lid/Sleep Bypass
    - 2: Windows Auto-Logon Setup
    - 3: Windows 10 Console Debloat & Optimization (PessimaIdeia Signature Edition)
    - 4: Playnite Installation (Auto-downloads if missing)
    - 5: Game Launchers Selection & Auto-installation (Winget + direct download)
    - 6: HackBGRT Setup (Auto-downloads, copies splash.bmp, runs in batch mode)
    - 7: Playnite Console Boot Mode (Autostart vs Custom Shell, with recovery option)
#>

# ==========================================
# 0. PRIVILEGE ELEVATION & PREPARATION
# ==========================================
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host "Elevating privileges to Administrator..." -ForegroundColor Yellow
    Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
    Exit
}

Set-ExecutionPolicy Unrestricted -Scope Process -Force
$ScriptDir = $PSScriptRoot

[Net.ServicePointManager]::SecurityProtocol = 3072 -bor 12288
[Net.ServicePointManager]::ServerCertificateValidationCallback = { $true }

function Download-File {
    param (
        [string]$Uri,
        [string]$Path
    )
    $webClient = New-Object System.Net.WebClient
    $webClient.Headers.Add("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36")
    $webClient.DownloadFile($Uri, $Path)
}

[console]::BackgroundColor = 'Black'
Clear-Host

# PessimaIdeia custom theme
$BrandAccent = "$([char]27)[38;2;179;7;139m"    # #b3078b Accent
$BrandMuted  = "$([char]27)[38;2;120;0;90m"     # Darker accent
$BrandDark   = "$([char]27)[38;2;140;140;140m"  # Gray for logs
$BrandGreen  = "$([char]27)[38;2;50;200;120m"   # Success/Action green
$BrandYellow = "$([char]27)[38;2;240;180;20m"   # Warning yellow
$BrandRed    = "$([char]27)[38;2;240;50;50m"    # Error red
$ResetColor  = "$([char]27)[0m"

Write-Host "${BrandAccent}==========================================${ResetColor}"
Write-Host "${BrandAccent}   PESSIMOCONSOLE AUTOMATED PROVISIONING  ${ResetColor}"
Write-Host "${BrandMuted}        Powered by PessimaIdeia Inc.      ${ResetColor}"
Write-Host "${BrandAccent}==========================================${ResetColor}"

# ==========================================
# MODULE 1: POWER & LID SETTINGS
# ==========================================
Write-Host "`n${BrandGreen}[1/7] Applying Power & Lid Behavior Settings...${ResetColor}"

powercfg /s 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c
powercfg /setacvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT SUB_BUTTONS LIDACTION 0 2>$null
powercfg /change monitor-timeout-ac 0 2>$null
powercfg /change monitor-timeout-dc 0 2>$null
powercfg /change standby-timeout-ac 0 2>$null
powercfg /change standby-timeout-dc 0 2>$null
powercfg /change hibernate-timeout-ac 0 2>$null
powercfg /change hibernate-timeout-dc 0 2>$null
powercfg /setacvalueindex SCHEME_CURRENT 2a737441-1bc6-4bf0-b40d-e22f99f7a07c 48e7f87c-a338-4145-901d-6527454a360d 0 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT 2a737441-1bc6-4bf0-b40d-e22f99f7a07c 48e7f87c-a338-4145-901d-6527454a360d 0 2>$null
powercfg /setacvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a821a0626318 ee12f206-e0ef-4f1b-a53a-9984083a2e08 0 2>$null
powercfg /setdcvalueindex SCHEME_CURRENT 501a4d13-42af-4429-9fd1-a821a0626318 ee12f206-e0ef-4f1b-a53a-9984083a2e08 0 2>$null

$DesktopPath = "HKCU:\Control Panel\Desktop"
if (-not (Test-Path $DesktopPath)) { New-Item -Path $DesktopPath -Force | Out-Null }
Set-ItemProperty -Path $DesktopPath -Name "ScreenSaveActive" -Value "0"
Set-ItemProperty -Path $DesktopPath -Name "ScreenSaverIsSecure" -Value "0"
Remove-ItemProperty -Path $DesktopPath -Name "SCRNSAVE.EXE" -ErrorAction SilentlyContinue

powercfg /setactive SCHEME_CURRENT
Write-Host "${BrandDark}-> Power set to High Performance. Lid closure sleep, standby, hibernate, and screen timeouts disabled.${ResetColor}"

# ==========================================
# MODULE 2: AUTOMATIC USER LOGON
# ==========================================
Write-Host "`n${BrandGreen}[2/7] Configuring Auto-Logon for TV Console Experience...${ResetColor}"
$WinLogonPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon"

$DefaultUser = $env:UserName
$TargetUser = Read-Host "Enter Windows Username for Auto-Logon [Default: $DefaultUser]"
if ([string]::IsNullOrWhiteSpace($TargetUser)) { $TargetUser = $DefaultUser }

$TargetPass = Read-Host "Enter Password for $TargetUser (Leave blank if no password)" -AsSecureString
$BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($TargetPass)
$PlainPass = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

Set-ItemProperty -Path $WinLogonPath -Name "AutoAdminLogon" -Value "1"
Set-ItemProperty -Path $WinLogonPath -Name "DefaultUserName" -Value $TargetUser
Set-ItemProperty -Path $WinLogonPath -Name "DefaultPassword" -Value $PlainPass
Remove-ItemProperty -Path $WinLogonPath -Name "AutoLogonCOUNT" -ErrorAction SilentlyContinue

Write-Host "${BrandDark}-> Auto-Logon configured for account: $TargetUser${ResetColor}"

# ==========================================
# MODULE 3: WINDOWS 10 CONSOLE DEBLOAT & OPTIMIZATION
# ==========================================
Write-Host "`n${BrandGreen}[3/7] Debloating & Optimizing Windows 10...${ResetColor}"

Write-Host "${BrandDark}-> Disabling Telemetry & Diagnostic Services...${ResetColor}"
$PoliciesPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
if (-not (Test-Path $PoliciesPath)) { New-Item -Path $PoliciesPath -Force | Out-Null }
Set-ItemProperty -Path $PoliciesPath -Name "AllowTelemetry" -Value 0 -Type DWord

Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Stop-Service -Force -Confirm:$false -ErrorAction SilentlyContinue
Get-Service -Name "DiagTrack" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue
Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Stop-Service -Force -Confirm:$false -ErrorAction SilentlyContinue
Get-Service -Name "dmwappushservice" -ErrorAction SilentlyContinue | Set-Service -StartupType Disabled -ErrorAction SilentlyContinue

$UnusedServices = @(
    "SysMain",          # Prevents CPU/Disk spikes (Superfetch)
    "Spooler",          # Print Spooler (no printer needed on a couch console)
    "MapsBroker",       # Downloaded Maps Manager
    "Fax",              # Fax service
    "RemoteRegistry",   # Remote Registry (security risk)
    "WbioSrvc",         # Biometrics (fingerprint/facial recognition not used on a TV console)
    "diagnosticshub.standardcollector.service", # Diagnostics Collector
    "RetailDemo",       # Retail Demo
    "PhoneSvc",         # Phone Service (Your Phone link)
    "WalletService"     # Wallet Service
)
foreach ($SvcName in $UnusedServices) {
    $Svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
    if ($null -ne $Svc) {
        Write-Host "${BrandDark}   Disabling service: $SvcName...${ResetColor}"
        Stop-Service -Name $SvcName -Force -Confirm:$false -ErrorAction SilentlyContinue
        Set-Service -Name $SvcName -StartupType Disabled -ErrorAction SilentlyContinue
    }
}

Write-Host "${BrandDark}-> Disabling background telemetry tasks...${ResetColor}"
$TelemetryTasks = @(
    "Microsoft\Windows\Application Experience\Microsoft Compatibility Appraiser",
    "Microsoft\Windows\Application Experience\ProgramDataUpdater",
    "Microsoft\Windows\Application Experience\StartupAppTask",
    "Microsoft\Windows\Customer Experience Improvement Program\Consolidator",
    "Microsoft\Windows\Customer Experience Improvement Program\UsbCeip",
    "Microsoft\Windows\DiskDiagnostic\Microsoft-Windows-DiskDiagnosticDataCollector",
    "Microsoft\Windows\Power Efficiency Diagnostics\AnalyzeSystem"
)
foreach ($Task in $TelemetryTasks) {
    Disable-ScheduledTask -TaskName (Split-Path $Task -Leaf) -TaskPath (Split-Path $Task) -ErrorAction SilentlyContinue | Out-Null
}

Write-Host "${BrandDark}-> Ensuring Bluetooth & Device Installation Services are active (for controllers)...${ResetColor}"
$RequiredServices = @("bthserv", "DeviceAssociationService", "DeviceInstall", "DsmSvc")
foreach ($SvcName in $RequiredServices) {
    $Svc = Get-Service -Name $SvcName -ErrorAction SilentlyContinue
    if ($null -ne $Svc) {
        $StartupType = if ($SvcName -eq "bthserv") { "Automatic" } else { "Manual" }
        Set-Service -Name $SvcName -StartupType $StartupType -ErrorAction SilentlyContinue
        Start-Service -Name $SvcName -ErrorAction SilentlyContinue
    }
}

Get-Service -Name "BluetoothUserService*" -ErrorAction SilentlyContinue | ForEach-Object {
    Start-Service -InputObject $_ -ErrorAction SilentlyContinue
}

Write-Host "${BrandDark}-> Disabling power saving features on Bluetooth and USB controllers...${ResetColor}"
Get-CimInstance -ClassName Win32_PnPEntity | Where-Object { 
    $_.Caption -like "*Bluetooth*" -or 
    $_.Caption -like "*USB Root Hub*" -or 
    $_.Caption -like "*Generic USB Hub*" -or 
    $_.ClassGuid -eq "{e0cbf06c-cd8b-4647-bb8a-263b43f0f974}" # Bluetooth Class GUID
} | ForEach-Object {
    $DeviceId = $_.DeviceID
    $RegPath = "HKLM:\SYSTEM\CurrentControlSet\Enum\$DeviceId"
    if (Test-Path $RegPath) {
        Set-ItemProperty -Path $RegPath -Name "PnPCapabilities" -Value 24 -Type DWord -ErrorAction SilentlyContinue
    }
}

Write-Host "${BrandDark}-> Enabling device installation & driver search settings in registry...${ResetColor}"
$DeviceInstallRegPaths = @(
    "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DeviceInstall\Restrictions"
)
foreach ($RegPath in $DeviceInstallRegPaths) {
    if (Test-Path $RegPath) {
        Remove-ItemProperty -Path $RegPath -Name "DenyDeviceIDs" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "DenyDeviceClasses" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "DenyRemovableDevices" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $RegPath -Name "DenyDeviceIDsRetroactive" -ErrorAction SilentlyContinue
    }
}

$DriverSearchingPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\DriverSearching"
if (-not (Test-Path $DriverSearchingPath)) { New-Item -Path $DriverSearchingPath -Force | Out-Null }
Set-ItemProperty -Path $DriverSearchingPath -Name "SearchOrderConfig" -Value 1 -Type DWord -ErrorAction SilentlyContinue

$DeviceMetadataPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Device Metadata"
if (-not (Test-Path $DeviceMetadataPath)) { New-Item -Path $DeviceMetadataPath -Force | Out-Null }
Set-ItemProperty -Path $DeviceMetadataPath -Name "PreventDeviceMetadataFromNetwork" -Value 0 -Type DWord -ErrorAction SilentlyContinue

$CloudContentPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\CloudContent"
if (-not (Test-Path $CloudContentPath)) { New-Item -Path $CloudContentPath -Force | Out-Null }
Set-ItemProperty -Path $CloudContentPath -Name "DisableWindowsConsumerFeatures" -Value 1 -Type DWord

Write-Host "${BrandDark}-> Disabling Game DVR background recording...${ResetColor}"
$GameConfigStorePath = "HKCU:\System\GameConfigStore"
if (-not (Test-Path $GameConfigStorePath)) { New-Item -Path $GameConfigStorePath -Force | Out-Null }
Set-ItemProperty -Path $GameConfigStorePath -Name "GameDVR_Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

$GameDVRPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\GameDVR"
if (-not (Test-Path $GameDVRPath)) { New-Item -Path $GameDVRPath -Force | Out-Null }
Set-ItemProperty -Path $GameDVRPath -Name "AllowGameDVR" -Value 0 -Type DWord -ErrorAction SilentlyContinue

$SearchPoliciesPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Windows Search"
if (-not (Test-Path $SearchPoliciesPath)) { New-Item -Path $SearchPoliciesPath -Force | Out-Null }
Set-ItemProperty -Path $SearchPoliciesPath -Name "AllowCortana" -Value 0 -Type DWord
Set-ItemProperty -Path $SearchPoliciesPath -Name "DisableWebSearch" -Value 1 -Type DWord
$HKCUSearchPath = "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search"
if (-not (Test-Path $HKCUSearchPath)) { New-Item -Path $HKCUSearchPath -Force | Out-Null }
Set-ItemProperty -Path $HKCUSearchPath -Name "BingSearchEnabled" -Value 0 -Type DWord

Write-Host "${BrandDark}-> Applying responsiveness and usability tweaks...${ResetColor}"

$StickyKeysPath = "HKCU:\Control Panel\Accessibility\StickyKeys"
if (-not (Test-Path $StickyKeysPath)) { New-Item -Path $StickyKeysPath -Force | Out-Null }
Set-ItemProperty -Path $StickyKeysPath -Name "Flags" -Value "506" -ErrorAction SilentlyContinue

$FilterKeysPath = "HKCU:\Control Panel\Accessibility\Keyboard Response"
if (-not (Test-Path $FilterKeysPath)) { New-Item -Path $FilterKeysPath -Force | Out-Null }
Set-ItemProperty -Path $FilterKeysPath -Name "Flags" -Value "122" -ErrorAction SilentlyContinue

$ToggleKeysPath = "HKCU:\Control Panel\Accessibility\ToggleKeys"
if (-not (Test-Path $ToggleKeysPath)) { New-Item -Path $ToggleKeysPath -Force | Out-Null }
Set-ItemProperty -Path $ToggleKeysPath -Name "Flags" -Value "58" -ErrorAction SilentlyContinue

$SerializePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Serialize"
if (-not (Test-Path $SerializePath)) { New-Item -Path $SerializePath -Force | Out-Null }
Set-ItemProperty -Path $SerializePath -Name "StartupDelayInMSec" -Value 0 -Type DWord -ErrorAction SilentlyContinue

$ContentDeliveryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\ContentDeliveryManager"
if (-not (Test-Path $ContentDeliveryPath)) { New-Item -Path $ContentDeliveryPath -Force | Out-Null }
Set-ItemProperty -Path $ContentDeliveryPath -Name "SoftLandingEnabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $ContentDeliveryPath -Name "SubscribedContent-338389Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $ContentDeliveryPath -Name "SubscribedContent-338388Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $ContentDeliveryPath -Name "SubscribedContent-353636Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue
Set-ItemProperty -Path $ContentDeliveryPath -Name "SubscribedContent-310093Enabled" -Value 0 -Type DWord -ErrorAction SilentlyContinue

$DesktopPanelPath = "HKCU:\Control Panel\Desktop"
Set-ItemProperty -Path $DesktopPanelPath -Name "MenuShowDelay" -Value "200" -ErrorAction SilentlyContinue

$AdvancedExplorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
if (-not (Test-Path $AdvancedExplorerPath)) { New-Item -Path $AdvancedExplorerPath -Force | Out-Null }
Set-ItemProperty -Path $AdvancedExplorerPath -Name "DisallowShaking" -Value 1 -Type DWord -ErrorAction SilentlyContinue

$PersonalizationPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Personalization"
if (-not (Test-Path $PersonalizationPath)) { New-Item -Path $PersonalizationPath -Force | Out-Null }
Set-ItemProperty -Path $PersonalizationPath -Name "NoLockScreen" -Value 1 -Type DWord

Write-Host "${BrandDark}-> Removing pre-installed UWP bloatware...${ResetColor}"
$BloatApps = @(
    "Microsoft.3DBuilder",
    "Microsoft.GetHelp",
    "Microsoft.Getstarted",
    "Microsoft.Messaging",
    "Microsoft.MicrosoftOfficeHub",
    "Microsoft.MicrosoftSolitaireCollection",
    "Microsoft.People",
    "Microsoft.SkypeApp",
    "Microsoft.WindowsFeedbackHub",
    "Microsoft.YourPhone",
    "Microsoft.ZuneMusic",
    "Microsoft.ZuneVideo",
    "Microsoft.BingNews",
    "Microsoft.BingSports",
    "Microsoft.BingWeather",
    "Microsoft.MixedReality.Portal",
    "Microsoft.XboxSpeechToTextOverlay",
    "Microsoft.OneConnect",
    "Microsoft.StickyNotes",
    "Microsoft.WindowsMaps",
    "Microsoft.Wallet",
    "Microsoft.BingSearch",
    "Microsoft.Paint3D",
    "Microsoft.Office.OneNote",
    "Microsoft.549981C3F5F10" # Cortana app
)
foreach ($App in $BloatApps) {
    Write-Host "${BrandDark}   Uninstalling $App...${ResetColor}"
    Get-AppxPackage -Name $App -AllUsers -ErrorAction SilentlyContinue | Remove-AppxPackage -ErrorAction SilentlyContinue
    Get-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue | Where-Object { $_.PackageName -like "*$App*" } | Remove-AppxProvisionedPackage -Online -ErrorAction SilentlyContinue
}

Write-Host "${BrandDark}-> Removing OneDrive...${ResetColor}"
Stop-Process -Name "OneDrive" -Force -ErrorAction SilentlyContinue
$System32OneDrive = "$env:SystemRoot\System32\OneDriveSetup.exe"
$SysWOW64OneDrive = "$env:SystemRoot\SysWOW64\OneDriveSetup.exe"
if (Test-Path $SysWOW64OneDrive) {
    Start-Process -FilePath $SysWOW64OneDrive -ArgumentList "/uninstall" -Wait -NoNewWindow
} elseif (Test-Path $System32OneDrive) {
    Start-Process -FilePath $System32OneDrive -ArgumentList "/uninstall" -Wait -NoNewWindow
}
Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "OneDrive" -ErrorAction SilentlyContinue
Remove-Item -Path "$env:UserProfile\OneDrive" -Force -Recurse -ErrorAction SilentlyContinue

Write-Host "${BrandDark}-> Applying PessimaIdeia Brand Colors (Full Black + Accent #b3078b)...${ResetColor}"
$ThemePersonalizePath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
if (-not (Test-Path $ThemePersonalizePath)) { New-Item -Path $ThemePersonalizePath -Force | Out-Null }
Set-ItemProperty -Path $ThemePersonalizePath -Name "AppsUseLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $ThemePersonalizePath -Name "SystemUsesLightTheme" -Value 0 -Type DWord
Set-ItemProperty -Path $ThemePersonalizePath -Name "ColorPrevalence" -Value 1 -Type DWord

$DWMPath = "HKCU:\Software\Microsoft\Windows\DWM"
if (-not (Test-Path $DWMPath)) { New-Item -Path $DWMPath -Force | Out-Null }
Set-ItemProperty -Path $DWMPath -Name "ColorPrevalence" -Value 1 -Type DWord
Set-ItemProperty -Path $DWMPath -Name "AccentColor" -Value 0xFF8B07B3 -Type DWord
Set-ItemProperty -Path $DWMPath -Name "ColorizationColor" -Value 0xFFB3078B -Type DWord

$AccentPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Accent"
if (-not (Test-Path $AccentPath)) { New-Item -Path $AccentPath -Force | Out-Null }
Set-ItemProperty -Path $AccentPath -Name "AccentColorMenu" -Value 0xFF8B07B3 -Type DWord
$AccentPaletteValue = [byte[]](0xfa,0x47,0xcd,0x00, 0xd9,0x1e,0xab,0x00, 0xb3,0x07,0x8b,0x00, 0xb3,0x07,0x8b,0x00, 0x8c,0x05,0x6c,0x00, 0x66,0x03,0x4f,0x00, 0x40,0x01,0x32,0x00, 0x1a,0x00,0x14,0x00)
Set-ItemProperty -Path $AccentPath -Name "AccentPalette" -Value $AccentPaletteValue -Type Binary

Write-Host "${BrandDark}-> Windows 10 Console debloating and branding completed.${ResetColor}"

# ==========================================
# MODULE 4: PLAYNITE INSTALLATION
# ==========================================
Write-Host "`n${BrandGreen}[4/7] Installing Playnite...${ResetColor}"
$PlayniteInstaller = Join-Path -Path $ScriptDir -ChildPath "PlayniteInstaller.exe"

if (-not (Test-Path $PlayniteInstaller)) {
    Write-Host "${BrandYellow}-> Downloading Playnite Installer...${ResetColor}"
    $ProgressPreference = 'SilentlyContinue'
    try {
        Download-File -Uri "https://playnite.link/download/PlayniteInstaller.exe" -Path $PlayniteInstaller
        Write-Host "${BrandDark}-> Playnite Installer downloaded successfully.${ResetColor}"
    } catch {
        Write-Host "${BrandRed}-> ERROR: Failed to download Playnite installer. $_${ResetColor}"
    }
} else {
    Write-Host "${BrandDark}-> PlayniteInstaller.exe already exists. Skipping download.${ResetColor}"
}

if (Test-Path $PlayniteInstaller) {
    Write-Host "${BrandDark}-> Running Playnite installer...${ResetColor}"
    Start-Process -FilePath $PlayniteInstaller -ArgumentList "/VERYSILENT", "/NORESTART" -Wait
    Write-Host "${BrandDark}-> Playnite installed successfully.${ResetColor}"
    Write-Host "${BrandDark}-> Cleaning up Playnite installer file...${ResetColor}"
    Remove-Item -Path $PlayniteInstaller -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "${BrandRed}-> ERROR: PlayniteInstaller.exe not found!${ResetColor}"
}

# ==========================================
# MODULE 5: GAME LAUNCHERS SELECTION
# ==========================================
Write-Host "`n${BrandGreen}[5/7] Configuring Game Launchers...${ResetColor}"

function Install-Launcher {
    param (
        [string]$Name,
        [string]$WingetId,
        [string]$DownloadUrl,
        [string]$SilentArgs,
        [bool]$IsMsi = $false
    )

    Write-Host "`n${BrandGreen}-> Installing $Name...${ResetColor}"
    
    $wingetPath = Get-Command winget -ErrorAction SilentlyContinue
    if ($null -ne $wingetPath) {
        Write-Host "${BrandDark}   Attempting to install via winget...${ResetColor}"
        $process = Start-Process winget -ArgumentList "install", "--id", $WingetId, "--silent", "--accept-source-agreements", "--accept-package-agreements" -NoNewWindow -PassThru -Wait
        if ($process.ExitCode -eq 0) {
            Write-Host "${BrandGreen}   $Name installed successfully via winget!${ResetColor}"
            return
        } else {
            Write-Host "${BrandYellow}   winget installation failed (ExitCode: $($process.ExitCode)). Falling back to direct download...${ResetColor}"
        }
    } else {
        Write-Host "${BrandDark}   winget not found. Using direct download...${ResetColor}"
    }

    $fileName = Split-Path $DownloadUrl -Leaf
    if ($fileName -notlike "*.*") {
        $fileName = "$Name-Installer" + (if ($IsMsi) { ".msi" } else { ".exe" })
    }
    $installerPath = Join-Path -Path $ScriptDir -ChildPath $fileName
    
    Write-Host "${BrandYellow}   Downloading $Name from $DownloadUrl...${ResetColor}"
    $ProgressPreference = 'SilentlyContinue'
    try {
        Download-File -Uri $DownloadUrl -Path $installerPath
        Write-Host "${BrandDark}   Download complete. Executing installer...${ResetColor}"
        
        if ($IsMsi) {
            $process = Start-Process msiexec.exe -ArgumentList "/i", "`"$installerPath`"", $SilentArgs -NoNewWindow -PassThru -Wait
        } else {
            $process = Start-Process -FilePath $installerPath -ArgumentList $SilentArgs -NoNewWindow -PassThru -Wait
        }
        
        Remove-Item -Path $installerPath -Force -ErrorAction SilentlyContinue
        
        Write-Host "${BrandGreen}   $Name installed successfully!${ResetColor}"
    } catch {
        Write-Host "${BrandRed}   ERROR: Failed to download or install $Name. $_${ResetColor}"
    }
}

$Launchers = @(
    [PSCustomObject]@{ Id = 1; Name = "Steam"; WingetId = "Valve.Steam"; Url = "https://media.steampowered.com/client/installer/SteamSetup.exe"; Args = "/S"; IsMsi = $false },
    [PSCustomObject]@{ Id = 2; Name = "GOG Galaxy"; WingetId = "GOG.Galaxy"; Url = "https://webinstallers.gog-statics.com/download/GOG_Galaxy_2.0.exe"; Args = "/SILENT"; IsMsi = $false },
    [PSCustomObject]@{ Id = 3; Name = "Epic Games Launcher"; WingetId = "EpicGames.EpicGamesLauncher"; Url = "https://launcher-public-service-prod06.ol.epicgames.com/launcher/api/installer/download/EpicGamesLauncherInstaller.msi"; Args = "/qn /norestart"; IsMsi = $true },
    [PSCustomObject]@{ Id = 4; Name = "EA App"; WingetId = "ElectronicArts.EADesktop"; Url = "https://download.origin.com/origin/live/EAappInstaller.exe"; Args = "/quiet"; IsMsi = $false },
    [PSCustomObject]@{ Id = 5; Name = "Ubisoft Connect"; WingetId = "Ubisoft.UbisoftConnect"; Url = "https://ubistatic3-a.akamaihd.net/orbit/launcher_installer/UbisoftConnectInstaller.exe"; Args = "/S"; IsMsi = $false },
    [PSCustomObject]@{ Id = 6; Name = "Battle.net"; WingetId = "Blizzard.BattleNet"; Url = "https://www.battle.net/download/getInstallerForGame?os=win&locale=enUS&version=LIVE&gameProgram=BATTLENET_APP"; Args = "--silent"; IsMsi = $false },
    [PSCustomObject]@{ Id = 7; Name = "Itch.io"; WingetId = "ItchAssociation.Itch"; Url = "https://itch.io/app/download?platform=windows"; Args = "--silent"; IsMsi = $false },
    [PSCustomObject]@{ Id = 8; Name = "RetroArch"; WingetId = "Libretro.RetroArch"; Url = "https://buildbot.libretro.com/stable/1.19.1/windows/x86_64/RetroArch-Win64-setup.exe"; Args = "/S"; IsMsi = $false }
)

Write-Host "`nSelect the game launchers you want to install." -ForegroundColor Cyan
Write-Host "Enter their numbers separated by commas (e.g., 1,3,5) or press Enter to skip:" -ForegroundColor Gray

foreach ($l in $Launchers) {
    Write-Host "$($l.Id)) $($l.Name)" -ForegroundColor White
}

$Selection = Read-Host "Selection"
if (-not [string]::IsNullOrWhiteSpace($Selection)) {
    $SelectedIds = $Selection.Split(',') | ForEach-Object { $_.Trim() } | Where-Object { $_ -match '^\d+$' } | ForEach-Object { [int]$_ }
    
    foreach ($id in $SelectedIds) {
        $launcher = $Launchers | Where-Object { $_.Id -eq $id }
        if ($null -ne $launcher) {
            Install-Launcher -Name $launcher.Name -WingetId $launcher.WingetId -DownloadUrl $launcher.Url -SilentArgs $launcher.Args -IsMsi $launcher.IsMsi
        } else {
            Write-Host "${BrandYellow}-> Option $id is invalid.${ResetColor}"
        }
    }
} else {
    Write-Host "${BrandDark}-> No launchers selected. Skipping.${ResetColor}"
}

# ==========================================
# MODULE 6: HACKBGRT SETUP
# ==========================================
Write-Host "`n${BrandGreen}[6/7] Launching HackBGRT Setup...${ResetColor}"
$HackBGRTDir = Join-Path -Path $ScriptDir -ChildPath "HackBGRT-2.6.0"
$HackBGRTSetup = Join-Path -Path $HackBGRTDir -ChildPath "setup.exe"

if (-not (Test-Path $HackBGRTSetup)) {
    Write-Host "${BrandYellow}-> Downloading HackBGRT...${ResetColor}"
    $HackBGRTZip = Join-Path -Path $ScriptDir -ChildPath "HackBGRT-2.6.0.zip"
    $ProgressPreference = 'SilentlyContinue'
    try {
        Download-File -Uri "https://github.com/Metabolix/HackBGRT/releases/download/v2.6.0/HackBGRT-2.6.0.zip" -Path $HackBGRTZip
        Write-Host "${BrandDark}-> Extracting HackBGRT...${ResetColor}"
        Expand-Archive -Path $HackBGRTZip -DestinationPath $ScriptDir -Force
        Remove-Item -Path $HackBGRTZip -Force
        Write-Host "${BrandDark}-> HackBGRT downloaded and extracted successfully.${ResetColor}"
    } catch {
        Write-Host "${BrandRed}-> ERROR: Failed to download or extract HackBGRT. $_${ResetColor}"
    }
} else {
    Write-Host "${BrandDark}-> HackBGRT already exists. Skipping download.${ResetColor}"
}

if (Test-Path $HackBGRTSetup) {
    Write-Host "${BrandYellow}-> Note: Secure Boot must be disabled in BIOS for HackBGRT to work.${ResetColor}"
    
    $LocalSplash = Join-Path -Path $ScriptDir -ChildPath "splash.bmp"
    $HackBGRTSplash = Join-Path -Path $HackBGRTDir -ChildPath "splash.bmp"
    if (Test-Path $LocalSplash) {
        Write-Host "${BrandDark}-> Copying custom splash logo to HackBGRT folder...${ResetColor}"
        Copy-Item -Path $LocalSplash -Destination $HackBGRTSplash -Force
    } else {
        Write-Host "${BrandYellow}-> WARNING: Custom splash.bmp not found in script directory.${ResetColor}"
    }

    Write-Host "${BrandDark}-> Installing HackBGRT in batch mode...${ResetColor}"
    Start-Process -FilePath $HackBGRTSetup -ArgumentList "batch", "install", "enable-bcdedit" -Wait
    Write-Host "${BrandDark}-> HackBGRT setup executed.${ResetColor}"
    
    Write-Host "${BrandDark}-> Cleaning up HackBGRT installation files...${ResetColor}"
    Remove-Item -Path $HackBGRTDir -Recurse -Force -ErrorAction SilentlyContinue
} else {
    Write-Host "${BrandRed}-> ERROR: HackBGRT setup.exe not found!${ResetColor}"
}

# ==========================================
# MODULE 7: AUTO-START PLAYNITE & SHELL MODE
# ==========================================
Write-Host "`n${BrandGreen}[7/7] Setting up Playnite Console Boot Mode & Controller Mouse Emulation...${ResetColor}"

$ConsoleDir = "C:\PessimoConsole"
if (-not (Test-Path $ConsoleDir)) {
    New-Item -Path $ConsoleDir -ItemType Directory -Force | Out-Null
}

if (Get-Command Add-MpPreference -ErrorAction SilentlyContinue) {
    Write-Host "${BrandDark}-> Adding Windows Defender exclusion for $ConsoleDir...${ResetColor}"
    Add-MpPreference -ExclusionPath $ConsoleDir -ErrorAction SilentlyContinue
}

$GopherExe = Join-Path -Path $ConsoleDir -ChildPath "Gopher360.exe"
if (-not (Test-Path $GopherExe)) {
    Write-Host "${BrandYellow}-> Downloading Gopher360 Controller-to-Mouse Mapper...${ResetColor}"
    $ProgressPreference = 'SilentlyContinue'
    try {
        Download-File -Uri "https://github.com/Tylemagne/Gopher360/releases/download/v0.989/Gopher.exe" -Path $GopherExe
        Write-Host "${BrandDark}-> Gopher360 downloaded successfully to $GopherExe.${ResetColor}"
    } catch {
        Write-Host "${BrandRed}-> WARNING: Failed to download Gopher360. $_${ResetColor}"
    }
} else {
    Write-Host "${BrandDark}-> Gopher360 already exists at $GopherExe.${ResetColor}"
}

$PlaynitePath = "$env:LocalAppData\Playnite\Playnite.FullscreenApp.exe"
$PlayniteMainPath = "$env:LocalAppData\Playnite\Playnite.DesktopApp.exe"
$StartupRegistryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
$WinlogonRegistryPath = "HKCU:\Software\Microsoft\Windows NT\CurrentVersion\Winlogon"

$SelectedPlayniteExe = ""
if (Test-Path $PlaynitePath) {
    $SelectedPlayniteExe = $PlaynitePath
} elseif (Test-Path $PlayniteMainPath) {
    $SelectedPlayniteExe = "$PlayniteMainPath"
}

if (-not [string]::IsNullOrEmpty($SelectedPlayniteExe)) {
    $BootChoice = ""
    while ($BootChoice -ne "1" -and $BootChoice -ne "2") {
        Write-Host "`nChoose how Playnite should launch on boot:" -ForegroundColor Cyan
        Write-Host "1) Custom Shell Mode (Recommended: Boots directly into Playnite, hides Windows Desktop entirely)"
        Write-Host "2) Standard Startup Mode (Safer: Boots Windows Desktop, then launches Playnite Fullscreen)"
        $BootChoice = (Read-Host "Choice (1 or 2)").Trim()
        if ($BootChoice -ne "1" -and $BootChoice -ne "2") {
            Write-Host "Invalid choice! Please enter 1 or 2." -ForegroundColor Red
        }
    }

    if ($BootChoice -eq "1") {
        
        $IniFileMappingPath = "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\IniFileMapping\system.ini\boot"
        if (Test-Path $IniFileMappingPath) {
            Set-ItemProperty -Path $IniFileMappingPath -Name "Shell" -Value "USR:Software\Microsoft\Windows NT\CurrentVersion\Winlogon" -Type String
            Write-Host "${BrandDark}-> Enabled user-level registry shell redirection mapping.${ResetColor}"
        }

        $PlayniteCmd = ""
        if ($SelectedPlayniteExe -eq $PlaynitePath) {
            $PlayniteCmd = "`"$PlaynitePath`""
        } else {
            $PlayniteCmd = "`"$PlayniteMainPath`" --startfullscreen"
        }

        $ShellLauncherPath = Join-Path -Path $ConsoleDir -ChildPath "ConsoleShell.bat"
        $ShellLauncherContent = @"
@echo off
:: Start Gopher360 in the background for controller mouse emulation
start "" "$GopherExe"

:: Start Playnite and wait for it to exit
start /wait "" $PlayniteCmd

:: Clean up Gopher360 when exiting Playnite
taskkill /f /im Gopher360.exe >nul 2>&1

:: If Playnite exits, load standard Windows Explorer shell so user is not stuck on a black screen
start explorer.exe
"@
        $ShellLauncherContent | Out-File -FilePath $ShellLauncherPath -Encoding ascii -Force
        Write-Host "${BrandDark}-> Created custom shell launcher at: $ShellLauncherPath${ResetColor}"

        Set-ItemProperty -Path $WinlogonRegistryPath -Name "Shell" -Value "`"$ShellLauncherPath`"" -Type String
        
        Remove-ItemProperty -Path $StartupRegistryPath -Name "PlayniteTVMode" -ErrorAction SilentlyContinue
        Remove-ItemProperty -Path $StartupRegistryPath -Name "Gopher360" -ErrorAction SilentlyContinue
        Write-Host "${BrandDark}-> Configured launcher batch script as custom shell. Booting will now load Playnite directly!${ResetColor}"
        
        $RestoreScriptPath = Join-Path -Path $ConsoleDir -ChildPath "RestoreExplorerShell.bat"
        $RestoreScriptContent = @"
@echo off
echo ==========================================
echo       RESTORE WINDOWS EXPLORER SHELL
echo ==========================================
reg delete "HKCU\Software\Microsoft\Windows NT\CurrentVersion\Winlogon" /v Shell /f
taskkill /f /im Playnite.FullscreenCmd.exe >nul 2>&1
taskkill /f /im Playnite.DesktopApp.exe >nul 2>&1
taskkill /f /im Gopher360.exe >nul 2>&1
start explorer.exe
echo.
echo Explorer.exe restored as the default shell.
echo Please restart your computer or log off.
pause
"@
        $RestoreScriptContent | Out-File -FilePath $RestoreScriptPath -Encoding ascii -Force
        
        Copy-Item -Path $RestoreScriptPath -Destination (Join-Path -Path $ScriptDir -ChildPath "RestoreExplorerShell.bat") -Force -ErrorAction SilentlyContinue

        Write-Host "${BrandYellow}-> Created restore script at: $RestoreScriptPath${ResetColor}"
        Write-Host "   Run this file to revert to the normal Windows desktop interface." -ForegroundColor Yellow
    } else {
        $FormattedPlayniteExe = $SelectedPlayniteExe
        if ($SelectedPlayniteExe -eq $PlayniteMainPath) {
            $FormattedPlayniteExe = "`"$PlayniteMainPath`" --startfullscreen"
        } else {
            $FormattedPlayniteExe = "`"$SelectedPlayniteExe`""
        }
        
        Set-ItemProperty -Path $StartupRegistryPath -Name "PlayniteTVMode" -Value $FormattedPlayniteExe
        
        Set-ItemProperty -Path $StartupRegistryPath -Name "Gopher360" -Value "`"$GopherExe`""
        
        Remove-ItemProperty -Path $WinlogonRegistryPath -Name "Shell" -ErrorAction SilentlyContinue
        Write-Host "${BrandDark}-> Playnite and Gopher360 configured to launch on standard Windows startup.${ResetColor}"
    }
} else {
    Write-Host "${BrandYellow}-> WARNING: Playnite executable path not resolved. Cannot configure boot mode.${ResetColor}"
}

Write-Host "`n${BrandAccent}==========================================${ResetColor}"
Write-Host "${BrandAccent}      PESSIMOCONSOLE SETUP COMPLETE!      ${ResetColor}"
Write-Host "${BrandMuted}       Your atrocious console awaits      ${ResetColor}"
Write-Host "${BrandAccent}==========================================${ResetColor}"

$RestartChoice = Read-Host "`nWould you like to restart your PC now? (Y/N)"
if ($RestartChoice -match '^[Yy]$') {
    Write-Host "${BrandYellow}Restarting computer...${ResetColor}"
    Restart-Computer -Force
} else {
    Write-Host "${BrandYellow}Please remember to manually restart your computer to apply all changes.${ResetColor}"
}