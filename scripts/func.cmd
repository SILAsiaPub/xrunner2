:ampmhour
:: Description: Converts AM/PM time to 24hour format. 
:: Usage: call :ampmhour ampm hours
:: Purpose: modify variable
:: Functions called: funcbegin funcend
:: Variable created: fhh
:: Created: 2016-05-04 
:: Used by: getfiledatetime 
  @call :funcbegin %0 "'%~1' '%~2' %~3"
  set thh=%~1
  set ampm=%~2
  set zerostart=
  if "%ampm%" == "AM" (
    if "%thh:~1,1%" == "" set single=true
    set nfhh=%thh%
    if defined single set nfhh=0%thh%
    if "%thh%" == "12" set nfhh=00
  )
  if "%ampm%" == "PM" (
    if %thh:~0,1%. == 0. set zerostart=true
    if defined zerostart (
      set /A nfhh=%thh:~1,1%+12
    ) else (
      set /A nfhh=%thh%+12
    )
    if "%thh%" == "12" set nfhh=12
  ) 
  set fhh=%nfhh%
  @if defined info3 echo %green%Info: fhh = %fhh%%reset%
  @call :funcend %0
goto :eof

:appendfile
:: Description: Appends one file to the end of another file.
:: Usage: call :appendfile filetoadd filetoappendto
:: Purpose: append file
:: Functions called: funcbegin funcend 
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if not exist "%~2" copy nul "%~2"
  if not exist "%~1" call :funcend %0 "Warning: File to append does not exist. File: %~1" & pause & goto :eof
  if exist "%~1" type "%~1" >> "%~2"
  @call :funcend %0
goto :eof

:appendtofile
:: Description: Appends text to the end of a file.
:: Usage: call :appendtofile text-to-append filetoappendto first
:: Functions called: funcbegin funcend
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set text=%~1
  set text=%text:'="%
  set outfile=%~2
  set first=%~3
  if defined first (
   echo %text%> "%outfile%"
  ) else (
  echo %text%>> "%outfile%"
  )
  set first=
  @call :funcend %0
goto :eof

:autoit
:: Description: Pass a script and variables to autoit.
:: Usage: call :autoit script.au3 infile outfile parm1 etc
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount %count%
  set script=%~1
  if not defined script call :fatal %0 "Autoit script not supplied!" & goto :eof
  if not exist "%scripts%\%script%" call :scriptfind "%script%" %0
  @if defined info3 if not exist "%scripts%\%script%" call :fatal %0 "Script %script% not found" & goto :eof
  @if defined info3 if exist "%scripts%\%script%" echo %green%Info: script %script% exists%reset%
  set parm1=%~2
  if not exist "%autoit%" call :fatal %0 "missing autoit3.exe executable file" & goto :eof
  set parm2=%~3
  if defined fatal goto :eof
  set curcommand="%autoit%" "%script%" "%parm1%" "%parm2%"
  @if defined info2 echo call %cyan%%curcommand% %reset%
  pushd "%scripts%"
  call %curcommand%
  popd
  @call :funcend %0
goto :eof

:calc
:: Description: Calculate an number and return in a variable.
:: Usage: call :calc varname numbcalcstring
:: Functions called: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2'"
  set cal=%~2
  if "%cal%" neq "%cal:.=%" call :fatal %0 "The numbers cannot be decimals" & goto :eof
  if defined info3 if "%cal%" neq "%cal:/=%" echo %green%Info: Results of division are only whole numbers not decimals.%reset%
  set /A numb=%~2
  echo %green%calculated number = %numb%%reset%
  set %~1=%numb%
  @call :funcend %0
goto :eof

:cct
:: Description: Privides interface to ccw.
:: Usage: call :cct script.cct ["infile.txt" ["outfile.txt" [append]]]
:: Functions called: funcbegin funcendtest inccount infile outfile fatal scriptfind checkdir
:: External apps: ccw32.exe 
:: External apps url: https://software.sil.org/cc/
:: Required variable: ccw
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' %~5"
  call :inccount
  set script=%~1
  set infile=%~2
  set append=%~4
  if defined infile if "%infile%" neq "%infile:,=%" set commainput=true
  if not defined infile set infile=%ouptfile%
  if defined commainput if defined info2 echo %green%Info: Comma separated input files supplied. Existent not checked.%reset%
  if not defined commainput call :infile "%infile%" %0
  if defined append set append=append
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%scriptout%.xml" %append%
  if not defined script call :fatal %0 "CCT script not supplied!" & goto :eof
  if not exist "%scripts%\%script%" call :scriptfind "%script%" %0
  if not exist "%scripts%\%script%" call :fatal %0 "Script not found!" & goto :eof
  if not exist "%ccw%" call :fatal %0 "Missing ccw.exe file" & goto :eof
  call :checkdir "%outfile%"
  set cctparam=-q -n
  if defined append (
    set cctparam=-a
	@if defined info3 echo %green%Info: Output is being appended to output file.%reset%
  )
  set curcommand="%ccw%" -u -b %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  @if defined info2 echo %cyan%%curcommand%%reset%
  pushd "%scripts%"
  call %curcommand%
  popd
  @call :funcendtest %0
goto :eof

:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
:: Functions called: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set checkpath=%~1
  if not defined checkpath call :funcend %0 "missing required directory parameter for :checkdir" & goto :eof
  set ext=%~x1
  if defined ext set checkpath=%~dp1
  if defined ext set checkpath=%checkpath:~0,-1%
  if exist "%checkpath%" (
    @if defined info3 echo %green%Info: found path %checkpath%%reset%
  ) else (
    @if defined info3 echo %green%Info: creating path %checkpath%%reset%
    @if defined info4 echo mkdir "%checkpath%"
    mkdir "%checkpath%"
  )
  @call :funcend %0
goto :eof

:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run  command in"   "output file to test for"]
:: Functions called: inccount, checkdir, funcend or any function
:: External program: May use any external program
:: Note: Single quotes get converted to double quotes before the command is used.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  setlocal DISABLEDELAYEDEXPANSION
  set curcommand=%~1
  set commandpath=%~2
  set outfile=%~3
  if defined outfile call :checkdir "%outfile%"
  set basepath=%cd%
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
  if exist "%outfile%" del "%outfile%"
  if not defined curcommand (
    echo missing curcommand 
    call :funcend %0
    goto :eof
    )
  if defined commandpath call :checkdir "%commandpath%"
  if defined commandpath pushd "%commandpath%"
  @if defined info3 echo %green%Info: current path: %cd%%reset%
  @if defined info2 echo %cyan%%curcommand%%reset%
  set curcommand=%curcommand:'="%
  call %curcommand%
  SETLOCAL ENABLEDELAYEDEXPANSION
  if defined commandpath popd
    @if defined outfile (call :funcendtest %0) else (call :funcend %0)
goto :eof

:cmd
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" [ "output file to test for" ["path to run  command in"]]
:: Functions called: inccount, checkdir, funcend or any function
:: External program: May use any external program
:: Note: Single quotes get converted to double quotes before the command is used.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  set curcommand=%~1
  set outfile=%~2
  set commandpath=%~3
  if defined outfile call :checkdir "%outfile%"
  set basepath=%cd%
  if exist "%outfile%" move /y "%outfile%" "%outfile%.prev"
  if not defined curcommand (
    echo missing curcommand 
    call :funcend %0
    goto :eof
    )
  set curcommand=%curcommand:'="%
  if defined commandpath call :checkdir "%commandpath%"
  if defined commandpath pushd "%commandpath%"
  @if defined info3 echo %green%Info: current path: %cd%%reset%
  @if defined info2 echo %cyan%%curcommand%%reset%
  call %curcommand%
  if defined commandpath popd
  @if defined outfile (call :funcendtest %0) else (call :funcend %0)
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath" [append]]
:: Functions called: inccount, checkdir, funcend funcbegin
:: External app note: May call any external program
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount
  set command=%~1
  set outfile=%~2
  set commandpath=%~3
  set append=%~4
  if not defined command (
    echo Info: missing command
    if defined info4 echo %funcendtext% %0 
    goto :eof
    )
  if not defined outfile set outfile=%projectpath%\tmp\%group%-%count%--command2file.xml
  if exist "%outfile%" del "%outfile%"
  call :checkdir "%outfile%"
  if not defined append if "%commandpath%" == "append" set append=on
  set curcommand=%command:'="%
  if defined commandpath pushd "%commandpath%"
  if not defined append (
    @if defined info3 echo %green%Info: over writing if file exists.%reset%
    @if defined info2 echo %cyan%%curcommand% ^>  "%outfile%"%reset%
    call %curcommand% > "%outfile%"
  ) else (
    @if defined info3 echo %green%Info: Appending output to end of file.%reset%
    @if defined info2 echo %cyan%%curcommand% ^>^>  "%outfile%"%reset%
    call %curcommand% >> "%outfile%"
  )
  if defined commandpath popd
  @call :funcendtest %0 
goto :eof

:compare
:: Description: Compare two files in WinMergeU
:: Usage: call :copare leftfile rightfile
:: Functions called: infile, outfile, inccount funcend funcbegin funcendtest
:: Created 2023-11-08
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set leftfile=%~1
  set midfile=%~2
  set rightfile=%~2
  if defined rightfile (
    call :start "%winmerge%" "%leftfile%" "%midfile%" "%rightfile%"
  ) else (
    call :start "%winmerge%" "%leftfile%" "%midfile%"
  )
  @call :funcend %0
goto :eof

:condition
:: Description: if file note exists run function
:: Usage: call :condition file function param3--param9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set file=%~1
  set curfunc=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  call :multivarlist 3 8
  if not exist "%file%" call :%curfunc% "%file%" %multivar:'="%
  @call :funcend %0
goto :eof

:copy
:: Description: Provides copying with exit on failure
:: Usage: call :copy infile outfile [append] [xcopy]
:: Functions called: infile, outfile, inccount funcend funcbegin funcendtest
:: Uddated: 2018-11-03
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set fn1=%~nx1
  set fn2=%~nx2
  set fx2=%~x2
  set append=%~3
  set xcopy=%~4
  call :infile "%~1" %0
  call :inccount
  if defined append (
    set append=append
	if defined info3 echo %green%Info: Using 'append' switch.%reset%
  )
  if defined xcopy if defined info3 echo %green%Info: Using xcopy.%reset%
  if not defined xcopy if defined info3 echo %green%Info: Using copy.%reset%
  call :outfile "%~2" "%projectpath%\output\copy-%fn1%.txt" %append%
  call :checkdir "%outfile%
  if not exist "%infile%" call :fatal %0 "File to be copied does not exist" & goto :eof
  rem if not exist "%outfile%" copy nul "%outfile%"
  if defined append set curcommand=copy /A "%outfile%"+"%infile%" "%outfile%"
  if not defined append  set curcommand=copy /y "%infile%" "%outfile%"
  rem xcopy is not working for now.
  if defined xcopy (
    if defined fx2 (
      set curcommand=xcopy /y/s "%infile%" "%outfile%"
	  ) else (
      set curcommand=xcopy /y/s/i "%infile%" "%outpath%"
	)
  )
  if defined info3 echo %blue%%curcommand%%reset%
  %curcommand% > nul
  @call :funcendtest %0
