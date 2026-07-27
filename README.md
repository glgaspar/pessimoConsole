# 🎮 PessimoConsole by PessimaIdeia Inc.

> [!WARNING]
> Deploying code associated with a company literally named **PessimaIdeia** ("Atrocious Idea") is, objectively, a terrible decision. Read the [LICENSE](file:///home/gustavo/p/pessimoConsole/LICENSE) file before proceeding.

`PessimoConsole` is an automated provisioning system designed by **PessimaIdeia Inc.** to turn your Windows 10 PC into a completely dedicated gaming console experience running **Playnite Fullscreen Mode**.

---

## 🛠️ Features Included

1. **High Performance Power Optimization**: Configures the PC to a high-performance power plan and completely disables sleep, hibernate, and screen timeouts (on both AC and Battery modes). It also disables USB Selective Suspend and PCIe Link State Power Management, and configures Bluetooth adapters/USB hubs to disable Windows power saving.
2. **Windows Auto-Logon Setup**: Configures registry keys to automatically log in to your Windows user account on boot without prompting for passwords.
3. **PessimaIdeia Signature Debloater**: Strips background services (Disables `SysMain`/Superfetch to prevent 100% disk usage, `Print Spooler`, `MapsBroker`, biometric sensors, and fax services), disables telemetry-related diagnostics and scheduled tasks, turns off Windows Game DVR background recording, disables consumer features (automatic downloads of sponsored apps), and uninstalls the Windows Lock Screen, Cortana, web search in the Start Menu, UWP bloatware (Mixed Reality, Maps, Wallet, OneNote, etc.), and OneDrive.
4. **Gaming & Usability Optimizations**: Disables Sticky Keys, Filter Keys, and Toggle Keys popups (preventing keyboard dialog interruptions during intense gameplay), removes Windows startup delay to boot apps immediately, increases menu hover responsiveness, and disables Aero Shake to prevent background windows from randomly minimizing.
5. **Ensures Controller Support**: Automatically enables and starts the Windows Bluetooth Support Service (`bthserv`) and per-user Bluetooth services so that wireless game controllers work seamlessly out of the box.
6. **PessimaIdeia Brand Theme Settings**: Configures the system to a clean dark theme and applies PessimaIdeia's signature custom accent color palette (Full Black background with `#b3078b` accent branding).
7. **Automated Playnite Setup**: Dynamically downloads and silently installs the latest version of the Playnite game aggregator.
8. **Interactive Launcher Selector**: Displays a menu of supported launchers to install via Windows Package Manager (`winget`) with a fallback direct download downloader:
   * Steam
   * GOG Galaxy
   * Epic Games Launcher
   * EA App
   * Ubisoft Connect
   * Battle.net
   * Itch.io
   * RetroArch
9. **Custom HackBGRT UEFI Boot Logo**: Integrates the custom [splash.bmp](file:///home/gustavo/p/pessimoConsole/splash.bmp) boot logo to replace the default Windows boot logo automatically using HackBGRT's batch installer mode (requires disabling Secure Boot).
10. **Playnite Custom Shell Integration**: Bypasses the default Windows desktop shell (`explorer.exe`) entirely to boot straight into Playnite's 10-foot console-like user interface. Exiting Playnite automatically exits the mouse mapper and launches `explorer.exe` to bring back the desktop.
11. **Controller Mouse Emulation**: Downloads and integrates **Gopher360** to allow controlling the Windows mouse cursor and clicks using a standard game controller to handle launcher updates, installations, or dialog popups.

---

## 🚀 How to Run

There are two ways to deploy `PessimoConsole` on your target Windows machine:

### Method 1: Using the Compiled Installer (Recommended)
1. Copy [PessimoConsoleSetup.exe](file:///home/gustavo/p/pessimoConsole/PessimoConsoleSetup.exe) to your target Windows machine.
2. Right-click the installer and select **"Run as Administrator"**.
3. The installer will extract all files and launch the automated command-line interface. Follow the prompts.

> [!NOTE]
> The setup terminal window runs in the foreground so you can interactively enter your auto-logon credentials, select which game launchers to install, and configure your console settings.

### Method 2: Running from Source Scripts
1. Clone or copy this directory to your target Windows machine.
2. Ensure you have the custom [splash.bmp](file:///home/gustavo/p/pessimoConsole/splash.bmp) logo and [setup.ps1](file:///home/gustavo/p/pessimoConsole/setup.ps1) script in the same directory.
3. Right-click [RUN_SETUP.bat](file:///home/gustavo/p/pessimoConsole/RUN_SETUP.bat) and select **"Run as Administrator"**.
4. Follow the simple console prompts to configure your gaming console.

---

## 🎮 Connecting Bluetooth Controllers

To pair Bluetooth controllers (like Xbox or PlayStation controllers) to your console:

### Method 1: Using Task Manager (Standard Way in Custom Shell Mode)
Since the standard Windows desktop is hidden in Custom Shell Mode, you can open the pairing dialog directly:
1. Press `Ctrl + Shift + Esc` on your keyboard to open the **Windows Task Manager**.
2. Click **File** > **Run new task**.
3. Type `DevicePairingWizard.exe` (to launch the lightweight pairing wizard) or `ms-settings:bluetooth` (to launch modern Bluetooth settings) and press Enter.
4. Put your controller in pairing mode and connect it.

### Method 2: Adding pairing shortcut directly into Playnite (100% Console-Like)
To add controllers using only your game controller directly inside Playnite:
1. Switch Playnite to **Desktop Mode** (via the menu or pressing `Ctrl + D` on your keyboard).
2. Go to the main menu at the top-left and select **Add Game** > **Manually...**.
3. In the **General** tab, set the name to `Add Bluetooth Controller`.
4. In the **Actions** tab, click **Add Action**:
   * **Type**: Select `Executable`.
   * **Path**: Type `C:\Windows\System32\DevicePairingWizard.exe`.
5. Save the entry, switch back to **Fullscreen Mode** (`F11`), and select this new tool to pair controllers easily using your active controller.

## 🖱️ Controller Mouse Emulation (Gopher360)

`PessimoConsole` automatically installs and configures **Gopher360** to let you navigate standard Windows desktop dialogs, store launchers (like Epic, EA, GOG, or Steam), and installation wizards using your game controller.

### Controls:
* **Left Analog Stick**: Moves the mouse cursor.
* **A Button**: Left Mouse Click.
* **X Button**: Right Mouse Click.
* **B Button**: Press Enter.
* **D-Pad**: Keyboard Arrow Keys.
* **Right Analog Stick**: Mouse Scroll Wheel (Up/Down).
* **Start + Back (Pressed Simultaneously)**: Toggles Gopher360 mouse emulation on or off (useful to temporarily disable/enable mapping when launching or exiting games).

---

## ⚠️ Recovery (How to get Windows Desktop back)

If you configure **Custom Shell Mode**, Windows will boot directly into Playnite, hiding the desktop, taskbar, and start menu.

To restore the standard Windows desktop interface:
1. Press `Ctrl + Shift + Esc` on your keyboard to open the **Windows Task Manager**.
2. Select **File** > **Run new task**.
3. Type `C:\PessimoConsole\RestoreExplorerShell.bat` and press Enter (or click **Browse** and select it).
4. Restart your PC.

---

## 🎖️ Credits & Acknowledgments

This project relies on the following incredible open-source and third-party tools:

* **[Playnite](https://playnite.link/)** (by Josef Nemec) - The open-source video game library manager that powers the fullscreen 10-foot console user interface.
* **[HackBGRT](https://github.com/Metabolix/HackBGRT)** (by Metabolix) - The UEFI boot logo changer used to apply our custom boot splash logo.
* **[Inno Setup](https://jrsoftware.org/isinfo.php)** (by JR Software) - The free installer compiler for Windows used to build the [PessimoConsoleSetup.exe](file:///home/gustavo/p/pessimoConsole/PessimoConsoleSetup.exe) package.
* **[RetroArch](https://www.retroarch.com/)** (by Libretro) - The open-source emulator frontend.

---

## ⚖️ License

Distributed under the **PessimaIdeia "Atrocious Idea" Public License v1.0**. Read [LICENSE](file:///home/gustavo/p/pessimoConsole/LICENSE) for more details.
