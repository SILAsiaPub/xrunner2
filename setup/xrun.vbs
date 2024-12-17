' VB Script Document
Option Explicit
'         <!--define variables-->
Dim coFSO, objShell
Set objShell = CreateObject("Wscript.Shell")
Set coFSO = CreateObject("Scripting.FileSystemObject")
' Project files
Dim projIni, projPath, projectTxt, projectInfo, projectxslt 
' Setup files
Dim dquote, shell, cmdline, strUserProfile, setupvarxslt, title, xrundata, tskgrp 
Dim xrunini, zero, level, boxlist, tasklen
' Programs 
Dim texteditor, program, xmleditor, xrunxslt, npp 
Dim WshShell, strCurDir, WScript 
Dim maintab, subgroup, docstab, doctab, subgrp, subarray, grpindex, grouplabel, sublabel
' Unused: xrundata, info1, info2, info3, info4, info5, strPath, labelIni, bConsoleSw, 
Set WshShell = CreateObject("WScript.Shell")
strCurDir    = WshShell.CurrentDirectory
tskgrp =  Array("a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z")
boxlist = Array("Checkbox1","Checkbox2","Checkbox3","Checkbox4","Checkbox5")
maintab = Array("project","subrunner1","subrunner2","projectinfo","docs","expert")
doctab = Array("Xrunner_info","Xrunner_func","Xrun_func")
sublabel = "sub"
subgrp = Array("s1","s2","s3","s4","s5","s6","s7","s8","s9","s10","s11","s12","s13","s14","s15","s16","s17","s18","s19","s20")
grouplabel = Array("g1","g2","g3","g4","g5","g6","g7","g8","g9","g10","g11","g12","g13","g14","g15","g16","g17","g18","g19","s20")

zero = 0
zero = CInt(zero)
' xrundata = "setup\"
xrunini = "setup\xrun.ini"
projPath =  ReadIni(xrunini,"setup","projecthome")
setupvarxslt =  "scripts\projectvariables-v2.xslt"
xrunxslt =  ReadIni(xrunini,"setup","xrunnerpath") & "\scripts\xrun.xslt"
texteditor =  ReadIni(xrunini,"tools","editor")
npp =  ReadIni(xrunini,"tools","npp")
xmleditor =  ReadIni(xrunini,"tools","xmleditor")
projectInfo =  projPath & "\project-info.txt" 

projIni = "blank.txt"
level = 0
dquote = chr(34)
strUserProfile = objShell.ExpandEnvironmentStrings( "%userprofile%" )


Function ReadIni( myFilePath, mySection, myKey )
    ' This function returns a value read from an INI file
    ' Arguments:
    ' myFilePath  [string]  the (path and) file name of the INI file
    ' mySection   [string]  the section in the INI file to be searched
    ' myKey       [string]  the key whose value is to be returned
    ' Returns:
    ' the [string] value for the specified key in the specified section
    ' CAVEAT:     Will return a space if key exists but value is blank
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre and Rob van der Woude
    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8
    Dim intEqualPos
    Dim objFSO, objIniFile
    Dim strFilePath, strKey, strLeftString, strLine, strSection
    Set objFSO = CreateObject( "Scripting.FileSystemObject" )
    ReadIni     = ""
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )
    If objFSO.FileExists( strFilePath ) Then
        Set objIniFile = objFSO.OpenTextFile( strFilePath, ForReading, False )
        Do While objIniFile.AtEndOfStream = False
            strLine = Trim( objIniFile.ReadLine )
            ' Check if section is found in the current line
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                strLine = Trim( objIniFile.ReadLine )
                ' Parse lines until the next section is reached
                Do While Left( strLine, 1 ) <> "["
                    ' Find position of equal sign in the line
                    intEqualPos = InStr( 1, strLine, "=", 1 )
                    If intEqualPos > 0 Then
                        strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                        ' Check if item is found in the current line
                        If LCase( strLeftString ) = LCase( strKey ) Then
                            ReadIni = Trim( Mid( strLine, intEqualPos + 1 ) )
                            ' In case the item exists but value is blank
                            If ReadIni = "" Then
                                 ReadIni = " "
                            End If
                            ' Abort loop when item is found
                            Exit Do
                        End If
                    End If
                    ' Abort if the end of the INI file is reached
                    If objIniFile.AtEndOfStream Then Exit Do
                    ' Continue with next line
                    strLine = Trim( objIniFile.ReadLine )
                Loop
            Exit Do
            End If
        Loop
        objIniFile.Close
    Else
        Msgbox strFilePath & " doesn't exists. Exiting..."
    End If
