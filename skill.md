# Edge Profile Automation System
This document describes the complete feature set of the Edge Profile Automation system and provides a master prompt that can be used to instruct an AI to regenerate this entire project from scratch.

## 🌟 Core Features

1. **Auto-Elevation (UAC Bypass)**: Uses a VBScript `ShellExecute` wrapper to self-elevate to Administrator. This method is specifically designed to work on Windows 10 Lite editions where PowerShell `Start-Process -Verb RunAs` fails.
2. **Robust User Detection**: Uses a PowerShell WMI query (`Get-WmiObject -Class Win32_ComputerSystem`) to accurately identify the active desktop user, even when the script is running elevated under a different admin account.
3. **Hardware & Network Data Extraction**: Automatically fetches:
   - Local IP Address (`ipconfig`)
   - Public IP Address (`api.ipify.org`)
   - AnyDesk ID (Reads from `%ProgramData%\AnyDesk\system.conf` or AppData)
   - MAC / Physical Address (`getmac /fo csv`)
4. **Daily Completion Tracking & Smart Skipping**: 
   - Logs daily completions to `C:\user_completion_log.txt`.
   - If a user runs the script but has already finished their profiles for the day (`!date!`), it prompts a 5-minute timeout using the `choice` command.
   - Timeout options: Wait 5 mins to auto-switch, Press `S` to switch instantly, or Press `C` to cancel.
5. **Sequential Edge Profile Execution**: Loops through 20 Edge Profiles. Saves progress in `C:\<Username>_complete.txt` so it can resume exactly where it left off if the PC restarts or crashes.
6. **Smart Process Monitoring**: Runs a 200-second timer for each Edge profile. It uses `tasklist` to monitor if `msedge.exe` is closed manually by the user before the timer ends. If closed early, it immediately advances to the next profile.
7. **Real-Time Terminal Dashboard**: Displays a live-updating UI containing the User, Network Info, MAC Address, Current Profile, Completed Profiles, Remaining Profiles, and the live countdown timer.
8. **Unattended User Switching (AutoAdminLogon)**: When a user finishes, the script calculates the next sequential user (A to O). It dynamically updates the Windows Registry `Winlogon` keys (`AutoAdminLogon`, `DefaultUserName`, `DefaultPassword`) and automatically restarts (`shutdown /r`) the PC to log into the next account without human intervention.
9. **Telegram Notifications**: When the final configured user (`LAST_USER`) completes their run, the script uses `curl` to send a Telegram message with all network/device details and uploads the `C:\user_completion_log.txt` document directly to the Telegram chat, then shuts down the PC (`shutdown /s`).


---

## 🤖 Master Prompt for Regeneration

If you ever lose these files, you can paste the following prompt to an AI to have it completely rewrite the system:

```text
Create an automated Windows Batch script system for running Microsoft Edge profiles sequentially across multiple Windows user accounts (radhamay_ratanA to radhamay_ratanO). 

Requirements:
1. Administrator Elevation: The script must self-elevate using a VBScript 'ShellExecute' method (do not use PowerShell Start-Process as this runs on Win 10 Lite).
2. User Detection: Detect the current active desktop user using: powershell -Command "(Get-WmiObject -Class Win32_ComputerSystem).UserName.Split('\')[1]"
3. Telemetry: Extract Local IP, Public IP (via api.ipify.org), AnyDesk ID (from system.conf), and MAC Address (via getmac).
4. State Management: The script must loop through "Default" and "Profile 1" to "Profile 19". It must track completed profiles for the current user in a file like "C:\<User>_complete.txt" to resume if interrupted.
5. Edge Execution: For each profile, start msedge.exe --profile-directory="<ProfileName>". Run a 200-second timer. Use tasklist to check if msedge.exe is closed manually. If closed manually, skip the remaining time. Otherwise, taskkill it at 200 seconds.
6. Dashboard: While the timer runs, clear the screen and display a live dashboard showing the User, IP, AnyDesk ID, MAC, Current Profile, Completed Profiles list, Remaining Profiles list, and the countdown timer.
7. User Switching: When all profiles for the current user are done, append a log entry to "C:\user_completion_log.txt" with the date. Then calculate the next user in the sequence (A to O). Modify the Windows Registry (HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon) to set AutoAdminLogon=1, ForceAutoLogon=1, DefaultUserName=<NextUser>, and DefaultPassword=<Password>. Finally, issue a 'shutdown /r /t 5' to restart and log into the next user.
8. Smart Skipping: At the very beginning of the script, check if the current user is already in "C:\user_completion_log.txt" for today's date. If they are, use the 'choice' command to wait 300 seconds. Allow 'S' to skip the wait and switch immediately, and 'C' to cancel the script. If no input is received, automatically proceed to switch to the next user.
9. Final User Telegram Alert: If the current user is the LAST user (radhamay_ratanO), do not restart. Instead, use curl to send a POST request to the Telegram Bot API with a summary message containing the telemetry data, and upload "C:\user_completion_log.txt" using sendDocument. Then run 'shutdown /s /t 0' to turn off the PC.
```
