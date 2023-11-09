; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!
#define icon "x2.ico"
#define saxonjar "saxon-he-12.3.jar"
#define saxonzip "SaxonHE12-3J.zip"
#define ccwzip "Ccw64.zip"
#define ccwexe "ccw64.exe"
#define makezip "make.zip"
#define makeexe "make.exe"

[Setup]
;OutputBaseFilename=Xrunner-installer-with-Java
OutputBaseFilename=Xrunner2-installer-w-java
AppName=Xrunner2
AppVersion=2.0
DefaultDirName=C:\programs\xrunner2j
DisableDirPage=false
DefaultGroupName=Publishing
UninstallDisplayIcon={app}\setup\{#icon}
Compression=lzma2
SolidCompression=yes

[Files]
Source: "*.hta"; DestDir: "{app}"
Source: "*.cmd"; DestDir: "{app}"
Source: "setup\*.ico"; DestDir: "{app}\setup"
Source: "setup\*.css"; DestDir: "{app}\setup"
Source: "setup\*.vbs"; DestDir: "{app}\setup"
Source: "setup\*.js"; DestDir: "{app}\setup"
Source: "setup\*.txt"; DestDir: "{app}\setup"
Source: "*.xml"; DestDir: "{app}"
Source: "LICENSE.txt"; DestDir: "{app}"
Source: "scripts\*.xslt"; DestDir: "{app}\scripts"
Source: "scripts\*.cct"; DestDir: "{app}\scripts"
Source: "scripts\func.cmd"; DestDir: "{app}\scripts"
Source: "setup\*.html"; DestDir: "{app}\setup"
Source: "docs\*.png"; DestDir: "{app}\docs"
Source: "docs\*.html"; DestDir: "{app}\docs"

; tools
Source: "tools\make\*.*"; DestDir: "{app}\tools\make"    ; Flags: recursesubdirs
Source: "tools\cct\*.*"; DestDir: "{app}\tools\cct"     ; Flags: recursesubdirs
Source: "tools\SaxonHE12-3J\*.*"; DestDir: "{app}\tools\saxon"     ; Flags: recursesubdirs
Source: "tools\java\*.*"; DestDir: "{app}\tools\java"     ; Flags: recursesubdirs

[Icons]
Name: "{group}\Xrunner2j"; Filename: "{app}\xrunner.hta"; IconFilename: "{app}\setup\{#icon}"
Name: "{group}\Uninstallers\Xrunner2 Uninstall"; Filename: "{uninstallexe}" 

 [Run]
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\{#saxonzip} -d {app}\tools\saxon";  Check: FileDoesNotExist('{app}\tools\saxon\{#saxonjar}');

[Dirs]
Name: "{app}\_Xrunner_Projects\Demos"
Name: "{app}\_Xrunner_Projects\Modify-LIFT"
Name: "{app}\docs"
Name: "{app}\scripts"
Name: "{app}\tools"
Name: "{app}\tools\make"
Name: "{app}\tools\saxon"
Name: "{app}\tools\cct"
Name: "{app}\tools\java"

[INI]
;The following line is different to how it is tested on the computer
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "projecthome"; String: "{app}\_xrunner_projects"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "ccw32"; String: "{app}\tools\cct\{#ccwexe}"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "saxon"; String: "{app}\tools\saxon\{#saxonjar}"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "java"; String: "{app}\tools\java\bin\java.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "editor"; String: "C:\Windows\System32\notepad.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "make"; String: "{app}\tools\make\bin\make.exe"; Flags: createkeyifdoesntexist




[Code]
function FileDoesNotExist(file: string): Boolean;
begin
  if (FileExists(ExpandConstant(file))) then
    begin
      Result := False;
    end
  else
    begin
      Result := True;
    end;
end;


procedure DecodeVersion(verstr: String; var verint: array of Integer);
var
  i,p: Integer; s: string;
begin
  { initialize array }
  verint := [0,0,0,0];
  i := 0;
  while ((Length(verstr) > 0) and (i < 4)) do
  begin
    p := pos ('.', verstr);
    if p > 0 then
    begin
      if p = 1 then s:= '0' else s:= Copy (verstr, 1, p - 1);
      verint[i] := StrToInt(s);
      i := i + 1;
      verstr := Copy (verstr, p+1, Length(verstr));
    end
    else
    begin
      verint[i] := StrToInt (verstr);
      verstr := '';
    end;
  end;
end;


function CompareVersion (ver1, ver2: String) : Integer;
var
  verint1, verint2: array of Integer;
  i: integer;
begin
  SetArrayLength (verint1, 4);
  DecodeVersion (ver1, verint1);

  SetArrayLength (verint2, 4);
  DecodeVersion (ver2, verint2);

  Result := 0; i := 0;
  while ((Result = 0) and ( i < 4 )) do
  begin
    if verint1[i] > verint2[i] then
      Result := 1
    else
      if verint1[i] < verint2[i] then
        Result := -1
      else
        Result := 0;
    i := i + 1;
  end;
end;

function InstallJava() : Boolean;
var
  JVer: String;
  InstallJ: Boolean;
begin
  RegQueryStringValue(
    HKLM, 'SOFTWARE\JavaSoft\Java Runtime Environment', 'CurrentVersion', JVer);
  InstallJ := true;
  if Length( JVer ) > 0 then
  begin
    if CompareVersion(JVer, '1.8') >= 0 then
    begin
      InstallJ := false;
    end;
  end;
  Result := InstallJ;
end;