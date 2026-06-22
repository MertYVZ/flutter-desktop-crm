# Windows build and installer distribution

This project ships the Flutter Windows desktop app as an **Inno Setup** installer (`.exe`), with a **ZIP fallback** when Inno Setup is not installed.

> **Must build on Windows.** Unlike the macOS DMG workflow, the Windows installer cannot be produced on macOS or Linux. Use a Windows machine (or CI runner) with Flutter and Visual Studio installed.

## App metadata

| Setting | Value |
|--------|--------|
| Display name | Ok Teknik Metal CRM |
| Executable | `okteknikmetalcrm.exe` |
| Release folder | `build/windows/x64/runner/Release/` |
| Version source | `pubspec.yaml` (`version:` field) |
| Bundle ID (macOS) | `com.okteknikmetal.okteknikmetalcrm` |

## Prerequisites

1. **Windows 10/11 (64-bit)**
2. **[Flutter SDK](https://docs.flutter.dev/get-started/install/windows)** with Windows desktop enabled
3. **Visual Studio 2022** with workload **Desktop development with C++**
   - Include MSVC, Windows 10/11 SDK, and CMake
4. **[Inno Setup 6](https://jrsoftware.org/isdl.php)** (recommended)
   - Default install path: `C:\Program Files (x86)\Inno Setup 6\`
   - Adds `ISCC.exe` used by the build script

Verify Flutter can build for Windows:

```powershell
flutter doctor
flutter config --enable-windows-desktop
```

## Build an installer

From the repository root in **PowerShell**:

```powershell
.\scripts\build_windows_installer.ps1
```

This will:

1. Run `flutter build windows --release`
2. Compile `scripts/windows_installer.iss` with Inno Setup
3. Write `dist/Ok_Teknik_Metal_CRM_<version>_windows_setup.exe`

The installer:

- Installs to **Program Files** (`C:\Program Files\Ok Teknik Metal CRM\`)
- Creates a **Start Menu** shortcut
- Offers an optional **desktop** shortcut (unchecked by default)
- Registers an **uninstaller** in Windows Settings → Apps

### Options

```powershell
# Re-package an existing Release build (skip Flutter compile)
.\scripts\build_windows_installer.ps1 -SkipBuild

# ZIP only (no Inno Setup required)
.\scripts\build_windows_installer.ps1 -ZipOnly
```

### Git Bash / MSYS2 (alternative)

If you prefer Bash on Windows:

```bash
chmod +x scripts/build_windows_installer.sh   # first time only
./scripts/build_windows_installer.sh
```

On **macOS or Linux**, only validation is supported:

```bash
./scripts/build_windows_installer.sh --validate
```

## ZIP fallback

If `ISCC.exe` is not found, the build script automatically creates:

```
dist/Ok_Teknik_Metal_CRM_<version>_windows.zip
```

Extract the ZIP anywhere and run `okteknikmetalcrm.exe`. This is suitable for internal testing but does not add Start Menu entries or an uninstaller.

## Code signing (production)

For wide distribution outside your organization, sign the installer and/or executable to reduce SmartScreen warnings.

1. Obtain a **code signing certificate** (Extended Validation recommended for fewer SmartScreen prompts).
2. Sign the release executable before packaging:

   ```powershell
   signtool sign /fd SHA256 /a `
     "build\windows\x64\runner\Release\okteknikmetalcrm.exe"
   ```

3. Build the installer with `-SkipBuild`, then sign the setup `.exe`:

   ```powershell
   .\scripts\build_windows_installer.ps1 -SkipBuild
   signtool sign /fd SHA256 /a `
     "dist\Ok_Teknik_Metal_CRM_1.0.0_windows_setup.exe"
   ```

4. Optionally timestamp signatures (`/tr http://timestamp.digicert.com /td SHA256`).

Signing requires the **Windows SDK** (`signtool.exe`) and a valid certificate on the build machine.

## Troubleshooting

| Issue | What to try |
|-------|-------------|
| `Release executable not found` | Run `flutter build windows --release` or omit `-SkipBuild` |
| `flutter` not on PATH | Add Flutter `bin` to your user/system PATH |
| MSVC / linker errors | Open Visual Studio Installer → modify → enable **Desktop development with C++** |
| Inno Setup not found | Install [Inno Setup 6](https://jrsoftware.org/isdl.php) or use `-ZipOnly` |
| SmartScreen blocks the app | Code-sign the installer; users can also click **More info → Run anyway** once |
| Building from macOS | Not supported — use `--validate` only, or build on Windows / CI |

## Output layout

```
dist/
  Ok_Teknik_Metal_CRM_1.0.0_windows_setup.exe
  Ok_Teknik_Metal_CRM_1.0.0_windows.zip    # fallback or -ZipOnly
```

The `dist/` directory is gitignored; distribute the installer (or ZIP) directly to users.

## CI suggestion

Run on a `windows-latest` GitHub Actions (or Azure DevOps) agent:

1. Install Flutter and Inno Setup (`choco install innosetup`).
2. `flutter build windows --release`
3. `.\scripts\build_windows_installer.ps1 -SkipBuild`
4. Upload `dist/*.exe` as a release artifact.
