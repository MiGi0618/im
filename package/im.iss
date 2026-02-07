#ifndef MyAppName
#define MyAppName "IM Client"
#endif

#ifndef MyAppVersion
#define MyAppVersion "0.1"
#endif

#ifndef MyAppPublisher
#define MyAppPublisher "IMSystem"
#endif

#ifndef MyAppExeName
#define MyAppExeName "IMClientMVP.exe"
#endif

#ifndef MyAppDir
#define MyAppDir "F:\IMsystem\code\package\stage"
#endif

[Setup]
AppId={{A1B2C3D4-5678-4CDE-ABCD-1234567890AB}
AppName={#MyAppName}
AppVersion={#MyAppVersion}
AppPublisher={#MyAppPublisher}
DefaultDirName={autopf}\{#MyAppName}
DisableProgramGroupPage=yes
OutputDir=.
OutputBaseFilename=im
Compression=lzma
SolidCompression=yes

[Languages]
Name: "chinese"; MessagesFile: "compiler:\Languages\ChineseSimplified.isl"

[Tasks]
Name: "desktopicon"; Description: "Create a desktop icon"; GroupDescription: "Additional tasks"; Flags: unchecked

[Files]
Source: "{#MyAppDir}\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"
Name: "{autodesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#MyAppExeName}"; Description: "Run {#MyAppName}"; Flags: nowait postinstall skipifsilent
