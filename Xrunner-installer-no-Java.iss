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
OutputBaseFilename=Xrunner2-installer
AppName=Xrunner2
AppVersion=2.0
DefaultDirName=C:\programs\xrunner2
DisableDirPage=true
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
;Source: "*.md"; DestDir: "{app}"
;Source: "*.txt"; DestDir: "{app}" ; Flags: onlyifdoesntexist;
Source: "scripts\*.xslt"; DestDir: "{app}\scripts"
Source: "scripts\*.cct"; DestDir: "{app}\scripts"
Source: "scripts\func.cmd"; DestDir: "{app}\scripts"
Source: "setup\*.html"; DestDir: "{app}\setup"
;Source: "setup\*.ini"; DestDir: "{app}\setup"
Source: "docs\*.png"; DestDir: "{app}\docs"
Source: "docs\*.html"; DestDir: "{app}\docs"
;Source: "_Xrunner_Projects\Unit-tests\*.*"; DestDir: "{app}\_Xrunner_Projects\Unit-tests"  ;
;Source: "_Xrunner_Projects\Complete_Concordance_Builder\My-Concordance\*.*"; DestDir: "{app}\_Xrunner_Projects\Complete_Concordance_Builder\My-Concordance" ; Flags: recursesubdirs
; Modify-LIFT
;Source: "_Xrunner2_Projects\Modify-LIFT\*.*"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT"  ;
;Source: "_Xrunner2_Projects\Modify-LIFT\scripts\*.*"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT\scripts"  ;
;Source: "_Xrunner2_Projects\Modify-LIFT\source\*.txt"; DestDir: "{app}\_Xrunner_Projects\Modify-LIFT\source"  ;
; HymnBook contents menu
;Source: "_Xrunner2_Projects\Hymn_Menu\*.*"; DestDir: "{app}\_Xrunner_Projects\Hymn_Menu"  ;
;Source: "_Xrunner2_Projects\Hymn_Menu\scripts\*.*"; DestDir: "{app}\_Xrunner_Projects\Hymn_Menu\scripts"  ;

; tools
;Source: "..\..\..\installer-tools\jre-8u141-windows-x64.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: IsWin64 AND InstallJava(); Flags: deleteafterinstall
;Source: "..\..\..\installer-tools\jre-8u66-windows-i586.exe"; DestDir: "{tmp}"; DestName: "JREInstall.exe"; Check: (NOT IsWin64) AND InstallJava(); Flags: deleteafterinstall
;Source: "..\..\..\installer-tools\UNZIP.EXE"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{tmp}\UNZIP.EXE');
;Source: "..\..\..\installer-tools\{#saxonzip}"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\saxon\{#saxonjar}');
;Source: "..\..\..\installer-tools\{#ccwzip}"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\cct\{#ccwexe}');
;Source: "..\..\..\installer-tools\amazon-corretto-8.222.10.3-windows-x64-jre.zip"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('{app}\tools\java\java.exe');
;Source: "..\..\..\{#makeinstall}" DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('C:\Program Files (x86)\GnuWin32\bin\make.exe');
;Source: "D:\All-SIL-Publishing\installer-tools\{#makezip}"; DestDir: "{tmp}"; Flags: deleteafterinstall ;  Check: FileDoesNotExist('C:\{app}\tools\bin\make.exe');
Source: "tools\bin\*.*"; DestDir: "{app}\tools\bin"    ; Flags: recursesubdirs
Source: "tools\lib\*.*"; DestDir: "{app}\tools\lib"     ; Flags: recursesubdirs
Source: "tools\cct\*.*"; DestDir: "{app}\tools\cct"     ; Flags: recursesubdirs
Source: "tools\SaxonHE12-3J\*.*"; DestDir: "{app}\tools\saxon"     ; Flags: recursesubdirs

[Icons]
Name: "{group}\Xrunner2"; Filename: "{app}\xrunner.hta"; IconFilename: "{app}\setup\{#icon}"
;Name: "{group}\Xrun func documentation"; Filename: "{app}\docs\xrun-docs.md.html"; IconFilename: "{app}\setup\{#icon}"
Name: "{group}\Uninstallers\Xrunner2 Uninstall"; Filename: "{uninstallexe}" 

 [Run]
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\{#saxonzip} -d {app}\tools\saxon";  Check: FileDoesNotExist('{app}\tools\saxon\{#saxonjar}');
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\{#ccwzip} -d '{app}\tools\cct'";  Check: FileDoesNotExist('{app}\tools\cct\{#ccwexe}');
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\{#makezip} -d '{app}\tools'";  Check: FileDoesNotExist('{app}\tools\{#makeexe}');
;Filename: "{tmp}\UNZIP.EXE"; Parameters: "{tmp}\amazon-corretto-8.222.10.3-windows-x64-jre.zip -d '{app}\tools\java'";  Check: FileDoesNotExist('{app}\tools\java\java.exe');
;Filename: "{tmp}\JREInstall.exe"; Parameters: "/s"; Flags: nowait postinstall runhidden runascurrentuser; Check: InstallJava() ;
;Filename: "{tmp}\{#makeinstall}"; Parameters: "/s"; Flags: nowait postinstall runhidden runascurrentuser; Check: FileDoesNotExist('C:\Program Files (x86)\GnuWin32\bin\make.exe') ;


[Dirs]
Name: "{app}\_Xrunner_Projects\Demos"
Name: "{app}\_Xrunner_Projects\Modify-LIFT"
Name: "{app}\docs"
Name: "{app}\scripts"
Name: "{app}\tools"
Name: "{app}\tools\bin"
Name: "{app}\tools\lib"
Name: "{app}\tools\saxon"
Name: "{app}\tools\cct"

[INI]
;The following line is different to how it is tested on the computer
Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "projecthome"; String: "{app}\_xrunner_projects"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "taskgroup_list"; String: "a b c d e f g h i j k l m n o p q r s t u v w x y z"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "button-or-label_list"; String: "button b label"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "nonunique_list"; String: "t xt ut button b label com"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "unittestlabel_list"; String: "ut utt"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "tasklabel_list"; String: "t"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "batchsection_list"; String: "variables var project proj"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "xsltsection_list"; String: "variables xvar"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "includesection_list"; String: "include inc"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "guisection_list"; String: "gui"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "reservedsection_list"; String: "variables var project proj include inc gui"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "includelabel_list"; String: "i"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "true_list"; String: "true yes on 1"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "commentlabel"; String: "com"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "needsaxon"; String: "true"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "detectjava"; String: ""; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "setup"; Key: "setup-type"; String: "java"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "java"; String: "java"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "ccw32"; String: "{app}\tools\cct\{#ccwexe}"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "saxon"; String: "{app}\tools\saxon\{#saxonjar}"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "java"; String: "java"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "zip"; String: "C:\Program Files\7-Zip\7z.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "editor"; String: "C:\Windows\System32\notepad.exe"; Flags: createkeyifdoesntexist
Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "make"; String: "{app}\tools\bin\make.exe"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "foxe"; String: "C:\Program Files (x86)\firstobject\foxe.exe"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "prince"; String: "C:\Program Files (x86)\Prince\engine\bin\prince.exe"; Flags: createkeyifdoesntexist
;Filename: "{app}\setup\xrun.ini"; Section: "tools"; Key: "rdwrtp8"; String: "C:\Program Files (x86)\Paratext 8\rdwrtp8.exe"; Flags: createkeyifdoesntexist




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