goto :eof

:copy2usb
:: Description: Set up to cop files to USB drive and optionally format.
:: Usage: call :copy2usb source_path target_drive target_folder [format_first]
:: Functions called: funcend funcbegin
:: External apps: xcopy
:: Note: external program xcopy (a part of Windows)
  @call :funcbegin %0 "'%~1' '%~2' '%~3' %~4"
  set sourcepath=%~1
  set targetdrive=%~2
  set targetpath=%~3
  set format=%~4
  set volumename=%~5
  set protecteddrives=a b c d e l p s t
  if not exist %targetdrive%:\ call :funcend %0 "Drive %targetdrive%: not available!" & goto :eof
  if "%protecteddrives%" neq "!protecteddrives:%targetdrive%=!" echo System drive! Abort! & call :funcend %0 & goto :eof
  if defined format FORMAT %targetdrive%: /V:%volumename% /Q /X /Y
  echo Copying %targetdrive%:\%targetpath%
  XCOPY /V /I /Q /G /Y /J "%sourcepath%" "%targetdrive%:\%targetpath%"
  EjectMedia %targetdrive%:
  if "%errorlevel%" neq "0" pause
  @call :funcend %0
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Functions called: detectdateformat  funcend funcbegin
:: Required variables: dateseparator
:: Created: 2016-05-04
rem got this from: http://www.robvanderwoude.com/datetiment.php#IDate
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if not defined dateseparator call :detectdateformat
  FOR /F "tokens=1-4 delims=%dateseparator% " %%A IN ("%date%") DO (
      IF "%dateformat%"=="0" (
          SET fdd=%%C
          SET fmm=%%B
          SET fyyyy=%%D
      )
      IF "%dateformat%"=="1" (
          SET fdd=%%B
          SET fmm=%%C
          SET fyyyy=%%D
      )
      IF "%dateformat%"=="2" (
          SET fdd=%%D
          SET fmm=%%C
          SET fyyyy=%%B
      )
  )
  set curdate=%fyyyy%-%fmm%-%fdd%
  set curisodate=%fyyyy%-%fmm%-%fdd%
  set yyyy-mm-dd=%fyyyy%-%fmm%-%fdd%
  set curyyyy-mm=%fyyyy%-%fmm%
  set curyyyymmdd=%fyyyy%%fmm%%fdd%
  set curyymmdd=%fyyyy:~2%%fmm%%fdd%
  set curUSdate=%fmm%/%fdd%/%fyyyy%
  set curAUdate=%fdd%/%fmm%/%fyyyy%
  set curyyyy=%fyyyy%
  set curyy=%fyyyy:~2%
  set curmm=%fmm%
  set curdd=%fdd%
  @call :funcend %0
goto :eof

:dec
:: Description: Decrease the number variable
:: Usage: call :dec varname
:: Functions called: funcend funcbegin
  @call :funcbegin %0 "'%~1'"
  set /A %~1-=1
  @call :funcend %0
goto :eof

:delfile
:: Description: Delete a file if it exists
:: Functions called: funcend funcbegin
  @call :funcbegin %0 "'%~1'"
  if exist "%~1" del "%~1"
  @call :funcend %0
goto :eof

:detectdateformat
:: Description: Get the date format from the Registery: 0=US 1=AU 2=iso
:: Usage: call :detectdateformat
  @call :funcbegin %0
  set KEY_DATE="HKCU\Control Panel\International"
  rem get dateformat number
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v iDate`) DO set dateformat=%%A
  rem get the date separator: / or -
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sDate`) DO set dateseparator=%%A
  rem get the time separator: : or ?
  FOR /F "usebackq skip=2 tokens=3" %%A IN (`REG QUERY %KEY_DATE% /v sTime`) DO set timeseparator=%%A
  rem set project log file name by date
  if defined info3 echo %green%Info: dateformat = %dateformat%%reset%
  if defined info3 echo %green%Info: dateseparator = %dateseparator%%reset%
  if defined info3 echo %green%Info: timeseparator = %timeseparator%%reset%
  @call :funcend %0
goto :eof

:drivepath
:: Description: returns the drive and path from a full drive:\path\filename
:: Usage: call :drivepath C:\path\name.ext|path\name.ext
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if defined fatal goto :eof
  set utdp=%~dp1
  set drive=%~d1
  set drivelet=%drive:~0,1%
  set drivepath=%utdp:~0,-1%
  @call :funcend %0
goto :eof

:echo
:: Description: Echo a message
:: Usage: call :echo "message text"
  if "%~1" == "." (
    @echo.
  ) else (
    @echo %~1
  )
goto :eof

:elapsed
:: Description: calculates the elapsed time since the starttime
:: Required variables: starttime
  call :time2sec cursec
  set /A elapsed=%cursec%-%starttime%
  call :sec2time elapsedt %elapsed%
  echo Info: Elapsed time %elapsedt% %elapsedt-units%
goto :eof

:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file [validate-against]
:: Functions called: :infile
:: External program: file.exe http://gnuwin32.sourceforge.net/
:: Required variables: encodingchecker
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  rem if not defined encodingchecker echo Encoding not checked. Encoding Checker not defined. & echo %funcendtext% %0 error1 &goto :eof
  if not exist "%encodingchecker%" call :funcend %0 "file.exe not found! %fileext%" "Encoding not checked." & goto :eof
  set testfile=%~1
  set validateagainst=%~2
  set retname=enc%~n1
  call :infile "%testfile%"
  set nameext=%~nx1
  FOR /F "usebackq tokens=1-2 delims=;," %%A IN (`%encodingchecker% --mime-encoding "%infile%"`) DO set fencoding=%%B 
  @rem echo %magentabg%%fencoding%%reset%
  if defined validateagainst (
    if "%fencoding%" == " %validateagainst% "  ( 
      echo Encoding check: %green%%nameext%%reset% is %greenbg% %validateagainst% %reset%
      set /A badencoding=0+%badencoding%
    ) else (
      if "%fencoding%" == " us-ascii " ( 
        echo Encoding check: %green%%nameext%%reset% is %magentabg%%fencoding%%reset% which is %greenbg% UTF-8 %reset% compatible.
        if "%validateagainst%" == "utf-8" set /A badencoding=0+%badencoding%
      ) else (
        echo Encoding check:  %red%%nameext%%reset% is %redbg%%fencoding%%reset% But expected to be: %redbg% %validateagainst% %reset%
        set /A badencoding=1+%badencoding%
      )
    )
  )
  set %retname%=%badencoding%
  if defined info3 echo %retname% = %badencoding%
  @call :funcend %0
goto :eof

:epubcheck
:: Description: Check Epub file
:: Usage: call :epubcheck epubfile report_file
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1"
  @if defined info2 echo %cyan%%java% -jar "D:\programs\epubcheck\epubcheck.jar" "%1" 2^> "%~2"%reset%
  %java% -jar "D:\programs\epubcheck\epubcheck.jar" "%1" 2> "%~2"
  @call :funcend %0  
goto :eof

:epubzip
:: Description: Use 7zip to build zip an epub file.
:: Usage: call :epubzip epubfilelocation epubname
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  setlocal DISABLEDELAYEDEXPANSION
  xcopy /D "%cd%\setup\epub-add.list" "%projectpath%\output"
  xcopy /D "%cd%\setup\!mimetype" "%projectpath%\output"
  set hostpath=%1
  set epubname=%2
  set hostpath=%hostpath:"=%
  set epubname=%epubname:"=%
  set errorlevel=
  call :outfile "%hostpath%\%epubname%.epub"
  @if defined info2 echo %green%Starting 7zip 3 times to create %epubname%.epub%reset%
  pushd "%hostpath%\%epubname%"
  "C:\Program Files\7-Zip\7z.exe" a -t* ..\%epubname%.epub ..\!mimetype 1> ..\7zip-epub-build.txt 2> ..\7zip-epub-build-errors.txt
  call :errortest 0 "Added !mimtype to zip" "Error adding !mimtype to zip"
  "C:\Program Files\7-Zip\7z.exe" u -tzip ..\%epubname%.epub @..\epub-add.list 1>> ..\7zip-epub-build.txt 2>> ..\7zip-epub-build-errors.txt
  call :errortest 0 "Added content to zip" "Error adding content to zip"
  "C:\Program Files\7-Zip\7z.exe" rn ..\%epubname%.epub !mimetype mimetype 1>> ..\7zip-epub-build.txt 2>> ..\7zip-epub-build-errors.txt
  call :errortest 0 "Renamed file !mimetype to mimetype in zip" "Error renaming file !mimetype to mimetype in zip"
  popd
  set errorlevel=
  SETLOCAL ENABLEDELAYEDEXPANSION
  @call :funcendtest %0
goto :eof

:errortest
:: Description: Used to report on external tools errorlevel report
:: Usage: call :errortest expected_message "message 1" "message 2"
:: Note: The expected_message is nothing "" or 0 for 7zip
  set wantedresult=%~1
  set goodmessage=%~2
  set failmessage=%3
  if %errorlevel%. equ %wantedresult%. (
    @if defined info3 echo   %green%%goodmessage% %reset%
  ) else (
    echo %redbg%   %failmessage%   %reset%
  )
goto :eof

:fatal
:: Description: Used when fatal events occur
:: Usage: call :fatal %0 "message 1" "message 2"
  set func=%~1
  set message=%~2
  set message2=%~3
  rem color 06 
  set pauseatend=on
  @if defined info2 echo %redbg%In %func% %group%%reset% 
  echo %redbg%Fatal error: Task %count% %message% %reset%
  if defined message2 echo %redbg%Task %count% %message2%%reset%
  set fatal=on
  @call :funcend %func%
  pause
goto :eof


:fb
:: Description: Used to give common feed back
:: Usage: call :fb info_or_error_or_output message
  echo %~1: %~2 >> log\log.txt
  if "%~1" == "info" Echo Info: %~2
  if "%~1" == "error" Echo Error: %~2
  if "%~1" == "output" Echo Output: %~2
goto :eof

:file
:: Description: Provides copying with exit on failure
:: Usage: call :copy append|xcopy|move|del infile outfile
:: Functions called: :infile, :outfile, :inccount :funcend
:: Uddated: 2018-11-03
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set action=%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%~dpn2-copy%~x2"
  if not defined action call :funcend %0 "missing parm 3 append|xcopy|move|copy" & goto :eof
  if defined missinginput call :funcend %0 "missing input file" & goto :eof
  call :inccount
  rem echo on
  if "%action%" == "append" set curcommand=copy /y "%outfile%"+"%infile%" "%outfile%" 
  if "%action%" == "copy" set curcommand=copy /y "%infile%" "%outfile%"
  if "%action%" == "xcopy"  set curcommand=xcopy /i/y/s "%infile%" "%outfile%"
  if "%action%" == "move"  set curcommand=move /y "%infile%" "%outfile%"
  %curcommand%
  rem echo off
  @call :funcendtest %0
