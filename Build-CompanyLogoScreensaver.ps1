
# ============================================ 
# Build-CompanyLogoScreensaver.ps1
# --------------------------------------------
# Builds a custom Windows screensaver (.scr)
# from a logo image using PowerShell + C#
#
# Author: Juuso Hellman
# Usage: Run in PowerShell as Administrator
# ============================================
# 1) Muokkaa tarvittaessa $logoRelativePath
# 2) Aja PowerShellissa (admin)
# 3) Valitse CompanyLogoSaver screensaveriksi
# ============================================


$ErrorActionPreference = 'Stop'

# --- Settings ---
$projectName       = 'CompanyLogoSaver'
$outDir            = Join-Path $env:TEMP $projectName
$scrName           = 'CompanyLogoSaver.scr'
$exeName           = "$projectName.exe"
$logoRelativePath  = 'Screensaver\Testiscrn.png'   # %Public%\Pictures\<this>
$logoRelativePathEsc = $logoRelativePath -replace '\\','\\\\'  # escape for C#

# --- C# source: handles /s /c /p, shows logo centered on all monitors ---
$code = @"
using System;
using System.Drawing;
using System.IO;
using System.Windows.Forms;

namespace CompanyLogoSaver {
  static class Program {
    static bool _armed = false; // input must wait for a small delay
    [STAThread]
    static void Main(string[] args) {
      string mode = (args.Length > 0) ? args[0].ToLowerInvariant() : "/s";
      switch (mode) {
        case "/s":
          RunSaver();
          break;
        case "/c":
        case "/p":
        default:
          // no settings/preview -> exit
          return;
      }
    }

    static void RunSaver() {
      Application.EnableVisualStyles();
      Application.SetCompatibleTextRenderingDefault(false);

      string commonPictures = Environment.GetFolderPath(Environment.SpecialFolder.CommonPictures);
      string logoPath = Path.Combine(commonPictures, "$logoRelativePathEsc");

      // Create a fullscreen window for each monitor
      foreach (var screen in Screen.AllScreens) {
        var form = new FullscreenForm(logoPath, screen);
        form.Show();
      }

      // arming delay: ignore early input pulses for 500 ms
      var armTimer = new System.Windows.Forms.Timer { Interval = 500 };
      armTimer.Tick += (s, e) => { _armed = true; armTimer.Stop(); };
      armTimer.Start();

      Application.Run();
    }

    class FullscreenForm : Form {
      readonly string _logoPath;
      Image _logo;
      Point _lastMouse = Point.Empty;

      public FullscreenForm(string logoPath, Screen screen) {
        _logoPath = logoPath;
        this.FormBorderStyle = FormBorderStyle.None;
        this.StartPosition = FormStartPosition.Manual;
        this.Bounds = screen.Bounds;
        this.BackColor = Color.Black;
        this.DoubleBuffered = true;
        this.TopMost = true;
        this.Shown += (_, __) => { try { Cursor.Hide(); } catch { } };
	this.FormClosed += (_, __) => { try { Cursor.Show(); } catch { } };


        this.KeyDown    += (_, __) => TryExit();
        this.MouseClick += (_, __) => TryExit();
        this.MouseMove  += OnMouseMoveSafe;

        if (File.Exists(_logoPath)) {
          using (var temp = Image.FromFile(_logoPath)) {
            _logo = new Bitmap(temp);
          }
        }
      }

      void OnMouseMoveSafe(object sender, MouseEventArgs e) {
        if (!_armed) return;
        if (_lastMouse == Point.Empty) { _lastMouse = e.Location; return; }

        int dx = Math.Abs(e.X - _lastMouse.X);
        int dy = Math.Abs(e.Y - _lastMouse.Y);
        if (dx >= 2 || dy >= 2) TryExit(); // require real movement
      }

      void TryExit() {
        if (_armed) Application.Exit();
      }

      protected override void OnPaint(PaintEventArgs e) {
        base.OnPaint(e);
        var g = e.Graphics;
        g.Clear(Color.Black);

        if (_logo != null) {
          Size screen = this.ClientSize;
          float ratioImg = (float)_logo.Width / _logo.Height;
          float ratioScreen = (float)screen.Width / screen.Height;

          int drawW, drawH;
          if (ratioImg > ratioScreen) { drawW = screen.Width;  drawH = (int)(screen.Width / ratioImg); }
          else                        { drawH = screen.Height; drawW = (int)(screen.Height * ratioImg); }

          int x = (screen.Width - drawW) / 2;
          int y = (screen.Height - drawH) / 2;
          g.DrawImage(_logo, new Rectangle(x, y, drawW, drawH));
        }
      }

      protected override void Dispose(bool disposing) {
        if (disposing && _logo != null) _logo.Dispose();
        base.Dispose(disposing);
      }
    }
  }
}
"@

# --- Compile with .NET CodeDom ---
Write-Host "Compiling $projectName..."
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

Add-Type -AssemblyName System.Windows.Forms, System.Drawing | Out-Null
$provider = New-Object Microsoft.CSharp.CSharpCodeProvider
$params   = New-Object System.CodeDom.Compiler.CompilerParameters

$params.GenerateExecutable = $true
$params.OutputAssembly     = Join-Path $outDir $exeName
$params.CompilerOptions    = '/target:winexe'
$params.ReferencedAssemblies.AddRange(@('System.dll','System.Drawing.dll','System.Windows.Forms.dll'))

$results = $provider.CompileAssemblyFromSource($params, $code)
if ($results.Errors.Count -gt 0) {
  $results.Errors | ForEach-Object { Write-Host $_.ToString() -ForegroundColor Red }
  throw "Compilation failed."
}
Write-Host "Build OK: $($params.OutputAssembly)"

# --- Rename to .scr and copy to System32 ---
$scrPath = Join-Path $outDir $scrName
Copy-Item $params.OutputAssembly $scrPath -Force
Copy-Item $scrPath "$env:WINDIR\System32\$scrName" -Force
Write-Host "Copied: $env:WINDIR\System32\$scrName"

# --- Set active for current user (HKCU) ---
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'SCRNSAVE.EXE' -Value "$env:WINDIR\System32\$scrName"
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'ScreenSaveActive' -Value '1'
Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'ScreenSaveTimeOut' -Value '60'  # 60s test

Write-Host "Set active. Open: control desk.cpl,,@screensaver"
