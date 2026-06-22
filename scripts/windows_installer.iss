; Inno Setup script for Ok Teknik Metal CRM (Flutter Windows release).
;
; Compile from the repository root (or via scripts/build_windows_installer.ps1):
;   "C:\Program Files (x86)\Inno Setup 6\ISCC.exe" ^
;     /DMyAppVersion=1.0.0 ^
;     /DSourceDir=build\windows\x64\runner\Release ^
;     /DOutputDir=dist ^
;     /DOutputBaseFilename=Ok_Teknik_Metal_CRM_1.0.0_windows_setup ^
;     scripts\windows_installer.iss
;
; Required defines (passed by the build script):
;   MyAppVersion, SourceDir, OutputDir, OutputBaseFilename

#ifndef MyAppVersion
  #define MyAppVersion "1.0.0"
#endif
#ifndef SourceDir
  #define SourceDir "..\build\windows\x64\runner\Release"
#endif
#ifndef OutputDir
  #define OutputDir "..\dist"
#endif
#ifndef OutputBaseFilename
  #define OutputBaseFilename "Ok_Teknik_Metal_CRM_windows_setup"
#endif

#define MyAppName "Ok Teknik Metal CRM"
#define MyAppPublisher "Ok Teknik Metal"
#define MyAppExeName "okteknikmetalcrm.exe"
#define MyAppId "{{A3B8C2D1-4E5F-6789-0ABC-DEF123456789}"

#if FileExists(AddBackslash(SourceDir) + MyAppExeName) = 0
  #error "Release build not found. Run flutter build windows --release first."
#endif

[Setup]
AppId={#MyAppId}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DefaultGroupName={#MyAppName}
DisableProgramGroupPage=yes
LicenseFile=
OutputDir={#OutputDir}
OutputBaseFilename={#OutputBaseFilename}
Compression=lzma2/ultra64
SolidCompression=yes
WizardStyle=modern
PrivilegesRequired=admin
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
UninstallDisplayIcon={app}\{#MyAppExeName}
#if FileExists("..\windows\runner\resources\app_icon.ico")
SetupIconFile=..\windows\runner\resources\app_icon.ico
#endif

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"
Name: "turkish"; MessagesFile: "compiler:Languages\Turkish.isl"

[Tasks]
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "{#SourceDir}\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, '&', '&&')}}"; Flags: nowait postinstall skipifsilent

[UninstallDelete]
Type: filesandordirs; Name: "{app}"