goto :eof

:funcbegin
:: Descriptions: takes initialization out of funcs
:: Modified: 2023-01-03
  @set func=%~1
  @rem the following line removes the func colon at the begining. Not removing it causes a crash.
  @set funcname=%func:~1%
  @set fparams=%~2
  @if defined button echo %magenta%   ----  %button%   ----%reset%& set button=
  @if defined info4 echo %magenta%%funcstarttext%%reset%
  @if defined info3 echo %magentabg%%func%%reset%  %fparams%
  @if defined echofunc FOR %%s IN (%echofunc%) DO if "%%s" == "%funcname%" echo  ============== %func% echo is ON =============== & echo on
@goto :eof

:funcend
:: Description: Used for non ouput file func
:: Usage: call :funcend %0
:: Modified: 2023-01-04
  @set func=%~1
  @set message1=%~2
  @set message2=%~3
  @if defined message1 echo %green%Info: %message1%%reset%
  @if defined message2 echo %green%Info: %message2%%reset%
  @if defined info4 echo %magenta%------------------------------------ %func% %funcendtext%%reset%
  @if defined pausefunc FOR %%s IN (%pausefunc%) DO if "%%s" == "%funcname%" echo ========= %func% paused for review ========= & pause
  @rem the following form of %func:~1% removes the colon from the begining of the func.
  @if defined echofunc FOR %%s IN (%echofunc%) DO @if "%%s" == "%funcname%" echo ========= %func% echo switched OFF ========= & echo off
@goto :eof

:funcendtest
:: Description: Used with func that output files. Like XSLT, cct, command2file
:: Usage: call :funcendtest %0 [alt_text]
:: Functions called: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set functest=%~1
  set alttext=%~2
  if not defined alttext set alttext=Output:
  @if defined info1 if exist "%outfile%" echo %green%%alttext% %outfile% %reset%
  @if defined outfile if not exist "%outfile%" Echo %redbg%Task failed: Output file not created! %reset%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & if not defined unittest pause
  @if defined info2 if exist "%outfile%" echo.
  @call :funcend  %0
  @call :funcend  %functest%
@goto :eof

:getfiledatetime
:: Description: Returns a variable with a files modification date and time in yyMMddhhmm  similar to setdatetime. Note 4 digit year makes comparison number too big for batch to handle.
:: Usage: call :getfiledatetime file varname
:: Classs: command - internal - date -time
:: Required parameters: varname file
:: Functions called: :detectdateformat variables
:: Updated: 2016-05-04 2023-01-03
  @call :funcbegin %0 "'%~1' '%~2'"
  set file=%~1
  set filedate=%~t1
  set varname=%~2
  if not defined varname call :funcend %0 "missing varname parameter" & goto :eof
  if not exist "%file%" set %varname%=0 &goto :eof
  rem got and mofified this from: http://www.robvanderwoude.com/datetiment.php#IDate
  FOR /F "tokens=1-6 delims=%timeseparator%%dateseparator% " %%A IN ("%filedate%") DO (
    IF "%dateformat%"=="0" (
        SET fdd=%%B
        SET fmm=%%A
        SET fyyyy=%%C
    )
    IF "%dateformat%"=="1" (
        SET fdd=%%A
        SET fmm=%%B
        SET fyyyy=%%C
    )
    IF "%dateformat%"=="2" (
        SET fdd=%%C
        SET fmm=%%B
        SET fyyyy=%%A
    )
    set fnn=%%E
    if "%timeformat:~0,2%" == "HH" (
        set fhh=%%D
    )
    if "%timeformat:~0,2%" == "hh" (
      call :ampmhour %%D %%F
    )
  )
  set tyy=%fyyyy:~2%
  set thh=%fhh%
  set temp=%tyy%%fMM%%fdd%%thh%%fnn%
  if defined info4 echo  %varname%=%temp%>> file-time.txt
  set %varname%=%temp%
  @if defined info3 echo %green%Info: %0 %varname% = !%varname%!%reset%
  @call :funcend  %0
goto :eof

:greaterthan
:: Description: Compares two file modified date-time and returns variable newerthan=on if true
:: Usage: call :newerthan file1 file2 varname
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set f1=%~1
  set f2=%~2
  set gtvarname=%~3
  set gtresult=
  if not exist "%f1%" call :funcend %0 "%0 func 1st file %~nx1 was not found, so comparison is aborted." & goto :eof
  if not exist "%f2%" call :funcend %0 "%0 func 2nd file %~nx2 was not found, so comparison is aborted." & goto :eof
  call :getfiledatetime "%f1%" file1
  call :getfiledatetime "%f2%" file2
  if %file1%. gtr %file2%. (
    set gtresult=on
    @if defined info4 echo %green%Info: %~nx1 %file1% greater than %~nx2 %file2%.%reset% 
  ) else (
    @if defined info4 echo %green%Info: %~nx1 %file1%  is less than %~nx2 %file2%%reset%
  )
  set %gtvarname%=%gtresult%
  @if defined info3 echo %green%Info: %gtvarname% = !%gtvarname%!%reset%
  @call :funcend %0
goto :eof

:iconv
:: Description: Converts files from CP1252 to UTF-8
:: Usage: call :iconv infile outfile OR call :iconv file_nx inpath outpath
:: Functions called: infile, outfile, funcend
:: External program: iconv.exe http://gnuwin32.sourceforge.net/
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set par1=%~1
  set par2=%~2
  set par3=%~3
  set par4=%~4
  if not defined par4 set par4=CP1252
  if not defined par3 call :infile "%par1%"
  if not defined par3 call :outfile "%par2%" "%projectpath%\tmp\iconv-%~nx1"
  if defined par3 set infile=%par2%\%par1%
  if defined par3 call :outfile "%par3%\%par1%" "%projectpath%\tmp\iconv-%~nx1"
  if not exist "%infile%" echo Error: missing infile = %infile% 
  if not exist "%infile%" if defined info4 echo %funcendtext% %0 
  if not exist "%infile%" goto :eof
  set command=%iconv% -f %par4% -t UTF-8 "%infile%"
  @if defined info2 echo.
  @if defined info2 echo call %command% ^> "%outfile%"
  call %command% > "%outfile%"
  @call :funcendtest %0
goto :eof

:ifdefined
:: Description: Checks for value in variable
:: Usage: call :ifdefined variablename action
:: action note: the action can be a function or a projectfunc
:: Functions called: multivarlist
  set varname=%~1
  set action=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :multivarlist 3 9
  set firstact=%action:~0,1%
  if defined %varname% (
    @if defined info2 echo %xtestt% variable %~1 is defined
    if ~%firstact% neq ~: (
      @if defined info3 echo call :%action% %multivar:'="%
      call :%action% %multivar:'="%
    ) else (
      @if defined info3 echo call %action% %multivar:'="%
      call %action% %multivar:'="%
    )
  ) else (
    @if defined info2 echo %xtestf% variable %~1 is not defined
  )
goto :eof

:ifequal
:: Description: Checks for value in variable
:: Usage: call :ifdefined variablename action
:: Functions called: funcbegin funcend multivarlist
:: Note: the action can be a function or a project_function
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set t1=%~1
  set t2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :multivarlist 3 9
  set firstact=%action:~0,1%
  if "%t1%" == "%t2%" (
    @if defined info3 echo %xtestt% "%t1%" ==  "%t2%" are equal
    %multivar:'="%
  ) else (
    @if defined info3 echo %xtestf% "%t1%" ==  "%t2%" are NOT equal
  )
  @call :funcend %0
goto :eof

:ifexist
:: Description: tests if a file exists
:: Usage: call :ifexist testfile action par*
:: action note: the action can be a dos command or call a xrun function or call a project taskgroup
:: Functions called: inccount funcbegin funcend
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set testfile=%~1
  set nameext=%~nx1
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :inccount
  if not defined testfile call :funcend %0 "Error:  missing testfile parameter" & goto :eof
  if not defined param2 call :funcend %0 "Error: missing action param2" "%funcendtext% %0 error2" & goto :eof
  call :multivarlist 2 6
  if exist "%testfile%" (
    if defined info3 echo %xtestt% %nameext% does exist. %green%Action:%reset% %multivar:'="%
    %multivar:'="%
    rem %param2% %param3% %param4% %param5% %param6%     
  ) else (
    if defined info3 echo %xtestf% %nameext% does not exist. %green%Action:%reset% none.
  )
  @call :funcend %0
goto :eof

:ifnotdefined
:: Description: Checks if true
:: Usage: call :ifnotdefined action par1 par 2 par3 par4
:: action note: the action can be a function or a projectfunc
  set varname=%~1
  set action=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :multivarlist 3 9
  set firstact=%action:~0,1%
  if not defined %varname% (
    @if defined info2 echo %xtestt% variable %~1 is not defined
    if ~%firstact% neq ~: (
      @if defined info3 echo call :%action% %multivar:'="%
      call :%action% %multivar:'="%
    ) else (
      @if defined info3 echo call %action% %multivar:'="%
      call %action% %multivar:'="%
    )
  ) else (
    @if defined info2 echo %xtestf% variable %~1 is defined
  )
goto :eof

:ifnotequal
:: Description: Checks for value in variable, if not equal
:: Usage: call :ifdefined variablename action
:: Functions called: funcbegin funcend multivarlist
:: Note: the action can be a function or a project_function
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set t1=%~1
  set t2=%~2
  set action=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :multivarlist 4 9
    if "%t1%" neq "%t2%" (
    @if defined info3 echo %xtestt% "%t1%" ==  "%t2%" are not equal
    @if defined info4 echo %multivar:'="%
    %multivar:'="%
  ) else (
    @if defined info3 echo %xtestf% "%t1%" ==  "%t2%" are equal
  )
  @call :funcend %0
goto :eof

:ifnotexist
:: Description: If a file or folder do not exist, then performs an action.
:: Usage: call :ifnotexist testfile action parm*
:: action note: the action can be a dos command or call a xrun function or call a project taskgroup
:: Functions called: inccount
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set testfile=%~1
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  set filename=%~nx1
  call :inccount
  call :multivarlist 2 9
  if not defined testfile call :funcend %0 "missing testfile parameter" & goto :eof
  if not defined param2 call :funcend %0 "missing action param2 parameter" & goto :eof
  call :multivarlist 2 6
  set firstact=%param2:~0,1%
  if not exist "%testfile%" (
    if defined info3 echo %xtestt% %testfile% does not exist. 
      if defined info4 echo %multivar:'="%
      %multivar:'="%
  ) else (
    if defined info3 echo %xtestf% %filename% does exist. No action %param2% taken.
  )
  @call :funcend %0

goto :eof

:inc
:: Description: Increase the number variable
:: Usage: call :inc varname
  @call :funcbegin %0 "'%~1'"
  set /A %~1+=1
  @call :funcend %0 !%~1!
