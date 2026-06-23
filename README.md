# Windows Company Screensaver

> PowerShell-based solution for creating and deploying a custom company logo screensaver in a Windows domain environment.

---

## 📌 Overview

This project provides a script that:

- Builds a custom `.scr` screensaver from a logo image
- Supports multiple monitors
- Displays the logo centered on screen
- Automatically registers the screensaver on the system

---

## 🛠️ Technologies Used

- PowerShell
- C# (compiled dynamically)
- Windows Forms
- Windows Registry

---

## 🖼️ How it works

1. The script generates a C# application  
2. The application displays a custom image fullscreen  
3. The app is compiled into `.exe`  
4. Renamed to `.scr` (Windows screensaver format)  
5. Deployed to `C:\Windows\System32`  
6. Activated via registry settings  

---

## 📂 Requirements

- Windows system  
- Administrator privileges (required for System32 copy)  

---

## ⚙️ Usage

1. Place your logo file in:  
   `C:\Users\Public\Pictures\Screensaver\`

2. Update the script variable if needed:  
   `$logoRelativePath = 'Screensaver\your-image.png'`

3. Run PowerShell as Administrator and execute:  
   `.\Build-CompanyLogoScreensaver.ps1`

4. Open screensaver settings and select CompanyLogoSaver:  
   `Win + R → control desk.cpl,,@screensaver`

---

## 🧠 Domain Deployment (Important)

This script only builds the screensaver.

To deploy across a domain:

1. Copy `.scr` and image files to a network share (e.g. NETLOGON)  
2. Use Group Policy to:
   - Copy files to client machines  
   - Configure screensaver settings  
   - Enforce automatic lock  

See detailed instructions in:  
`docs/deployment.md`

---

## 🚀 Features

- Multi-monitor support  
- Clean fullscreen rendering  
- Image scaling and centering  
- Safe input detection (prevents accidental exit)  
- Minimal system impact  

---

## ⚠️ Notes

- Requires admin rights for installation  
- Do not include sensitive company data in scripts  
- Designed for educational and real-world lab use  
