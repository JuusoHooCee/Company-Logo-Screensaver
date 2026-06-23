# Domain Deployment – Company Screensaver

## 📌 Overview

This guide explains how to deploy the custom screensaver across a Windows domain using Group Policy.

---

## 🎯 Goal

- Distribute screensaver files automatically
- Enforce screensaver usage
- Lock workstation after inactivity

---

## 🧱 Step 1 – Prepare files

After running the script, you will have:

- CompanyLogoSaver.scr
- Logo image (.png)

---

## 🌐 Step 2 – Store files in network location

Place the files in a shared folder, for example:

`\\domain.local\NETLOGON\Screensaver\`

Files:
- CompanyLogoSaver.scr
- your-image.png

---

## 🖥️ Step 3 – Copy files to client computers

Create a Group Policy Object:

Path:  
Computer Configuration → Preferences → Windows Settings → Files

Configure file copy:

- Source: Network share  
- Destination:  
  `C:\Windows\System32\CompanyLogoSaver.scr`

Repeat for the image file.

---

## 👤 Step 4 – Configure screensaver settings (User GPO)

Path:  
User Configuration → Policies → Administrative Templates → Control Panel → Personalization

Enable:

- Enable screen saver → Enabled  
- Screen saver timeout → e.g. 300 seconds  
- Force specific screen saver → Enabled  

Set value:  
`C:\Windows\System32\CompanyLogoSaver.scr`

---

## 🔒 Step 5 – Enforce automatic lock

Enable:
- Password protect the screen saver

---

## 🔋 Step 6 – Power settings

Ensure display settings do not conflict:

- Screensaver timeout < display timeout  
- Display should not turn off before screensaver activates  

---

## ✅ Result

- Screensaver starts after inactivity  
- Company logo is displayed  
- Workstation is locked automatically  

---

## 🧠 Notes

- Requires administrative rights  
- Test with a small group before production rollout  
- Ensure correct GPO targeting  