goto :eof

:inccount
:: Description: Increments the count variable
:: Usage: call :inccount
  @call :funcbegin %0
  set /A count=%count%+1
  @if defined info3 echo %green%Info: count = %count%%reset%
  @call :funcend %0
goto :eof

:infile
:: Description: If infile is specifically set then uses that else uses previous outfile.
:: Usage: call :infile "%file%" calling-func
:: Functions called: fatal
  @call :funcbegin %0 "'%~1' '%~2'"
  set infile=%~1
  set callingfunc=%~2
  if not defined infile set infile=%outfile%
  if not exist "%infile%" call :fatal %0 "infile %~nx1 not found for %callingfunc%"
  @if defined info4 echo Info: %green%infile = %infile%%reset%
  @call :funcend %0
goto :eof

:ini2xslt
:: Description: Convert ini file to xslt
:: Usage: call :ini2xslt file.ini output.xslt subfunc sectionexit
:: Functions called: inccount, infile, outfile.
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1" %0
  call :outfile "%~2" "%cd%\setup\xrun.xslt" 
  set subfunc=%~3
  set section=%~4
  if defined info2 echo Setup: Make xrun.xslt from: %~nx1
  echo ^<xsl:stylesheet xmlns:f="myfunctions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="f"^> > "%outfile%"
  FOR /F "eol=] tokens=1,2 delims==" %%u IN (%infile%) DO call :%subfunc% "%outfile%" "%section%" xsl:variable name %%u select "%%v" 
  echo ^</xsl:stylesheet^> >> "%outfile%"
  @set sectionexit=
  @call :funcend %0
goto :eof  

:ini2xslt2
:: Description: Convert ini file to xslt
:: Usage: call :ini2xslt file.ini output.xslt subfunc sectionexit
:: Functions called: inccount, infile, outfile.
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1" %0
  call :outfile "%~2" "%cd%\setup\xrun.xslt" 
  set subfunc=%~3
  set section=%~4
  if defined info2 echo Setup: Make xrun.xslt from: %~nx1
  echo ^<xsl:stylesheet xmlns:f="myfunctions" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0" exclude-result-prefixes="f"^> > "%outfile%"
  FOR /F "eol=] tokens=1,2 delims==" %%u IN (%infile%) DO call :%subfunc% "%outfile%" "%section%" xsl:variable name %%u select "%%v" 
  echo ^</xsl:stylesheet^> >> "%outfile%"
  @set sectionexit=
  @call :funcend %0
goto :eof  

:iniline2var
:: Description: Sets variables from one section
:: Usage: call :variableset line sectionget
:: Unused:
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set line=%~1
  set sectionget=%~2
  if "%line%" == "[%~2]" set sectionstart=on
  if "%line:~0,1%" == "[" @call :funcend %0
  if "%line:~0,1%" == "[" set sectionstart= &goto :eof
  if not defined sectionstart @call :funcend %0
  if not defined sectionstart goto :eof
  if defined sectionstart set %line%
  @call :funcend %0
goto :eof


:iniparse4xslt
:: Description: Parse the = delimited data and write to xslt . Skips sections and can exit when
:: Usage: call :iniparse4xslt outfile section element att1name att1val att2name att2val
:: Functions called: inccount
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7'"
  if defined sectionskip @call :funcend %0
  if defined sectionskip goto :eof
  set outfile=%~1
  set section=%~2
  set element=%~3
  set att1name=%~4
  set att1val=%~5
  set att2name=%~6
  set att2val=%~7
  if "%att1val:~0,1%" == "[" if exist insection.txt del insection.txt
  if "[%section%]" == "%att1val%" call :inccount  &  echo %att1val% > insection.txt
  if "%att1val:~0,1%" == "["  @call :funcend %0 & goto :eof
  if "%att1val:~0,1%" == "#" @call :funcend %0
  if "%att1val:~0,1%" == "#" goto :eof
  if defined att1name set attrib1=%att1name%="%att1val%"
  if defined att1name set attriblist1=%att1name%="%att1val:_list=%"
  if defined att2name set attrib2=%att2name%="'%att2val%'"
  if defined att2name set attriblist2=%att2name%="tokenize($%att1val%,' ')"
  if exist insection.txt (
    if defined info3 echo     variable written
    echo   ^<%element% %attrib1% %attrib2%/^> >> "%outfile%"
    if %att1val% neq %att1val:_list=% echo   ^<%element% %attriblist1% %attriblist2%/^> >> "%outfile%"
  )
  @call :funcend %0
goto :eof

:inisection
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist inifile sectionget linefunc
:: Unused:
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set list=%~1
  set sectionget=%~2
  set linefunc=%~3
  FOR /F "eol=] delims=`" %%q IN (%list%) DO call :%linefunc% "%%q" %sectionget%
  set sectionstart=
  @if defined info2 echo Setup: tasks created from: %~nx1
  @call :funcend %0
goto :eof

:inputfile
:: Description: Sets the starting file of a serial tasklist, by assigning it to the var outfile
:: usage: call :inputfile "drive:\path\file.ext"
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set outfile=%~1
  if not defined outfile echo Missing param1  & set skip=on
  @call :funcend %0
goto :eof

:jade
:: Description: Create html/xml from jade file (now pug) Still uses jade extension
:: Usage: call :jade "infile" "outfile" start
:: Functions called: inccount, infile, outfile, nameext, name, funcend 
:: External program: NodeJS npm program jade
  @call :funcbegin %0 "'%~1' '%~2'"
  call :inccount
  call :infile %~1
  set outfile=%~2
  call :drivepath "%outfile%"
  call :nameext "%outfile%"
  if not defined outfile set outfile=%projectpath%\tmp\jade-%count%.html
  set start=%~3
  echo jade -P -E "%ext:~1%" -o "%drivepath%" "%infile%"
  call jade -P -E "%ext:~1%" -o "%drivepath%" "%infile%"
  rem echo call jade -P ^< "%infile%" ^> "%outfile%"
  rem call jade -P < "%infile%" > "%outfile%"
  rem  @if defined info2 echo off
  rem ren "%outpath%\%infilename%%ext%" "%nameext%"
  if defined start start "" "%~2"
  @call :funcendtest %0
goto :eof

:javahometest
:: Description: Tests for a Java home installations
:: Note: Not currently used.
  @call :funcbegin %0
  set JAVA_HOME=%JAVA_HOME:"=%
  set JAVA_EXE=%JAVA_HOME%/bin/java.exe
  if not exist "%JAVA_EXE%" (
    set javahome=ERROR: JAVA_HOME is set to an invalid directory: %JAVA_HOME% 
    call :javainpathtest
    )
  @call :funcend %0
goto :eof

:javainpathtest
:: Description: Tests if Java is included in the path
  @call :funcbegin %0
  set JAVA_EXE=java.exe
  %JAVA_EXE% -version >NUL 2>&1
  if "%ERRORLEVEL%" neq "0" (
    set javapath=Error: No 'java' command could be found in your PATH.
    set nojava=true
    call :javanotfound 
    )
  @call :funcend %0
goto :eof

:javanotfound
:: Description: This is an error report if Java is not found
echo.
if defined javahome echo %javahome%
if defined javapath echo %javapath%
echo.
echo Fatal: Is Java installed?
echo.
echo Please set the JAVA_HOME variable in your environment to match the
echo location of your Java installation.
goto :eof

:last
:: Description: Find the last parameter in a set of numbered params. Usually called by a loop.
:: Usage: call :last par_name number
  if defined lastfound goto :eof
  set last=!%~1%~2!
  if defined last set lastfound=on
goto :eof


:libreconvert
:: Description: Use Libre office to convert document formats
:: Usage: call :libreconvert convert_to_type input_file/s output-dir
:: Note: No trailing backslash on the output directory.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set convtype=%~1
  set infile=%~2
  set outdir=%~3
  if not defined liboff call :fatal "Libre Office executable not defined." & goto :oef
  set curcommand="%liboff%" --headless --convert-to %convtype% --outdir "%outdir%" "%infile%"
  if defined info2 echo %cyan%call %curcommand%%reset%
  call %curcommand%
  @call :funcend %0
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles sub_name file_specs [param[3-9]]
:: Functions called: appendnumbparam, last, taskgroup. Can also use any other function.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  if defined fatal goto :eof
  set grouporfunc=%~1
  set filespec=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  rem set numbparam=
  rem set appendparam=
  if not defined grouporfunc echo %error% Missing func parameter[2]%reset%
  if not defined grouporfunc if defined info4 echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined filespec echo %error% Missing filespec parameter[1]%reset%
  if not defined filespec if defined info4 echo %funcendtext% %0 
  if not defined filespec goto :eof
  if not exist "%filespec%" echo %error% Missing source files %reset%
  if not exist "%filespec%" if defined info4 echo %funcendtext% %0 
  if not exist "%filespec%" goto :eof
  @if defined loopfilesecho echo off
  call :multivarlist 3 9
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  rem for /L %%v in (3,1,9) Do call :last par %%v
  if defined info3 if defined numbparam set %multivar%
  if "%grouporfunc:~0,1%" == ":" (
      FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n "%filespec%"') DO  call %grouporfunc% "%%s" %multivar:'="%
    ) else (
      FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n "%filespec%"') DO  call :%grouporfunc% "%%s" %multivar:'="%
  )  
  @call :funcend %0
goto :eof

:loopfolders
:: Description: Loops through all subfolders in a folder
:: Usage: call :loopdir grouporfunc basedir [param[3-9]]
:: Functions called: * - May be any function or project Taskgroup
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined loopdirecho echo on
  set grouporfunc=%~1
  set basedir=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :qoutevar 3 9
  rem set appendparam=
  rem set numbparam=
  if not defined grouporfunc call :funcend %0 "Missing function or task-group parameter" & goto :eof
  if not defined basedir call :funcend %0 "Missing basedir parameter" & goto :eof
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  rem for /L %%v in (3,1,9) Do call :last par %%v
  set grouporfunc=%grouporfunc:'="%
  rem if defined last echo %last%
  if "%grouporfunc:~0,1%" == ":" FOR /F " delims=" %%s IN ('dir /b /a:d "%basedir%"') DO call :%grouporfunc% "%%s" %multivar:'="%
  if "%grouporfunc:~0,1%" neq ":" FOR /F " delims=" %%s IN ('dir /b /a:d "%basedir%"') DO call :%grouporfunc% "%%s" %multivar:'="%
  @call :funcend %0
  @if defined loopdirecho echo off
goto :eof