End Function

Sub WriteIni( myFilePath, mySection, myKey, myValue )
    ' This subroutine writes a value to an INI file
    ' Written by Keith Lacelle
    ' Modified by Denis St-Pierre, Johan Pol and Rob van der Woude
    Const ForReading   = 1
    Const ForWriting   = 2
    Const ForAppending = 8
    Dim blnInSection, blnKeyExists, blnSectionExists, blnWritten
    Dim intEqualPos
    Dim objFSO, objNewIni, objOrgIni, wshShell
    Dim strFilePath, strFolderPath, strKey, strLeftString
    Dim strLine, strSection, strTempDir, strTempFile, strValue
    strFilePath = Trim( myFilePath )
    strSection  = Trim( mySection )
    strKey      = Trim( myKey )
    strValue    = Trim( myValue )
    Set objFSO   = CreateObject( "Scripting.FileSystemObject" )
    Set wshShell = CreateObject( "WScript.Shell" )
    strTempDir  = wshShell.ExpandEnvironmentStrings( "%TEMP%" )
    strTempFile = objFSO.BuildPath( strTempDir, objFSO.GetTempName )
    Set objOrgIni = objFSO.OpenTextFile( strFilePath, ForReading, True )
    Set objNewIni = objFSO.CreateTextFile( strTempFile, False, False )
    blnInSection     = False
    blnSectionExists = False
    ' Check if the specified key already exists
    blnKeyExists     = ( ReadIni( strFilePath, strSection, strKey ) <> "" )
    blnWritten       = False
    ' Check if path to INI file exists, quit if not
    strFolderPath = Mid( strFilePath, 1, InStrRev( strFilePath, "\" ) )
    If Not objFSO.FolderExists ( strFolderPath ) Then
        WScript.Echo "Error: WriteIni failed, folder path (" _
                   & strFolderPath & ") to ini file " _
                   & strFilePath & " not found!"
        Set objOrgIni = Nothing
        Set objNewIni = Nothing
        Set objFSO    = Nothing
        WScript.Quit 1
    End If
    While objOrgIni.AtEndOfStream = False
        strLine = Trim( objOrgIni.ReadLine )
        If blnWritten = False Then
            If LCase( strLine ) = "[" & LCase( strSection ) & "]" Then
                blnSectionExists = True
                blnInSection = True
            ElseIf InStr( strLine, "[" ) = 1 Then
                blnInSection = False
            End If
        End If
        If blnInSection Then
            If blnKeyExists Then
                intEqualPos = InStr( 1, strLine, "=", vbTextCompare )
                If intEqualPos > 0 Then
                    strLeftString = Trim( Left( strLine, intEqualPos - 1 ) )
                    If LCase( strLeftString ) = LCase( strKey ) Then
                        ' Only write the key if the value isn't empty
                        ' Modification by Johan Pol
                        If strValue <> "<DELETE_THIS_VALUE>" Then
                            objNewIni.WriteLine strKey & "=" & strValue
                        End If
                        blnWritten   = True
                        blnInSection = False
                    End If
                End If
                If Not blnWritten Then
                    objNewIni.WriteLine strLine
                End If
            Else
                objNewIni.WriteLine strLine
                    ' Only write the key if the value isn't empty
                    ' Modification by Johan Pol
                    If strValue <> "<DELETE_THIS_VALUE>" Then
                        objNewIni.WriteLine strKey & "=" & strValue
                    End If
                blnWritten   = True
                blnInSection = False
            End If
        Else
            objNewIni.WriteLine strLine
        End If
    Wend
    If blnSectionExists = False Then ' section doesn't exist
        objNewIni.WriteLine
        objNewIni.WriteLine "[" & strSection & "]"
            ' Only write the key if the value isn't empty
            ' Modification by Johan Pol
            If strValue <> "<DELETE_THIS_VALUE>" Then
                objNewIni.WriteLine strKey & "=" & strValue
            End If
    End If
    objOrgIni.Close
    objNewIni.Close
    ' Delete old INI file
    objFSO.DeleteFile strFilePath, True
    ' Rename new INI file
    objFSO.MoveFile strTempFile, strFilePath
    Set objOrgIni = Nothing
    Set objNewIni = Nothing
    Set objFSO    = Nothing
    Set wshShell  = Nothing
End Sub

Function SelectFolder( myStartFolder )
' This function opens a "Select Folder" dialog and will
' return the fully qualified path of the selected folder
' Argument:
'     myStartFolder    [string]    the root folder where you can start browsing;
'                                  if an empty string is used, browsing starts
'                                  on the local computer
' Returns:
' A string containing the fully qualified path of the selected folder
' Written by Rob van der Woude
' http://www.robvanderwoude.com
    ' Standard housekeeping
    Dim objFolder, objItem, objShell, usea, useb
    ' Custom error handling
    On Error Resume Next
    'buttonHide()
    SelectFolder = vbNull
    ' Create a dialog object
    Set objShell  = CreateObject( "Shell.Application" )
    Set objFolder = objShell.BrowseForFolder( 0, "Select Folder", 0, myStartFolder )
    ' Return the path of the selected folder
    If IsObject( objfolder ) Then SelectFolder = objFolder.Self.Path
    ShowSelectedFolder.Value = SelectFolder
    projectTxt = SelectFolder & "\project.txt"
    If coFSO.FileExists(projectTxt) Then
      projectInfo = SelectFolder & "\project-info.txt"
      buttonShow(projectTxt)
      subButtons(projectTxt)
      Document.getElementById("title").InnerText = ReadIni(projectTxt,"variables","title")
      call editArea1(projectTxt)
      call editArea2(projectInfo)
    End If

    'document.getElementById("projecttxt").src = projectTxt
    'document.getElementById("infoarea").src = projectInfo
    'document.getElementById("projinfoframe").src = projectInfo
    'copy()
    ' Standard housekeeping
    Set objFolder = Nothing
    Set objshell  = Nothing
    On Error Goto 0
End Function

Function RunCmd( bat, param )
    'writeProjIni projIni,"variables",styleout
    cmdline = """%comspec%"" /c " & "cmd.exe /c " & bat & " " & param
    objShell.run(cmdline)
End Function

Function RunCmd2( bat, param1, param2 )
    'writeProjIni projIni,"variables",styleout
    cmdline = """%comspec%"" /c " & "cmd.exe /c " & bat & " " & param1 & " " & param2
    objShell.run(cmdline)
End Function

Function buttonShow(file)
  dim x, group, grplen, buttonlen
  For x = 0 To Ubound(tskgrp)
    group = tskgrp(x)
    grplen = len(ReadIni(file,group,"label")) + len(ReadIni(file,group,"g")) + len(ReadIni(file,group,"l"))
    buttonlen = len(ReadIni(file,group,"button")) + len(ReadIni(file,group,"b"))
    tasklen = len(ReadIni(file,group,"t")) + len(ReadIni(file,group,"ut"))
    If grplen > zero Then
        document.getElementById("grouplabel" & group).style.display = "block"
        If len(ReadIni(file,group,"g")) > zero Then
          document.getElementById("grouplabel" & group).InnerText = ReadIni(file,group,"g")
        Else
          document.getElementById("grouplabel" & group).InnerText = ReadIni(file,group,"label")
        End If
    Else
        document.getElementById("grouplabel" & group).style.display = "none"
    End If
    If tasklen > zero Then
      document.getElementById("button" & group).style.display = "block"
      If len(ReadIni(file,group,"b")) > zero Then
          document.getElementById("button" & group).InnerText = ReadIni(file,group,"b") & " - " & group
      Else 
        If len(ReadIni(file,group,"button")) > zero Then
            document.getElementById("button" & group).InnerText = ReadIni(file,group,"button")
        Else
            document.getElementById("button" & group).InnerText = "Task group " & group
        End If
      End If  
    Else
        document.getElementById("button" & group).style.display = "none"
    End If
  Next
End Function

Function subButtons(file)
  dim section, textlen, prefix, text, key, curid, keynumb, part, subarray, testa, x, curtext, namelen, group
  section = sublabel
  prefix = "s"
  call subbuttonHide()
  For each key in subgrp
    text = ReadIni(file,section,key)
    textlen = len(text)
    keynumb = Mid(key, 2)
    if textlen > 0 then
      subarray = split(text)
      if Ubound(subarray) < 10 Then
        For x = 0 to Ubound(subarray)
          curtext = Cstr(subarray(x))
          namelen = len(curtext)
          curid = prefix & keynumb & "-" & x
          If textlen > 0 then
            document.getElementById(curid).style.display = "block"
            document.getElementById(curid).InnerText = curtext
          else
            document.getElementById(curid).style.display = "none"
          End If
        Next
      else
        curid = prefix & keynumb & "-" & "1"
        document.getElementById(curid).style.display = "block"
        document.getElementById(curid).InnerText = "Too many items in list. Maximum 10."
      end if
    End If
  Next
  prefix = "subgroup"
  For each group in grouplabel
    text = ReadIni(file,section,group)
    textlen = len(text)
    keynumb = Mid(group, 2)
    curid = prefix & keynumb
    If textlen > 0 then
      document.getElementById(curid).style.display = "block"
      document.getElementById(curid).InnerText = text
'    else
'      document.getElementById(curid).style.display = "none"
    End If
  Next
End Function

Function buttonHide()
  dim x, group
  For x = 0 To Ubound(tskgrp)
    group = tskgrp(x)
    document.getElementById("grouplabel" & group).style.display = "none"
    document.getElementById("button" & group).style.display = "none"
  Next
End Function

Function subbuttonHide()
  dim x, y
  For x = 1 To 20
    document.getElementById("subgroup" & x).style.display = "none"
    For y = 0 To 9
      document.getElementById("s" & x & "-" & y).style.display = "none"
    Next
  Next
End Function


Sub xrun(group)
    Dim x, pauseatend, unittest
    pauseatend = ""
    For x = 0 To 5
      if document.getElementById("infoid" & x).checked Then
        level = document.getElementById("infoid" & x).value
      End If
    Next
    If document.getElementById("pauseatend").checked  Then
       pauseatend = "pause"
    End If   
    'If document.getElementById("unittest").checked  Then
    '   unittest = "unittest"
    'End If
   call RunScript("xrunner",projectTxt,group,level,pauseatend,"")
End Sub

Sub subrunx(key,numb)
    Dim x, pauseatend, group, sections, sectionarray, cursect
    dim infopar(5)
    group = sublabel
    pauseatend = ""
    sections = ReadIni(projectTxt,group,key)
    sectionarray = split(sections)
    cursect = sectionarray(numb)
    For x = 0 To 5
      if document.getElementById("infoid" & x).checked Then
        level = document.getElementById("infoid" & x).value
      End If
    Next
    If document.getElementById("pauseatend").checked  Then
       pauseatend = "pause"
    End If   
    'If document.getElementById("unittest").checked  Then
    '   unittest = "unittest"
    'End If
    infopar(0) = chr(34) & "xrunner" & chr(34)
    infopar(1) = " " & projectTxt
    infopar(2) = " " & cursect
    infopar(3) = " " & level
    infopar(4) = " " & pauseatend
    cmdline = infopar(0) & infopar(1) & infopar(2) & infopar(3) & infopar(4)
    objShell.run(cmdline)
End Sub

Sub copy()
  Dim x, y
  x = projectInfo
  y = "setup\project-info.txt"
  call RunScript("copy","/Y",x,y,"")
End Sub

Sub RunScript(script,var1,var2,var3,var4,var5)
    'writeProjIni projIni,"variables",styleout
    dim infopar(5), x
    infopar(0) = chr(34) & script & chr(34)
    infopar(1) = " " & var1
    infopar(2) = " " & var2
    infopar(3) = " " & var3
    infopar(4) = " " & var4
    infopar(5) = " " & var5
    cmdline = infopar(0) & infopar(1) & infopar(2) & infopar(3) & infopar(4) & infopar(5)
    objShell.run(cmdline)
    document.getElementById("lastcmd").InnerText = "Last commandline: " & cmdline
    'CmdPrompt(cmdline)
End Sub

Function editFileExternal(file)
	' Does not support filepaths supplied with spaces unless they are supplied with double quotes around the string.
    cmdline = texteditor & " " & file
    objShell.run(cmdline)
End Function

Sub editFileWithProgram(file,program)
    cmdline = dquote & program & dquote & " " & file
    objShell.run(cmdline)
End Sub

Function OpenTab(tabgrp,tabid)
    Dim tab, x, Elem, Elemon, Elemtab , Elemtc, ifrm, tabname, tabactive
    tab = tabgrp
    tabactive = tabid & "tab"
    For x = 0 To Ubound(tab)
      tabname = tab(x) & "tab"
      document.getElementById(tab(x)).style.display = "none"
      document.getElementById(tabname).style.background = "#f1f1f1"
    Next
    document.getElementById(tabid).style.display = "block"
    document.getElementById(tabactive).style.background = "#ccc"
End Function

'Const csFSpec = "E:\trials\SoTrials\answers\8841045\hta\29505115.txt"
Function reloadText(file)
  If coFSO.FileExists(file) Then
     'Document.getElementsByTagName(namearea)(0).value = coFSO.OpenTextFile(file).ReadAll()
     document.all.DataArea.value = coFSO.OpenTextFile(file).ReadAll()
  End If
End Function

Function reloadProject(file)
  call reloadText(file)
  call buttonShow(file)
  call subButtons(file)
  Document.getElementById("title").InnerText = ReadIni(projectTxt,"variables","title")
End Function

Sub editArea1(file)
  If coFSO.FileExists(file) Then
     'Document.getElementsByTagName(namearea)(0).value = coFSO.OpenTextFile(file).ReadAll()
     document.all.DataArea.value = coFSO.OpenTextFile(file).ReadAll()
  Else
     coFSO.CreateTextFile(file)
     document.all.DataArea.value = "[]"
  End If
End Sub

Sub editArea2(file)
  If coFSO.FileExists(file) Then
     'Document.getElementsByTagName(namearea)(0).value = coFSO.OpenTextFile(file).ReadAll()
     document.all.InfoArea.value = coFSO.OpenTextFile(file).ReadAll()
  Else
     coFSO.CreateTextFile(file)
     document.all.InfoArea.value = "# Notes"
  End If
End Sub

Sub SaveFile(data,filename)
  coFSO.CreateTextFile(filename).Write document.all.data.value
End Sub

Sub toggleIni(ini,section,key)
  If Document.GetElementById(key).Checked = False Then
    call WriteIni( ini, section,key , "" )
  Else
    call WriteIni( ini, section,key , "on" )
  End If
End Sub


Sub  SetRadioFromIni(ini, section,key,idname,last)
  dim x, infolevel, radio
  infolevel = ReadIni(xrunini,section,key)
  For x = 0 To Cint(last)
    If infolevel = x then
      radio = idname & x
      Document.GetElementById(idname & x ).checked = True
      Document.GetElementById(idname & x ).SetFocus
      Document.GetElementById(idname & x ).click
      Document.GetElementById(idname & x ).ClickButton
      call javascript:checkRadio(radio)
      'Sys.Keys "[Down][Down]"
    Else
      Document.GetElementById(idname & x ).removeAttribute("checked")
    End If
  Next
End Sub



Sub  SetCboxByIdNumbSetFromIni(ini, section,key,idname,last)
  dim x
  For x = 0 To Cint(last)
    call SetCboxByIdFromIni(ini, section,key & x,idname)
  Next
End Sub

Sub SetCboxByIdFromIni(ini, section,key,idname)
    If ReadIni(ini,section,key) = " " then
      Document.GetElementById(idname ).Checked = False
    Else
      Document.GetElementById(idname ).Checked = True
    End If
End Sub

Sub presets()
  'call SetRadioFromIni(xrunini, "feedback","infolevel","infoid",5)
  'call SetCboxByIdFromIni(xrunini, "feedback","pauseatend","pauseatend")
  'call SetCboxByIdFromIni(xrunini, "setup","unittest","unittest")
End Sub

Sub arraypos(thisarray,text)
  Dim x, curvalue
  For x = 0 To Ubound(thisarray)
    curvalue = thisarray(x)
    if curvalue = text then
        grpindex = x
    end if
  Next
End Sub

'' the following not used.
'Function groupLabel(file)
'  dim x, group, prefix, textlen, curid, label, text
'  group = "subbutton"
'  prefix = "sub"
'  prefix = "sublabel"
'  For x = 0 To Ubound(lblgrp)
'    label = lblgrp(x)
'    curid = prefix & label
'    text = ReadIni(file,group,curid)
'    textlen = len(text)
'    If textlen > zero Then
'        document.getElementById(curid).style.display = "block"
'        document.getElementById(curid).InnerText = ltext
'    End If
'  Next
'End Function

'Function buttonSubs(file)
'  dim x, group, textlen, prefix, text, key, curid
'  group = "subbutton"
'  prefix = "sub"
'  For x = 0 To 199
'    key = CStr(x)
'    curid = prefix & key
'    text = ReadIni(file,group,key)
'    textlen = len(text)
'    If textlen > zero Then
'        document.getElementById(curid).style.display = "block"
'        document.getElementById(curid).InnerText = text
'    Else
'        document.getElementById(curid).style.display = "none"
'    End If
'  Next
''  call groupLabel(file)
'End Function


