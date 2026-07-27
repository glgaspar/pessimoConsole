[Setup]                                                                                                                                                              
AppName=PessimoConsole                                                                                                                                               
AppVersion=1.0                                                                                                                                                       
AppPublisher=PessimaIdeia Inc.                                                                                                                                          
DefaultDirName={tmp}\PessimoConsole                                                                                                                                  
DisableDirPage=yes                                                                                                                                                   
DisableProgramGroupPage=yes
Uninstallable=no
PrivilegesRequired=admin
OutputDir=.
OutputBaseFilename=PessimoConsoleSetup
SetupIconFile=pessimaideia.ico

[Files]
Source: "setup.ps1"; DestDir: "{app}"; Flags: ignoreversion
Source: "splash.bmp"; DestDir: "{app}"; Flags: ignoreversion
Source: "RUN_SETUP.bat"; DestDir: "{app}"; Flags: ignoreversion

[Run]
Filename: "{app}\RUN_SETUP.bat"; Description: "Running PessimoConsole Provisioning..."; Flags: waituntilterminated