:looplist
:: Description: Used to loop through list supplied in a file
:: Usage: call :looplist sub_name list-file_specs [param[3-9]]
:: Functions called: appendnumbparam, last, taskgroup. Can also use any other function.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  if defined fatal goto :eof
  set grouporfunc=%~1
  set listfile=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  if not defined grouporfunc echo %error% Missing func parameter[2]%reset%
  if not defined grouporfunc if defined info4 echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined listfile echo %error% Missing list-file parameter[1]%reset%
  if not defined listfile if defined info4 echo %funcendtext% %0 
  if not defined listfile goto :eof
  if not exist "%listfile%" echo %error% Missing source: %listfile% %reset%
  if not exist "%listfile%" if defined info4 echo %funcendtext% %0 
  if not exist "%listfile%" goto :eof
  call :multivarlist 3 9
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  rem for /L %%v in (3,1,9) Do call :last par %%v
  rem if defined info3 set numbparam
  if defined info4 if defined comment echo %last%
  if not defined unittest (
    if "%grouporfunc:~0,1%" == ":" (
        FOR /F " delims=" %%s IN (%listfile%) DO  call %grouporfunc% "%%s" %multivar:'="%
      ) else (
        FOR /F " delims= " %%s IN (%listfile%) DO  call :%grouporfunc% "%%s" %multivar:'="%
  )  
    )  
  )  
  @call :funcend %0
goto :eof

:looplistspace
:: Description: Used to loop through list supplied in a file
:: Usage: call :looplist sub_name list-file_specs [param[3-9]]
:: Functions called: appendnumbparam, last, taskgroup. Can also use any other function.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  if defined fatal goto :eof
  set grouporfunc=%~1
  set listfile=%~2
  if not defined grouporfunc echo %error% Missing func parameter[2]%reset%
  if not defined grouporfunc if defined info4 echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined listfile echo %error% Missing list-file parameter[1]%reset%
  if not defined listfile if defined info4 echo %funcendtext% %0 
  if not defined listfile goto :eof
  if not exist "%listfile%" echo %error% Missing source: %listfile% %reset%
  if not exist "%listfile%" if defined info4 echo %funcendtext% %0 
  if not exist "%listfile%" goto :eof
  FOR /F "tokens=* delims= " %%a IN (%listfile%) DO  call :%grouporfunc% %%a %%b %%c %%d %%e %%f %%g %%h
  @call :funcend %0
goto :eof

:loopnumber
:: Description: Loops through a set of numbers.
:: Usage: call :loopnumber grouporfunc start stop
:: Functions called: taskgroup. Can also use any other function.
:: Note: action may have multiple parts
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if defined fatal goto :eof
  rem echo on
  set grouporfunc=%~1
  set start=%~2
  set end=%~3
  set step=%~4
  if not defined start set start=1
  if not defined end set end=12
  if not defined step set step=1
  if not defined grouporfunc echo Missing action parameter
  if not defined grouporfunc echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined start echo Missing start parameter
  if not defined start if defined info4 echo %funcendtext% %0 
  if not defined start goto :eof
  if not defined end echo Missing end parameter
  if not defined end echo %funcendtext% %0 
  if not defined end goto :eof
  if "%grouporfunc:~0,1%" == ":" FOR /L %%s IN (%start%,%step%,%end%) DO call %grouporfunc% "%%s"
  if "%grouporfunc:~0,1%" neq ":" FOR /L %%s IN (%start%,%step%,%end%) DO call :%grouporfunc% "%%s"
  @call :funcend %0
  rem @echo off
goto :eof

:loopstring
:: Description: Loops through a list supplied in a space separated string.
:: Usage: call :loopstring grouporfunc "string" [param[3-9]]
:: Functions called: quotevar, last, taskgroup. Can also use any other function.
:: Note: action may have multiple parts
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7'"
  if defined fatal goto :eof
  rem echo on
  set grouporfunc=%~1
  set string=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  if not defined grouporfunc echo Missing action parameter
  if not defined grouporfunc echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined string echo Missing string parameter
  if not defined string if defined info4 echo %funcendtext% %0 
  if not defined string goto :eof
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v 
  rem for /L %%v in (3,1,9) Do call :last par %%v
  call :multivarlist 3 9
  if defined info3 set multivar
  if "%grouporfunc:~0,1%" == ":" FOR %%s IN (%string%) DO call %grouporfunc% "%%s" %multivar:'="%
  if "%grouporfunc:~0,1%" neq ":" FOR %%s IN (%string%) DO call :%grouporfunc% "%%s" %multivar:'="%
  @call :funcend %0
  rem @echo off
goto :eof

:makef
:: Description: This runs the makefile script for checking if the project.xslt is up to date
:: Usage: call :runmake makefile-path-filename
:: Required variables: make 
  @call :funcbegin %0 "'%~1'"
  set makepath=%~dp1
  set makefile=%~nx1
  @if defined info2 echo %green%Running makefile: %makefile%%reset%
  pushd "%makepath%"
  call %make% -f %makefile%
  popd
  @call :funcend %0
goto :eof


:make
:: Description: Run a make file
:: Usage: call make [makepath makefile] 
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  set workpath=%~1
  set makefile=%~2
  pushd "%workpath%"  
  if defined makefile (
    if defined info2 echo %green%Checking: %makefile%%cyan%
    call %make% -f %makefile%
  ) else (
    if defined info2 echo %green%Checking: makefile in %workpath%
    call %make%
  )
  echo %green%------- End check: %reset%
  popd
  @call :funcend %0
goto :eof

:makemake
:: Description: Create makefile with relevant variables
:: Usage: call :makevar fileto add to
:: Note: the body of the make fiels should be in setup folder and in the form filename-make.txt
  set file=%~1
  set filenx=%~nx1
  set makesource=%~dp1
  if \%filenx% == \projxslt.make set makesource=setup
  if \%filenx% == \projsetup.make set makesource=setup
  set n1=%~2
  set v1=%~3
  set n2=%~4
  set v2=%~5
  set n3=%~6
  set v3=%~7
  set n4=%~8
  set v4=%~9
  echo projectpath := %projectpath%> %file%
  echo projectmpath := %projectpath::=\:%>> %file%
  echo xrunnerpath := %cd%>> %file%
  echo xrunnermpath := %cd::=\:%>> %file%
  echo java := %java%>> %file%
  echo saxon := %saxon%>> %file%
  echo ccw := %ccw%>> %file%
  if defined v1 echo %n1% := %v1%>> %file%
  if defined v2 echo %n2% := %v2%>> %file%
  if defined v3 echo %n3% := %v3%>> %file%
  if defined v4 echo %n4% := %v4%>> %file%
  copy /y %file%+%makesource%\%filenx:.=-%.txt %file% >nul
goto :eof 

:mergevar
:: Description: Merge two numbered variable into one with a space between them
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  set pname=%~1
  set vname=%~2
  set v1=%~3
  set v2=%~4
  set %vname%=!%pname%%v1%!!%pname%%v2%!
  @call :funcend %0
goto :eof

:modelcheck
:: Description: Copies in files from Model project
:: Usage: call :modelcheck "file.ext" "modelpath"
  @call :funcbegin %0 "'%~1' '%~2'"
  set infile=%~2\%~1
  set outname=%~1
  if not exist "%projectpath%\scripts\%outname%" copy "%infile%" "%projectpath%\scripts\" >> log.txt
goto :eof
   
:multivarlist
:: Descriptions: if varaible string contains a space put double quotes around it.
:: Usage: call quotevar var_name start_numb end_numb
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set startnumb=%~1
  set endnumb=%~2
  for /L %%v in (%startnumb%,1,%endnumb%) Do if defined param%%v if "!param%%v!" neq "!param%%v: =!" set param%%v='!param%%v!'
  if %startnumb%. == 1. set multivar=%param1% %param2% %param3% %param4% %param5% %param6% %param7% %param8% %param9%
  if %startnumb%. == 2. set multivar=%param2% %param3% %param4% %param5% %param6% %param7% %param8% %param9%
  if %startnumb%. == 3. set multivar=%param3% %param4% %param5% %param6% %param7% %param8% %param9%
  if %startnumb%. == 4. set multivar=%param4% %param5% %param6% %param7% %param8% %param9%
  if defined info3 echo %green%Info: multivar = %multivar%%reset%
  @call :funcend %0
goto :eof


:name
:: Description: Returns a variable name containg just the name from the path.
  @call :funcbegin %0 %~1
  set name=%~n1
  set fext=%~x1
  set fpath=%~p1
  set fdrive=%~d1
  @if defined info3 set name
  @call :funcend %0
goto :eof

:nameext
:: Description: Returns a variable nameext containg just the name and extension from the path.
  @call :funcbegin %0 %~1
  set nameext=%~nx1
  set name=%~n1
  set ext=%~x1
  @if defined info3 echo %green%Info: nameext = %nameext%%reset%
  @if defined info3 echo %green%Info: name = %name%%reset%
  @if defined info3 echo %green%Info: ext = %ext%%reset%
  @call :funcend %0
goto :eof

:outfile
:: Description: If out file is specifically set then uses that else uses supplied name.
:: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck_or_append
:: Functions called: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set toutfile=%~1
  set defaultoutfile=%~2
  set check=%~3
  set outnx=%~nx1
  set defaultoutdp=%~dp2
  set defaultoutnx=%~nx2
  set outpath=%~dp1
  set outpath=%outpath:~-1%
  rem the folloing is to preserve wildcards in the outfile. Since *.* when using %~nx1 becomes . not *.*
  @if defined info3 echo %green%Info: outnx = %outnx%%reset%
  @if defined info3 echo %green%Info: defaultoutfile = %defaultoutfile%%reset%
  rem now if toutfile is not defined then use default value
  if defined toutfile (set outfile=%toutfile%) else (set outfile=%defaultoutfile%)
  if not defined toutfile set outpath=%defaultoutdp%
  if not defined toutfile set outnx=%defaultoutnx%
  if defined check if "%check%" neq "append" set check=nocheck
  if not defined check if not exist "%outpath%" md "%outpath%"
  if "%outnx%" neq "" (
  if "%check%" neq "append" (
	  rem remove %outfile%.prev if it exists. Works with wildcards
	  if exist "%outfile%.prev" del "%outfile%.prev"
	  rem if outfile exists then rename to file.ext.prev; this works with wild cards too now.
	  if exist "%outfile%" ren "%outfile%" "%outnx%.prev"
  )
  )
  @if defined info5 echo.
  @if defined info4 echo %green%Info: outfile = %outfile%%reset%
  @call :funcend %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext [start] [validate] [copy]
:: Functions called: checkdir, funcend, validate
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set infile=%outfile%
  set outfile=%~1
  set var2=%~2
  set var3=%~3
  set var4=%~4
  if defined var2 set %var2%=%~1
  if defined fatal goto :eof
  call :checkdir "%outfile%"
  if not defined var4 (
    move /Y "%infile%" "%outfile%" >> log.txt
  ) else ( 
    call :copy "%infile%" "%outfile%"
  )
  if "%var2%" == "start" if exist "%outfile%" start "" "%outfile%"
  if "%var3%" == "start" if exist "%outfile%" start "" "%outfile%"
  if "%var2%" == "validate" call :validate "%outfile%"
  if "%var3%" == "validate" call :validate "%outfile%"
  @call :funcendtest %0 Renamed:
