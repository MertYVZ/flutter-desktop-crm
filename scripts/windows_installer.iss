; Inno Setup script for Ok Teknik Metal CRM (Flutter Windows release).
;
; Compile via scripts/build_windows_installer.ps1.
;
; Optional defines/environment variables used by the build script:
;   MyAppName, MyAppPublisher, MyAppExeName, MyAppVersion,
;   SourceDir, OutputDir, OutputBaseFilename

#ifndef MyAppName
  #if GetEnv("OKTM_APP_NAME") != ""
    #define MyAppName GetEnv("OKTM_APP_NAME")
  #else
    #define MyAppName "Ok Teknik Metal CRM"
  #endif
#endif
#ifndef MyAppPublisher
  #if GetEnv("OKTM_APP_PUBLISHER") != ""
    #define MyAppPublisher GetEnv("OKTM_APP_PUBLISHER")
  #else
    #define MyAppPublisher "Ok Teknik Metal"
  #endif
#endif
#ifndef MyAppExeName
  #if GetEnv("OKTM_APP_EXE_NAME") != ""
    #define MyAppExeName GetEnv("OKTM_APP_EXE_NAME")
  #else
    #define MyAppExeName "okteknikmetalcrm.exe"
  #endif
#endif
#ifndef MyAppVersion
  #if GetEnv("OKTM_APP_VERSION") != ""
    #define MyAppVersion GetEnv("OKTM_APP_VERSION")
  #else
    #define MyAppVersion "1.0.0"
  #endif
#endif
#ifndef SourceDir
  #if GetEnv("OKTM_SOURCE_DIR") != ""
    #define SourceDir GetEnv("OKTM_SOURCE_DIR")
  #else
    #define SourceDir "..\build\windows\x64\runner\Release"
  #endif
#endif
#ifndef OutputDir
  #if GetEnv("OKTM_OUTPUT_DIR") != ""
    #define OutputDir GetEnv("OKTM_OUTPUT_DIR")
  #else
    #define OutputDir "..\dist"
  #endif
#endif
#ifndef OutputBaseFilename
  #if GetEnv("OKTM_OUTPUT_BASE_FILENAME") != ""
    #define OutputBaseFilename GetEnv("OKTM_OUTPUT_BASE_FILENAME")
  #else
    #define OutputBaseFilename "Ok_Teknik_Metal_CRM_windows_setup"
  #endif
#endif

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