goto :eof

:paratextio
:: Description: Loops through a list of books and extracts USX files.
:: Usage: call :paratextio project "book_list" [outpath] [write] [usfm]
:: Functions called: ptbook
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set proj=%~1
  set string=%~2
  set outpath=%~3
  set write=%~4
  set usfm=%~5
  rem HKLM\Software\Wow6432Node\ScrChecks\1.0\Settings_Directory
  if defined info2 echo Info: Starting reading (or writing) from Paratext project %proj% 
  FOR %%s IN (%string%) DO call :ptbook %proj% %%s "%outpath%" "%write%" "%usfm%"
  @call :funcend %0
goto :eof

:pause
:: Description: Used in project.txt to pause the processing
  pause
goto :eof

:perl
:: Description: Privides interface to perl scripts
:: Usage: call :cct script.cct ["infile.txt" ["outfile.txt" ["par1"]]
:: Functions called: inccount, infile, outfile, funcend
:: External program: ccw.exe https://software.sil.org/cc/
:: Required variable: ccw
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount %count%
  set script=%~1
  set append=%~4
  if not defined script call :fatal %0 "CCT script not supplied!" & goto :eof
  if not exist "%scripts%\%script%" call :fatal %0 "CCT script not found!  %scripts%\%script%" & goto :eof
  call :infile "%~2" %0
  if defined missinginput  call :fatal %0 "infile not found!" & goto :eof
  set cctparam=-u -b -q -n
  if defined append set cctparam=-u -b -n -a
  if not exist "%perl%" call :fatal %0 "missing perl.exe file" & goto :eof
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%script%.xml"
  set par1=%~4
  if defined fatal goto :eof
  set curcommand="%perl%" "%script%" "%infile%" "%outfile%" "%par1%"
  @if defined info2 echo. & echo %curcommand%
  pushd "%scripts%"
  call %curcommand%
  popd
  @call :funcendtest %0
goto :eof

:prerender
:: Description: Prerenders HTML with JS into plain HTML
:: Usage: call :prerender url outpath
:: Functions used: inccount, infile, outfile, funcbegin, funcend
:: Required program: chrome.exe 
:: Required variable: chrome
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set url=%~1
  set filename=%~nx1
  set outpath=%~2
  call :command2file "'%chrome%' --headless --dump-dom --disable-gpu %url%" "%outpath%\%filename%"
  @call :funcend %0
goto :eof

:prince
:: Description: Make PDF using PrinceXML
:: Usage: call :prince [infile [outfile [css]]] [infile2] [infile3] [infile4] [infile5] [infile6] [infile7]
:: Functions called: infile, outfile, funcend
:: External program: prince.exe  https://www.princexml.com/
:: External program: prince
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\output\output.pdf" 
  set css=%~3
  set infile2=%~4
  set infile3=%~5
  set infile4=%~6
  set infile5=%~7
  set infile6=%~8
  set infile7=%~9
  set infile="%infile%"
  if defined infile2 set infile="%infile%" "%infile2%" 
  if defined infile3 set infile="%infile%" "%infile3%" 
  if defined infile4 set infile="%infile%" "%infile4%" 
  if defined infile5 set infile="%infile%" "%infile5%"
  if defined infile6 set infile="%infile%" "%infile6%"
  if defined infile7 set infile="%infile%" "%infile7%"
  if defined css set css=-s "%css%"
  set curcommand=call "%prince%" %css% %infile% %infile2% %infile3% %infile4% %infile5% %infile6% %infile7% -o "%outfile%"
  @if defined info2 echo %cyan%call %curcommand%%reset%
  call %curcommand%
  @call :funcendtest %0
goto :eof

:ptbkno
:: Description: set bknumb variable based on book 3 letter book code
:: Usage: call :ptbkno book
  set book=%~1
  if "%book%" == "GEN" set bknumb=001
  if "%book%" == "EXO" set bknumb=002
  if "%book%" == "LEV" set bknumb=003
  if "%book%" == "NUM" set bknumb=004
  if "%book%" == "DEU" set bknumb=005
  if "%book%" == "JOS" set bknumb=006
  if "%book%" == "JDG" set bknumb=007
  if "%book%" == "RUT" set bknumb=008
  if "%book%" == "1SA" set bknumb=009
  if "%book%" == "2SA" set bknumb=010
  if "%book%" == "1KI" set bknumb=011
  if "%book%" == "2KI" set bknumb=012
  if "%book%" == "1CH" set bknumb=013
  if "%book%" == "2CH" set bknumb=014
  if "%book%" == "EZR" set bknumb=015
  if "%book%" == "NEH" set bknumb=016
  if "%book%" == "EST" set bknumb=017
  if "%book%" == "JOB" set bknumb=018
  if "%book%" == "PSA" set bknumb=019
  if "%book%" == "PRO" set bknumb=020
  if "%book%" == "ECC" set bknumb=021
  if "%book%" == "SNG" set bknumb=022
  if "%book%" == "ISA" set bknumb=023
  if "%book%" == "JER" set bknumb=024
  if "%book%" == "LAM" set bknumb=025
  if "%book%" == "EZK" set bknumb=026
  if "%book%" == "DAN" set bknumb=027
  if "%book%" == "HOS" set bknumb=028
  if "%book%" == "JOL" set bknumb=029
  if "%book%" == "AMO" set bknumb=030
  if "%book%" == "OBA" set bknumb=031
  if "%book%" == "JON" set bknumb=032
  if "%book%" == "MIC" set bknumb=033
  if "%book%" == "NAM" set bknumb=034
  if "%book%" == "HAB" set bknumb=035
  if "%book%" == "ZEP" set bknumb=036
  if "%book%" == "HAG" set bknumb=037
  if "%book%" == "ZEC" set bknumb=038
  if "%book%" == "MAL" set bknumb=039
  if "%book%" == "MAT" set bknumb=040
  if "%book%" == "MRK" set bknumb=041
  if "%book%" == "LUK" set bknumb=042
  if "%book%" == "JHN" set bknumb=043
  if "%book%" == "ACT" set bknumb=044
  if "%book%" == "ROM" set bknumb=045
  if "%book%" == "1CO" set bknumb=046
  if "%book%" == "2CO" set bknumb=047
  if "%book%" == "GAL" set bknumb=048
  if "%book%" == "EPH" set bknumb=049
  if "%book%" == "PHP" set bknumb=050
  if "%book%" == "COL" set bknumb=051
  if "%book%" == "1TH" set bknumb=052
  if "%book%" == "2TH" set bknumb=053
  if "%book%" == "1TI" set bknumb=054
  if "%book%" == "2TI" set bknumb=055
  if "%book%" == "TIT" set bknumb=056
  if "%book%" == "PHM" set bknumb=057
  if "%book%" == "HEB" set bknumb=058
  if "%book%" == "JAS" set bknumb=059
  if "%book%" == "1PE" set bknumb=060
  if "%book%" == "2PE" set bknumb=061
  if "%book%" == "1JN" set bknumb=062
  if "%book%" == "2JN" set bknumb=063
  if "%book%" == "3JN" set bknumb=064
  if "%book%" == "JUD" set bknumb=065
  if "%book%" == "REV" set bknumb=066
  if "%book%" == "TOB" set bknumb=067
  if "%book%" == "JDT" set bknumb=068
  if "%book%" == "ESG" set bknumb=069
  if "%book%" == "WIS" set bknumb=070
  if "%book%" == "SIR" set bknumb=071
  if "%book%" == "BAR" set bknumb=072
  if "%book%" == "LJE" set bknumb=073
  if "%book%" == "S3Y" set bknumb=074
  if "%book%" == "SUS" set bknumb=075
  if "%book%" == "BEL" set bknumb=076
  if "%book%" == "1MA" set bknumb=077
  if "%book%" == "2MA" set bknumb=078
  if "%book%" == "3MA" set bknumb=079
  if "%book%" == "4MA" set bknumb=080
  if "%book%" == "1ES" set bknumb=081
  if "%book%" == "2ES" set bknumb=082
  if "%book%" == "MAN" set bknumb=083
  if "%book%" == "PS2" set bknumb=084
  if "%book%" == "XXA" set bknumb=093
  if "%book%" == "XXB" set bknumb=094
  if "%book%" == "XXC" set bknumb=095
  if "%book%" == "XXD" set bknumb=096
  if "%book%" == "XXE" set bknumb=097
  if "%book%" == "XXF" set bknumb=098
  if "%book%" == "XXG" set bknumb=099
  if "%book%" == "FRT" set bknumb=100
  if "%book%" == "BAK" set bknumb=101
  if "%book%" == "OTH" set bknumb=102
  if "%book%" == "INT" set bknumb=107
  if "%book%" == "CNC" set bknumb=108
  if "%book%" == "GLO" set bknumb=109
  if "%book%" == "TDX" set bknumb=110
  if "%book%" == "NDX" set bknumb=111
goto :eof

:ptbook
:: Description: Extract USX from Paratext
:: Usage: call :ptbook project book [outpath] [write] [usfm]
:: Functions called: outfile, funcend, ptbkno
:: External program: rdwrtp8.exe from https://pt8.paratext.org/
:: Required variables: rdwrtp8
  set proj=%~1
  set book=%~2
  set outpath=%~3
  set write=%~4
  set usfm=%~5
  call :checkdir "%outpath%"
  if not defined write set ptio=-r 
  if defined write set ptio=-w
  call :ptbkno %book%
  if not defined usfm set usx=-x
  if defined outpath call :outfile "%outpath%\%bknumb%%book%.usx"
  if not defined outpath call :outfile "" "%projectpath%\usx\%bknumb%%book%.usx"
  set curcommand="%rdwrtp8%" %ptio% %proj% %book% 0 "%outfile%" %usx%
  if defined info2 echo %curcommand%
  call %curcommand%
  @call :funcendtest %0
goto :eof

:qrcode
:: Description: Generate QR code
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set url=%~1
  set qrnumb=000%~2
  call qrcode -o "%projectpath%\output\qr\qr-%qrnumb:~-3%.png" -t png -w 400 "%url%"
  @call :funcendtest %0
goto :eof

:regex
:: Description: Run a regex on a file
:: Usage: call :regex find replace infile outfile
:: Functions called: inccount, infile, outfile, funcend
:: External program: rxrepl.exe  https://sites.google.com/site/regexreplace/
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  if defined missinginput color 06& call :funcend %0 & goto :eof
  set find="%~1"
  set replace="%~2"
  call :infile "%~3" %0
  call :outfile "%~4" "%projectpath%\tmp\%group%-%count%-regex.txt"
  set options=%~5
  set curcommand=rxrepl.exe %options% --search %find% --replace %replace% -f "%infile%" -o "%outfile%"
  @if defined info2 echo call %curcommand%
  call %curcommand%
  @call :funcendtest %0
goto :eof

:regexren
:: Description: Rename with regular expression
:: Usage: call :regexren file path find replace options
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  if defined missinginput color 06& call :funcend %0 & goto :eof
  set options=/f /r
  set files=%~1
  set drivepath=%~2
  set find=%~3
  set replace=%~4
  set cloptions=%~5
  if defined cloptions set options=%~5
  set curcommand="%regexren%" "%files%" "%find%" "%replace%" %options% 
  pushd "%drivepath%"
  @if defined info2 echo call  %curcommand%
  call %curcommand%
  popd
  @call :funcendtest %0
goto :eof

:rexxini
:: Description: Setup for Rexx scripting
:: Note: unused
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\scripts\xrun.xslt"
  call :nameext "%outfile%"
  set section=%~3
  set process=%~4
  call rexx rexxini.rexx %infile% %outfile% %section% %process%
  if %errorlevel% neq 0 echo Bad write to %nameext%.
  @call :funcend %0
goto :eof

:rho
:: Description: Create xml from .rho file markup
:: Usage: call :rho infile outfile
:: Functions called: infile, outfile, funcend NodeJS NPM program Rho
:: External program: NodeJS npm program Rho
  @call :funcbegin %0 "'%~1' '%~2'"
  call :infile "%~1" %0
  call :outfile "%~2" "%proectpath%\output\rho-out.html"
  call rho -i "%infile%" -o "%outfile%"
  @call :funcendtest %0
goto :eof

:scriptfind
:: Description: Find script if it does not exist in the scritps folder
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  set sname=%~1
  set funcname=%~2
  rem if the script was one of several like in CCT this will skip if it exists.
  if exist "%scripts%\%sname%" (
    echo %sname% found!
    @if defined info4 echo %funcendtext% %0
    goto :eof
    )
  call :nameext "%sname%"
  if defined info3 echo.
  if defined info3 echo %green%Info: Searching other projects for missing script:%reset% %nameext% 
  if exist "%cd%\scripts\generic-pool\%nameext%" (
    copy "%cd%\scripts\generic-pool\%nameext%" "%scripts%"
    ) else (
    FOR /F "" %%f IN ('dir /b /s %projecthome%\%nameext%') DO xcopy "%%f" "%scripts%" /d /y 
    )
  if exist "%scripts%\%nameext%" echo %green%Success: Searching found script: %nameext% %reset%
  if not exist "%scripts%\%nameext%" echo %yellow%Failed: Searching was unable to find script:%reset% %nameext% 
  @call :funcend %0
goto :eof

:sec2time
:: Description: convert seconds to time
:: Usage: call :sec2time varname seconds
:: Variables set: varname varname-units
  set sph=3600
  set spm=60
  set /A hh=%~2/%sph%
  set /A sh=%hh%*%sph%
  set /A mm=(%~2-%sh%)/%spm%
  set /A sm=%mm%*%spm%
  set /A ss=(%~2 - %sh% - %sm%) 
  if %mm% lss 10 set mm=0%mm%
  if %ss% lss 10 set ss=0%ss%
  if %hh% == 0 set %~1=%mm%:%ss%& set %~1-units=mm:ss
  if %hh% gtr 0 set %~1=%hh%:%mm%:%ss%& set %~1-units=h:mm:ss
goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb-level
:: Note: numb-level range 0-5
  @call :funcbegin %0 "%~1"
  rem reset info vars
  for /L %%v in (1,1,5) Do set info%%v=
  rem set info levels from input
  for /L %%v in (1,1,5) Do if "%~1" geq "%%v" set info%%v=on
  @if defined info3 echo.
  if defined info3 FOR /F %%i IN ('set info') DO echo Info: %%i
  if "%~1" geq "3" set clfeedback=on
  set funcstarttext={---
  set funcendtext=       ----}
  @call :funcend %0
goto :eof


:start
:: Description: Start a program but don't wait for it.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8
  echo.
  rem check availability
  set p1val=0
  set curcommand="%p1%" "%p2%" "%p3%" %p4% %p5% %p6% %p7% %p8%
  if not defined p1 if not exist "%p2%" call :funcend %0 "Error: valid file not found to start!" & goto :eof
  rem if defined p1 if defined p2 if not exist "%p2%" call :funcend %0 "Error: valid file2 not found to start!" & goto :eof
  if exist "%p1%" echo %cyan%start "" %curcommand%%reset% & start "" %curcommand%
  if not exist "%p1%" echo %cyan%start %curcommand%%reset% & start %curcommand%
  rem if "%p1%" neq "%p1: =%" echo start "" %curcommand% & start%curcommand%
  @call :funcend %0
goto :eof

:starturl
:: Description: Start a program but don't wait for it.
  @call :funcbegin %0 "%~1 %~2 %~3 %~4 %~5"
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8
  echo.
  rem check availability
  set curcommand=%p1% %p2% %p3% %p4% %p5% %p6% %p7% %p8%
  rem run the command
  echo %cyan%start /b %curcommand%%reset%
  start /b %curcommand%
  @call :funcend %0
goto :eof

:taskcall
:: Description: Loop that triggers each taskgroup.
:: Usage: call :taskcall group
:: Depends on: unittestaccumulate. Can depend on any procedure in the input task group.
@echo off
  @if defined fatal if defined info4 echo %funcendtext% %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined fatal goto :eof
  @call :funcbegin %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set group=%~1
  rem Do not remove these tgvarX variables some sub groups rely on them
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set param7=%~7
  set param8=%~8
  set param9=%~9
  call :multivarlist 2 9
  set taskend=!%~1count!
  call :%group:"=% %multivar:'="%
  @call :funcend %0 %~1
goto :eof

:tidy
:: Description: Convert HTML to XHTML
:: Usage: call :tidy ["infile"] ["outfile"] [outspec(default=asxml)] [encoding(default=utf8)]
:: Depends on: infile, outfile, inccount, funcend
:: External program: tidy.exe http://tidy.sourceforge.net/
:: Required variables: tidy
  @call :funcbegin %0 "'%~1' '%~2'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%coun%-html-tidy.html"
  call :inccount
  set outspec=%~3
  set encoding=%~4
  if not defined outspec set outspec=-asxml
  if not defined encoding set encoding=-utf8
  set curcommand="%tidy%" %outspec% %encoding% -q -o "%outfile%" "%infile%"
  if defined info2 echo %curcommand%
  call %curcommand% > tidy-report.txt
  @call :funcendtest %0
goto :eof

:time
:: Description: Retrieve time in several shorter formats than %time% provides
:: Optional variables: timeseparator
:: Usage: call :time
:: Created: 2016-05-05
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  FOR /F "tokens=1-4 delims=:%timeseparator%." %%A IN ("%time%") DO (
    set chh=0%%A
    set cmm=%%B
    set css=%%C
  )
  set hh=%chh:~-2%
  set curhhmm=%hh%%cmm%
  set curhhmmss=%hh%%cmm%%css%
  set curisohhmmss=%hh%-%cmm%-%css%
  set curhh_mm=%hh%:%cmm%
  set curhh_mm_ss=%hh%:%cmm%:%css%
  @call :funcend %0
goto :eof

:time2sec
:: Description: convert the current time to seconds
set varname=%~1
for /F "tokens=1-3 delims=:.," %%a in ("%TIME%") do (
	set /A "%varname%=(%%a*60+1%%b-100)*60+(1%%c-100)
)
goto :eof

:tsv2xml-njs
:: Description: Convert TSV to XML via NodeJS 
:: Usage: call :tsv2xml inputfile outputfile
:: Created: 2023-05-03
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1"
  call :outfile "%~2" "%projectpath%\tmp\%group%-%coun%-tsv2xml.xml"
  set cmdline=parsjs -d tab -o xml -s "%outfile%" "%infile%"
  if defined info2 echo %cyan%%cmdline%%reset%
  call %cmdline% > nul
  set outfile=%outfile%.xml
  @call :funcendtest %0
goto :eof

:tsv2xml
:: Description: use CCT to create xml from TSV
:: Usage: call :tsv3xmlcct tsvinfile xmloutfile
:: Created: 2023-08-13
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :cct tsv2xml-v2.cct "%~1" "%~2"
  @call :funcend %0
goto :eof

:tsv2multixml
:: Description: Convert TSV to XML via NodeJS 
:: Usage: call :tsv2xml inputpath inputfiles outputfile
:: Created: 2023-07-11
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  set wkpath=%~1
  set input=%~2
  call :outfile "%~3" "%projectpath%\tmp\%group%-%coun%-%0.xml"
  set inputs=%input:'="%
  set cmdline=tsv2xml %inputs% ^> "%outfile%"
  if defined info2 echo %cyan%%cmdline% ^> "%outfile%"%reset%
  pushd "%wkpath%"
  call %cmdline% > "%outfile%
  popd
  @call :funcendtest %0
goto :eof

:csv2tsv
:: Description: Convert TSV to XML via NodeJS 
:: Usage: call :csv2tsv inputfile outputfile
:: Created: 2023-05-03
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1"
  call :outfile "%~2" "%projectpath%\tmp\%group%-%coun%-%0.tsv"
  set cmdline=%csvtk% csv2tab "%infile%" 
  @echo %cyan%%cmdline% ^> "%outfile%" %reset%
  call %cmdline% > "%outfile%"
  @call :funcendtest %0
goto :eof

:csv2xml
:: Description: Convert TSV to XML via NodeJS 
:: Usage: call :csv2xml inputfile outputfile
:: Created: 2023-05-03
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  call :infile "%~1"
  call :outfile "%~2" "%projectpath%\tmp\%group%-%coun%-%0.xml"
  set cmdline=parsjs -d comma -o xml -s "%outfile%" "%infile%"
  echo %cyan%%cmdline%%reset%
  call %cmdline% > nul
  set outfile=%outfile%.xml
  @call :funcendtest %0
goto :eof


:unicodecount
:: Description: Count unicode characters in file
:: Usage: t=:unicodecount "infile" "outfile"
:: Functions called: External program UnicodeCCount.exe from https://scripts.sil.org/cms/scripts/page.php?item_id=UnicodeCharacterCount
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%count%-unicodecount.txt"
  call :drivepath "%outfile%""
  if not exist "%unicodecharcount%" call :fatal "Unicode Character count executable not found or not defined in xrun.ini"
  call "%unicodecharcount%" -o "%outfile%" "%infile%" 2> "%drivepath%\unicodecount-errors.txt"
  @call :funcendtest %0
goto :eof

:uniqcount
:: Description: Create a sorted ist that is then reduced to a Uniq list
:: Usage: t=:uniqcount infile outfile
:: Purpose: process file
:: Programs used: sort.exe from C:\Windows\System32\, uniq.exe from http://unixutils.sourceforge.net/
:: Functions called: funcbegin funcendtest infile outfile
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%count%-sorted-list.txt"
  set nocount=%~3
  set countuniq=-c
  if defined nocount set countuniq=
  if defined info2 echo.
  if defined info2 echo %cyan%C:\Windows\System32\sort.exe "%infile%" /O "%projectpath%\tmp\tmp1.txt"%reset%
  call C:\Windows\System32\sort.exe "%infile%" /O "%projectpath%\tmp\tmp1.txt"
  if defined info2 echo.
  if defined info2 echo %cyan%%uniq% %countuniq% "%projectpath%\tmp\tmp1.txt" "%outfile%"%reset%
  call %uniq% %countuniq% "%projectpath%\tmp\tmp1.txt" "%outfile%"
  @call :funcendtest %0
goto :eof
goto :eof

:updateif
:: Description: if a file exists move it and run an update
:: Usage: call :updateif testfile copytofile funcion funcoutfile
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  set testfile=%~1
  set copytofile=%~2
  set func=%~3
  set funcoutfile=%~4
  if exist "%testfile%" (
      move "%testfile%" "%copytofile%"
      @if defined info2 @echo %green%Info: Copied %yellow%%~nx1 %green%to %~nx2%reset%
      call :%func% "%copytofile%" "%funcoutfile%"
    ) else (
        @if defined info2 @echo %green%Info: File %yellow%%~nx1 %green%not found to move%reset%
    )
  @call :funcend %0
goto :eof

:update
:: Description: if a file exists move it and run an update
:: Usage: call :updateif testfile copytofile funcion funcoutfile
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :infile "%~1"
  set outfile=%~2
  xcopy /D /Y "%infile%" "%outfile%"
  @call :funcend %0
goto :eof

:validate
:: Description: Validate an XML file
:: Usage: call :validate "xmlfile"
:: Depends on: External program 'xml.exe' from  XMLstarlet http://xmlstar.sourceforge.net/
  set xmlfile=%~1
  set isxml=%outfile:~-3%
  if not defined xmlfile if "%isxml%" == "xml" set xmlfile=%outfile%
  if not defined xmlfile call :funcend %0 "xml file parameter missing" & goto :eof
  if not exist "%xmlfile%" call :funcend %0 "XML file not found" & goto :eof
  echo Info: Validating xml
  call "%xml%" val -e -b "%xmlfile%"
goto :eof

:validaterng
:: Description: Validate XML file against RNG schema
:: Usage: Call :validaterng "rngschema" "xmlfile"
:: Depends on: External Program jing.jar from https://relaxng.org/jclark/jing.html downloaded from: https://jar-download.com/download-handling.php
  set schema=%~1
  call :infile %~2 %0
  set checkspath=%projectpath%\checks
  if not exist "%schema%" call :fatal %0 "Missing rng schema file to validate against!"
  if not exist "%infile%" call :fatal %0 "Missing xml file to validate!"
  if not exist "%jing%" call :fatal %0 "Missing xml file to validate!"
  if not exist "%checkspath%\" md "%checkspath%"
  set commandline=java -jar "%jing%" "%schema%" "%infile%"
  @if defined info2 echo %commandline%
  call %commandline% > "%checkspath%\rng-schema-rpt.txt"
  more "%checkspath%\rng-schema-rpt.txt"
  pause
goto :eof

:var
:: Description: Set a variable within a taskgroup
:: Usage: t=:var varname "varvalue"
  @call :funcbegin %0 "'%~1' '%~2'"
  set vname=%~1
  set value=%~2
  if not defined vname call :funcend %0 "Name value missing. Var not set."& goto :eof
  rem no longer needed call :v2 retval "%value%"
  set %vname%=%value%
  @call :funcend %0
goto :eof

:wait
:: Description: delay for x number of seconds
:: Usage: call wait seconds_to_wait
  timeout /t %~1 /nobreak
goto :eof

:xquery
:: Description: Provides interface to xquery by saxon9he.jar
:: Usage: call :xquery scriptname ["infile"] ["outfile"] [allparam]
:: Depends on: inccount, infile, outfile, funcend, fatal
:: External program: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: Required variables: java saxon9
:: created: 2018-11-27
  @call :funcbegin %0 "'%~1' '%~2'"
  call :inccount
  set scriptname=%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%scriptname%.xml"
  set allparam=%~4
  set script=%projectpath%\scripts\%scriptname%
  if not exist "%script%" call :fatal %0 "Missing xquery script!"
  if defined allparam set param=%allparam:'="%
  set curcommand="%java%" -jar "%saxon%" net.sf.saxon.Query "%script%" -o:"%outfile%" -s:"%infile%" %param%
  if defined info2 echo %curcommand%
  call %curcommand%
  @call :funcendtest %0
goto :eof

:xslt
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program1: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: External program2: Node-JS   https://nodejs.org/en/
:: Node application: XSLT3 https://www.saxonica.com/download/javascript.xml
:: Required variables: java saxon9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  if not defined xsltsetup (
    call :makemake "%projectpath%\projxslt.make" 
    call :runmake "%projectpath%\projxslt.make"
    set xsltsetup=done
  )
  rem if not exist "%scripts%\project.xslt" call :fatal %0 "project.xslt not created" & call :funcend %0 & goto :eof
  call :inccount
  set script=%~1
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  rem echo on
  set params=%~4
  if defined suppressXsltNamespace set suppressXsltNamespaceCheck=--suppressXsltNamespaceCheck on
  if not defined xslt set xslt=xslt2
  if not exist "%script%" call :scriptfind "%script%" %0
  if not exist "%script%" call :fatal %0 "The Script %script% is missing" & goto :eof
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  if defined fatal goto :eof
  if "%xslt%" == "xslt1" (
    @if defined info2 echo %cyan%%xml% tr "%script%" "%infile%" ^> "%outfile%"%reset%
    call "%xml%" tr "%script%" "%infile%" > "%outfile%" 
  )  
  if "%xslt%" == "xslt1ms" (
    @if defined info2 echo %cyan%%xml% tr "%script%" "%infile%" ^> "%outfile%"%reset%
    call "%msxsl%" "%infile%" "%script%" -o "%outfile%" 
  ) 
  if "%xslt%" == "xslt2" (
    @if defined info2 echo %cyan%%java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%%reset%
    %java% -Xmx1024m  %suppressXsltNamespaceCheck% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  )
  if "%xslt%" == "xslt3" (
    @if defined info2 echo %cyan%xslt3 -xsl:"%script%" -s:"%infile%" -o:"%outfile%" %params%%reset%
    call :xslt3 -xsl:"%script%" -s:"%infile%" -o:"%outfile%" %params%
  ) 
  @call :funcendtest %0
goto :eof

:xslt1
:: Description: Runs Java with xmlScarlet to process XSLT1 transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: Required variables: java saxon9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml"
  set params=%~4
  if defined params set params= -s %params%
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo %cyan%%xml% tr "%script%" "%infile%"%params% ^> "%outfile%"%reset%
  call "%xml%" tr "%script%" "%infile%"%params% > "%outfile%"   
  @call :funcendtest %0
goto :eof

:xslt3
:: Description: Runs Java with saxon-js to process XSLT transformations.
:: Usage: call :xslt3 script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: Required variables: java saxon9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :make "%projectpath%" "projxslt.make"
  if not exist "%scripts%\project.xslt" call :fatal %0 "project.xslt not created" & call :funcend %0 & goto :eof
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  set params=%~4
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo.
  @if defined info2 echo xslt3 -xsl:"%script%" -s:"%infile%" -o:"%outfile%" %params%
  call xslt3 -o:"%outfile%" -s:"%infile%" -xsl:"%script%" %params%  
  @call :funcendtest %0
goto :eof

:xsltms
:: Description: Runs MSxml to process XSLT1 transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: Required variables: java saxon9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml"
  set params=%~4
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo.
  @if defined info2 echo %cyan%"%msxsl%" "%script%" "%infile%" -o "%outfile%"%reset%
  call "%msxsl%" "%infile%" "%script%" -o "%outfile%"   
  @call :funcendtest %0
goto :eof

:xsltnons
:: Description: Runs Java with saxon to process XSLT transformations.
:: Usage: call :xslt script.xslt [input.xml [output.xml [parameters]]]
:: Depends on: inccount, infile, outfile, fatal, funcend
:: External program: java.exe https://www.oracle.com/technetwork/java/javase/downloads/jre8-downloads-2133155.html
:: Java application: saxon9he.jar  https://sourceforge.net/projects/saxon/
:: Required variables: java saxon9
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  set params=%~4
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo.
  @if defined info2 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
  %java% -Xmx1024m --suppressXsltNamespaceCheck:on -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%  
  @call :funcendtest %0
goto :eof

:runmake
:: Description: This runs the makefile script for checking if the project.xslt is up to date
:: Usage: call :runmake makefile-path-filename
:: Required variables: make 
  rem @if defined info2 echo %green%Info: Checking if project.xslt is up to date.%cyan%
  @call :funcbegin %0 "'%~1'"
  set makepath=%~dp1
  set makefile=%~nx1
  pushd "%makepath%"
  call %make% -f %makefile%
  popd
  @call :funcend %0
goto :eof

:zzz
:: Description: Use 7zip to build zip an epub file.
:: Usage: call :epubzip epubfilelocation epubname
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  setlocal DISABLEDELAYEDEXPANSION
  xcopy /D "%cd%\setup\epubzip.make" "%projectpath%"
  call :makef "%projectpath%\epubzip.make"
  set hostpath=%1
  set epubname=%2
  set hostpath=%hostpath:"=%
  set epubname=%epubname:"=%
  set errorlevel=
  call :outfile "%hostpath%\%epubname%.epub"
  @if defined info2 echo %green%Starting 7zip 3 times to create %epubname%.epub%reset%
  pushd "%hostpath%\%epubname%"
  "C:\Program Files\7-Zip\7z.exe" a -t* ..\%epubname%.epub ..\!mimetype 1> nul 2> 7zip-errors.txt
  call :errortest 0 "Added !mimtype to zip" "Error adding !mimtype to zip"
  rem if %errorlevel%. neq 0. echo %redbg%  %reset%
  "C:\Program Files\7-Zip\7z.exe" u -tzip ..\%epubname%.epub @..\ziplist.txt 1> nul 2> 7zip-errors.txt
  call :errortest 0 "Added content to zip" "Error adding content to zip"
  rem if %errorlevel%. neq 0. echo %redbg% Error adding content to zip %reset%
  "C:\Program Files\7-Zip\7z.exe" rn ..\%epubname%.epub !mimetype mimetype 1> nul 2> 7zip-errors.txt
  call :errortest 0 "Renamed file !mimetype to mimetype in zip" "Error renaming file !mimetype to mimetype in zip"
  rem if %errorlevel%. neq 0. echo %redbg%Error renaming file !mimetype to mimetype %reset%
  popd
  set errorlevel=
  SETLOCAL ENABLEDELAYEDEXPANSION
  @call :funcendtest %0
goto :eof

:errortest
  set wantedresult=%~1
  set goodmessage=%~2
  set failmessage=%3
  if %errorlevel%. neq %wantedresult%. (
      echo %redbg%%failmessage% %reset%
  ) else (
      @if defined info3 echo %green%%goodmessage% %reset%
  )
goto :eof

