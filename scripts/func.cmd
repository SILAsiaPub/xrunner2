:ampmhour
:: Description: Converts AM/PM time to 24hour format. 
:: Usage: call :ampmhour ampm thh
:: Created: 2016-05-04 
:: Used by: getfiledatetime 

if defined debugdefinefunc echo %beginfuncstring% %0 %debugstack% %beginfuncstringtail%
set ampm=%~1
set thh=%~2
if "%ampm%" == "AM" (
  if "%thh%" == "12" (
    set fhh=00
  ) else (
    set fhh=%thh%
  )
) else if "%ampm%" == "PM" (
  if "%thh%" == "12" (
    set fhh=12
  ) else (
    rem added handling to prevent octal number error caused by leading zero
    set fhh=%thh: =0%
  )
) else  (
  set fhh=%thh%
)
if defined debugdefinefunc echo %endfuncstring% %0 %debugstack%
goto :eof

:appendfile
:: Description: Appends one file to the end of another file.
:: Usage: call : appendfile filetoadd filetoappendto
:: Depends on: funcbegin funcend 
  if defined fatal goto :eof
  rem echo on
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if not exist "%~2" copy nul "%~2"
  if not exist "%~1" echo Warning: File to append does not exist. File: %~1  & pause & @call :funcend %0 & goto :eof
  if exist "%~1" type "%~1" >> "%~2"
  rem @if defined unittest set utreturn=%~1, %~2
  rem echo off
  @call :funcend %0
goto :eof

:appendtofile
:: Description: Appends text to the end of a file.
:: Usage: call : appendtofile text-to-append filetoappendto first
:: Depends on: funcbegin funcend outfile
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

:appendnumbparam
:: Description: Append numbered parameters on the end of a given variable name. Used from a loop like :loopfiles.
:: Usage: call :appendnumbparam prepart-of-par-name seed-numb out_var_name
  set outvar=%~1
  set parpre=%~2
  set numb=%~3
  set calcnumb=%~4
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%numb%%calcnumb%
  if not defined outvar echo Error: no var name defined at par3.& echo %funcendtext% %0  & goto :eof
  if defined %parpre%%numb% set appendparam=%appendparam% "!%parpre%%newnumb%!"
  set %outvar%=%appendparam%
goto :eof

:autoit
:: Description: Pass a script and variables to autoit.
::Usage: call :autoit script.au3 infile outfile parm1 etc
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount %count%
  set script=%~1
  if not defined script call :fatal %0 "Autoit script not supplied!" & goto :eof
  if not exist "%scripts%\%script%" call :scriptfind "%script%" %0
  set parm1=%~2
  if not exist "%autoit%" call :fatal %0 "missing autoit3.exe executable file" & goto :eof
  set parm2=%~3
  if defined fatal goto :eof
  set curcommand="%autoit%" "%script%" "%parm1%" "%parm2%"
  @if defined info2 echo call %curcommand%
  pushd "%scripts%"
  call %curcommand%
  popd
  @if defined unittest set utreturn=%ccw32%, %cctparam%, %script%, %infile%, %outfile%
  @call :funcend %0
goto :eof

:calc
:: Description: Calculate an number and return in a variable.
:: Usage: call :calc varname numbcalcstring
  @call :funcbegin %0 "'%~1' '%~2'"
  set /A numb=%~2
  echo calculated number = %numb%
  set %~1=%numb%
  @call :funcend %0
goto :eof

:calcnumbparam
:: Description: Append numbered parameters on the end of a predefined %preaddnumbparam% string
:: Usage: call :calcnumbparam prepart-of-par-name seed-numb [value-to-add-or-subtract]
:: Note: Default value to add or subtract is -0
  set calcnumb=%~3
  if not defined calcnumb set calcnumb=+0
  set /A newnumb=%~2%calcnumb%
  if defined val%~2 set preaddnumbparam=%preaddnumbparam% "!%~1%newnumb%!"
goto :eof

:cct
:: Description: Privides interface to CCW32.
:: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile, funcend
:: External program: ccw32.exe https://software.sil.org/cc/
:: Required variable: ccw32
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount %count%
  set script=%~1
  if not defined script call :fatal %0 "CCT script not supplied!" & goto :eof
  rem if not exist "%scripts%\%script%" call :fatal %0 "CCT script not found!  %scripts%\%script%" & goto :eof
  if not exist "%scripts%\%script%" call :scriptfind "%script%" %0
  call :infile "%~2" %0
  if defined missinginput  call :fatal %0 "infile not found!" & goto :eof
  set cctparam=-u -b -q -n
  if not exist "%ccw32%" call :fatal %0 "missing ccw32.exe file" & goto :eof
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%scriptout%.xml"
  call :checkdir "%outfile%"
  if defined fatal goto :eof
  set curcommand="%ccw32%" %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  @if defined info2 echo %curcommand%

  pushd "%scripts%"
  call %curcommand%
  popd
  @if defined unittest set utreturn=%ccw32%, %cctparam%, %script%, %infile%, %outfile%
  @call :funcendtest %0
goto :eof

:ccta
:: Description: Privides interface to CCW32.
:: Usage: call :cct script.cct ["infile.txt" ["outfile.txt"]]
:: Depends on: inccount, infile, outfile, funcend
:: External program: ccw32.exe https://software.sil.org/cc/
:: Required variable: ccw32
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount %count%
  set script=%~1
  if not defined script call :fatal %0 "CCT script not supplied!" & goto :eof
  if not exist "%scripts%\%script%" call :fatal %0 "CCT script not found!  %scripts%\%script%" & goto :eof
  call :infile "%~2" %0
  if defined missinginput  call :fatal %0 "infile not found!" & goto :eof
  set cctparam=-u -b -q -n
  if defined append set cctparam=-u -b -n -a
  if not exist "%ccw32%" call :fatal %0 "missing ccw32.exe file" & goto :eof
  set scriptout=%script:.cct,=_%
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%scriptout%.xml"
  if defined fatal goto :eof
  set curcommand="%ccw32%" -a %cctparam% -t "%script%" -o "%outfile%" "%infile%"
  @if defined info2 echo. & echo %curcommand%
  pushd "%scripts%"
  call %curcommand%
  popd
  @if defined unittest set utreturn=%ccw32%, %cctparam%, %script%, %infile%, %outfile%
  @call :funcendtest %0
goto :eof

:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set checkpath=%~1
  if not defined checkpath echo missing required directory parameter for :checkdir& echo. %funcendtext% %0  & goto :eof
  set ext=%~x1
  if defined ext set checkpath=%~dp1
  if defined ext set checkpath=%checkpath:~0,-1%
  if exist "%checkpath%" if defined info3 echo Info: found path %checkpath%
  if not exist "%checkpath%" if defined info3 echo Info: creating path %checkpath%
  if not exist "%checkpath%" mkdir "%checkpath%"
  @if defined unittest set utreturn=%checkpath%
  @call :funcend %0
goto :eof

:command
:: Description: A way of passing any commnand from a tasklist. It does not use infile and outfile.
:: Usage: call :usercommand "copy /y 'c:\patha\file.txt' 'c:\pathb\file.txt'" ["path to run  command in"   "output file to test for"]
:: Depends on: inccount, checkdir, funcend or any function
:: External program: May use any external program
:: Note: Single quotes get converted to double quotes before the command is used.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  set curcommand=%~1
  set commandpath=%~2
  set outfile=%~3
  if defined outfile call :checkdir "%outfile%"
  set basepath=%cd%
  if exist "%outfile%" copy /y "%outfile%" "%outfile%.prev"
  if exist "%outfile%" del "%outfile%"
  if not defined curcommand (
    echo missing curcommand 
    goto :eof
    )
  set curcommand=%curcommand:'="%
  if defined commandpath (
    if not exist "%commandpath%" mkdir "%commandpath%"
    )
  if defined commandpath pushd "%commandpath%"
  if defined commandpath if defined info3 echo current path: %cd%
  @if defined info2 echo %curcommand%
  call %curcommand%
  if defined commandpath popd
  @if defined unittest set utreturn=%curcommand%, %commandpath%, %outfile%
  @if defined outfile @call :funcendtest %0
goto :eof

:command2file
:: Description: Used with commands that only give stdout, so they can be captued in a file.
:: Usage: call :command2file "command" "outfile" ["commandpath"]
:: Depends on: inccount, outfile, funcend or any function
:: External program: May call any external program
:: Note: This command does its own expansion of single quotes to double quotes so cannont be fed directly from a ifdefined or ifnotdefined. Instead define a task that is fired by the ifdefined.
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  call :inccount
  set command=%~1
  set out=%~2
  if not defined command (
    echo Info: missing command
    if defined info4 echo %funcendtext% %0 
    goto :eof
    )
  call :outfile "%out%" "%projectpath%\xml\%group%-%count%--command2file.xml"
  set commandpath=%~3
  set append=%~4
  if not defined append if "%commandpath%" == "append" set append=on
  set curcommand=%command:'="%
  if defined commandpath pushd "%commandpath%"
  if not defined append (
    @if defined info2 echo %curcommand% ^>  "%outfile%"
    call %curcommand% > "%outfile%"
  ) else (
    @if defined info2 echo %curcommand% ^>^>  "%outfile%"
    call %curcommand% >> "%outfile%"
  )
  if defined commandpath popd
  @if defined unittest set utreturn=%command%, %outfile%, %projectpath%\xml\%group%-%count%-%~1-command2file.xml
  @call :funcendtest %0 
goto :eof


:command2var
:: Description: creates a variable from the command line
:: Usage: call :command2var varname "command" "comment"
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set commandline=%~1
  set varname=%~2
  if not defined varname echo missing varname parameter
  if not defined varname if defined info4 echo %funcendtext% %0
  if not defined varname goto :eof
  if not defined commandline echo missing list parameter
  if not defined commandline if defined info4 echo %funcendtext% %0 
  if not defined commandline goto :eof
  set commandline=%commandline:'="%
  if defined comment echo %comment%
  @if defined unittest set utreturn=%commandline%, %varname%
  FOR /F "delims=#" %%s IN ('%commandline%') DO set %varname%=%%s & set utreturn=%utreturn%, %%s
  set commandline=
  set comment=
  @call :funcend %0
goto :eof

:copy
:: Description: Provides copying with exit on failure
:: Usage: call :copy infile outfile [append] [xcopy]
:: Depends on: :infile, :outfile, :inccount :funcend
:: Uddated: 2018-11-03
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :name "%infile%"
  call :outfile "%~2" "%projectpath%\output\copy-%name%.%fext%"
  set fn1=%~nx1
  set fn2=%~nx2
  set appendfile=%~3
  set xcopy=%~4
  if defined missinginput echo missing input file & goto :eof
  call :inccount
  if defined appendfile set curcommand=copy /y "%outfile%"+"%infile%" "%outfile%" 
  if not defined appendfile  set curcommand=copy /y "%infile%" "%outfile%"
  if defined xcopy set curcommand=xcopy /y/s "%infile%" "%outfile%"
  if defined xcopy if "%fn1%" == "%fn2%" set curcommand=xcopy /y/s "%infile%" "%outpath%"
  %curcommand% > nul
  @call :funcendtest %0
goto :eof

:file
:: Description: Provides copying with exit on failure
:: Usage: call :copy append|xcopy|move|del infile outfile
:: Depends on: :infile, :outfile, :inccount :funcend
:: Uddated: 2018-11-03
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~2" %0
  call :outfile "%~3" "%~dpn2-copy%~x2"
  set fn1=%~nx2
  set fn2=%~nx3
  set action=%~1
  if not defined action echo missing parm 3 append|xcopy|move|copy & goto :eof
  if defined missinginput echo missing input file & goto :eof
  call :inccount
  rem echo on
  if "%action%" == "append" set curcommand=copy /y "%outfile%"+"%infile%" "%outfile%" 
  if "%action%" == "copy" set curcommand=copy /y "%infile%" "%outfile%"
  if "%action%" == "xcopy"  set curcommand=xcopy /i/y/s "%infile%" "%outfile%"
  if "%action%" == "move"  set curcommand=move /y "%infile%" "%outfile%"
rem  if "%action%" == "del"  if exist "%infile%" del /q "%infile%" & @call :funcend %0 & goto :eof
  %curcommand%
  rem echo off
  @call :funcendtest %0
goto :eof

:copy2usb
:: Description: Set up to cop files to USB drive and optionally format.
:: Usage: call :copy2usb source_path target_drive target_folder [format_first]
:: Depends on: external program xcopy (a part of Windows)
  @call :funcbegin %0 "'%~1' '%~2' '%~3' %~4"
  set sourcepath=%~1
  set targetdrive=%~2
  set targetpath=%~3
  set format=%~4
  set volumename=%~5
  set protecteddrives=a b c d e l p s t
  if not exist %targetdrive%:\ echo Drive %targetdrive%: not available! & goto :eof
  if "%protecteddrives%" neq "!protecteddrives:%targetdrive%=!" echo System drive! Abort! & goto :eof
  if defined format FORMAT %targetdrive%: /V:%volumename% /Q /X /Y
  echo Copying %targetdrive%:\%targetpath%
  XCOPY /V /I /Q /G /Y /J "%sourcepath%" "%targetdrive%:\%targetpath%"
  EjectMedia %targetdrive%:
  if "%errorlevel%" neq "0" pause
  @call :funcend %0
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Depends on: detectdateformat
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
  @call :funcbegin %0 "'%~1'"
  set /A %~1-=1
  @if defined unittest set utreturn=!%~1!
  @call :funcend %0
goto :eof

:delfile
:: Description: Delete a file if it exists
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
  @if defined unittest set utreturn=%drivepath%
  @call :funcend %0
goto :eof

:dummy
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
call :time2sec cursec
set /A elapsed=%cursec%-%starttime%
echo Info: Elapsed seconds: %elapsed%
goto :eof

:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file [validate-against]
:: Depends on: :infile
:: External program: file.exe http://gnuwin32.sourceforge.net/
:: Required variables: encodingchecker
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
rem if not defined encodingchecker echo Encoding not checked. Encoding Checker not defined. & echo %funcendtext% %0 error1 &goto :eof
if not exist "%encodingchecker%" echo file.exe not found! %fileext% &echo Encoding not checked. & echo %funcendtext% %0 error2 & goto :eof
set testfile=%~1
set validateagainst=%~2
call :infile "%testfile%"
set nameext=%~nx1
FOR /F "usebackq tokens=1-2" %%A IN (`%encodingchecker% --mime-encoding "%infile%"`) DO set fencoding=%%B
if defined validateagainst (
    if "%fencoding%" == "%validateagainst%"  ( echo Encoding check: %green%%nameext% is %fencoding% %reset% 
    ) else (
    if "%fencoding%" == "us-ascii" ( echo Encoding check: %green%%nameext% is %fencoding% -- OK. %reset% &  goto :eof  
      ) else (
        echo Encoding check:  %redbg%%nameext% is  %fencoding%! %reset% 
        echo %redbg% But it was expected to be: %validateagainst%. %reset%
        set errorsuspendprocessing=on
      )
      )
) else  (              
    echo Encoding is: %magentabg% %fencoding% %reset% for file %nameext%.
    pause
) 
  @if defined unittest set utreturn=%testfile%, %validateagainst%, %fencoding%, %nameext%
  @call :funcend %0
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
  pause
  @if defined unittest set utreturn=%message%
  set fatal=on
goto :eof

:fb
:: Description: Used to give common feed back
  echo %~1: %~2 >> log\log.txt
  if "%~1" == "info" Echo Info: %~2
  if "%~1" == "error" Echo Error: %~2
  if "%~1" == "output" Echo Output: %~2
goto :eof

:funcbegin
:: Descriptions: takes initialization out of funcs
  @set func=%~1
  @rem the following line removes the func colon at the begining. Not removing it causes a crash.
  @set funcname=%func:~1%
  @set fparams=%~2
  @if defined info3 echo %magentabg%%func%%reset% %fparams%
  @if defined info4 echo %funcstarttext% %func% %fparams%
  @if defined info4 @if defined %funcname%echo echo  ============== %funcname%echo is ON =============== & echo on
@goto :eof

:funcendtest
:: Description: Used with func that output files. Like XSLT, cct, command2file
:: Usage: call :funcend %0
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set functest=%~1
  set alttext=%~2
  if not defined alttext set alttext=Output:
  @if defined info1 if exist "%outfile%" echo %green%%alttext% %outfile% %reset%
  @if defined info1 if exist "%outfile%" set utret3=Output: %outfile%
  @if defined outfile if not exist "%outfile%" Echo %redbg%Task failed: Output file not created! %reset%
  @if defined outfile if not exist "%outfile%" set utret4=color 06
  @if defined outfile if exist "%outfile%" set utret4=
  @if not defined info4 set utret5=
  @if defined info4 set utret5=%funcendtext% %functest%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & if not defined unittest pause
  @if defined info2 if exist "%outfile%" echo.
  @if defined unittest set utreturn= %functest%, %info1%, %info4%, %utret3%, %utret4%, %utret5%
  @call :funcend  %0
@goto :eof

:funcend
:: Description: Used for non ouput file func
:: Usage: call :funcend %0
  @set func=%~1
  @if defined info4 echo %funcendtext% %func%
  @if defined %func:~1%pause pause
  @rem the following form of %func:~1% removes the colon from the begining of the func.
  @if defined !func:~1!show @echo off
  @if defined !func:~1!show echo ========= !func:~1!echo switched OFF =========
@goto :eof

:getfiledatetime
:: Description: Returns a variable with a files modification date and time in yyMMddhhmm  similar to setdatetime. Note 4 digit year makes comparison number too big for batch to handle.
:: Revised: 2016-05-04
:: Classs: command - internal - date -time
:: Required parameters: varname file
:: Depends on: :detectdateformat variables
@call :funcbegin %0 "'%~1' '%~2'"
if defined debugdefinefunc echo %beginfuncstring% %0 %debugstack% %beginfuncstringtail%
set varname=%~1
if not defined varname echo missing varname parameter & goto :eof
set file=%~2
if not exist "%file%" set %varname%=0 &goto :eof
set filedate=%~t2
rem got and mofified this from: http://www.robvanderwoude.com/datetiment.php#IDate
FOR /F "tokens=1-6 delims=%timeseparator%%dateseparator% " %%A IN ("%~t2") DO (
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
  call :ampmhour %%F %%D
)
echo  %varname%=%fyyyy:~2%%fMM%%fdd%%fhh: =0%%fnn%>> file-time.txt
set %varname%=%fyyyy:~2%%fMM%%fdd%%fhh: =0%%fnn%
if defined debugdefinefunc echo %endfuncstring% %0 %debugstack%
if defined info3 echo %green%%varname%=!%varname%!%reset%
  @call :funcend  %0
goto :eof

:iconv
:: Description: Converts files from CP1252 to UTF-8
:: Usage: call :iconv infile outfile OR call :iconv file_nx inpath outpath
:: Depends on: infile, outfile, funcend
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
  @if defined unittest set utreturn=%par1%, %par2%, %par3%, %projectpath%\tmp\iconv-%~nx1, 
  @call :funcendtest %0
goto :eof

:ifnotdefined
:: Description: Checks if true
:: Usage: call :ifnotdefined action par1 par 2 par3 par4
:: action note: the action can be a function or a taskgroup NOT a dos command
  set varname=%~1
  set action=%~2
  set par1=%~3
  set par2=%~4
  set par3=%~5
  set par4=%~6
  set firstact=%action:~0,1%
  if not defined %varname% (
    @if defined info2 echo Test: TRUE - variable %~1 is not defined
    if ~%firstact% neq ~: (
      @if defined info3 echo call :taskgroup %action%  "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%" 
      call :taskgroup %action% "%par1%" "%par2%" "%par3%" "%par4%" 
    ) else (
      @if defined info3 echo call %action% "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%"
      call %action% "%par1%" "%par2%" "%par3%" "%par4%"
    )
  ) else (
    @if defined info2 echo Test: FALSE - variable %~1 is defined
  )
goto :eof

:ifdefined
:: Description: Checks for value in variable
:: Usage: call :ifdefined variablename action
:: action note: the action can be a function or a taskgroup not a dos command
:: Depends on: 
  set varname=%~1
  set action=%~2
  set par1=%~3
  set par2=%~4
  set par3=%~5
  set par4=%~6
  set firstact=%action:~0,1%
  if defined %varname% (
    @if defined info2 echo Test: TRUE - variable %~1 is defined
    if ~%firstact% neq ~: (
      @if defined info3 echo call :taskgroup %action%  "%par1%" "%par2%" "%par3%" "%par4%" 
      call :taskgroup %action% "%par1%" "%par2%" "%par3%" "%par4%" 
    ) else (
      @if defined info3 echo call %action% "%par1%" "%par2%" "%par3%" "%par4%"
      call %action% "%par1%" "%par2%" "%par3%" "%par4%"
    )
  ) else (
    @if defined info2 echo Test: FALSE - variable %~1 is not defined
  )
goto :eof

:ifequal
:: action note: the action can be a function or a taskgroup not a dos command
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8'"
  set t1=%~1
  set t2=%~2
  set action=%~3
  set actpar1=%~4
  set actpar2=%~5
  set actpar3=%~6
  set actpar4=%~7
  set actpar5=%~8
  set actpar6=%~9
  set firstact=%action:~0,1%
  if "%t1%" == "%t2%" (
    @if defined info3 echo "%t1%" ==  "%t2%" are equal
    if ~%firstact% neq ~: (
      rem @if defined info3 echo call :taskgroup %action%  "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%" 
      call :taskgroup %action% "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%" 
    ) else (
      rem @if defined info3 echo call %action% "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%"
      call %action% "%actpar1%" "%actpar2%" "%actpar3%" "%actpar4%"
    )
  ) else (
    @if defined info3 echo "%t1%" ==  "%t2%" are NOT equal
  )
  @call :funcend %0
goto :eof

:ifnotequal
:: action note: the action can be a function or a taskgroup not a dos command
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set t1=%~1
  set t2=%~2
  set action=%~3
  set firstact=%action:~0,1%
  if ~%firstact% NEQ ~: (
    @if defined info3 echo if "%t1%" NEQ "%t2%" call :taskgroup %action% "%~4" "%~5" "%~6" "%~7"
    if "%t1%" NEQ "%t2%" call :taskgroup %action%  "%~4" "%~5" "%~6" "%~7"
  ) else (
    @if defined info3 echo if "%t1%" NEQ "%t2%" call %action%  "%~4" "%~5" "%~6" "%~7"
    if "%t1%" NEQ "%t2%" call %action%  "%~4" "%~5" "%~6" "%~7"
  )
  @call :funcend %0
goto :eof

:ifexist
:: Description: tests if a file exists
:: Usage: call :ifexist testfile action par*
:: action note: the action can be a dos command or call a xrun function or call a project taskgroup
:: Depends on: inccount funcbegin funcend
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set testfile=%~1
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  call :inccount
  if not defined testfile echo Error:  missing testfile parameter& echo %funcendtext% %0 error1 & goto :eof
  if not defined param2 echo Error: missing action param2& echo %funcendtext% %0 error2 & goto :eof
  rem set appendparam=
  rem set numbparam=
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparam param %%v
  for /L %%v in (2,1,6) Do if defined param%%v if "!param%%v!" neq "!param%%v: =!" set param%%v="!param%%v!"
  rem set actionfirstlet=%param2:~0,1%
  if exist "%testfile%" (
    if defined info3 echo Test: TRUE   %~nx1 does exist. Action: %param2% %~nx3 %~nx4 %~nx5 %~nx6
    %param2% %param3% %param4% %param5% %param6%     
  ) else (
    if defined info3 echo Test: FALSE  %~nx1 does not exist. Action: none.
  )
  @if defined unittest set utreturn=%testfile%, %param2%, %param3%, %param4%, %param5%, %param6%
  @call :funcend %0
goto :eof

:ifnotexist
:: Description: If a file or folder do not exist, then performs an action.
:: Usage: call :ifnotexist testfile action parm*
:: action note: the action can be a dos command or call a xrun function or call a project taskgroup
:: Depends on: inccount
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6'"
  set testfile=%~1
  set param2=%~2
  set param3=%~3
  set param4=%~4
  set param5=%~5
  set param6=%~6
  set filename=%~nx1
  call :inccount
  rem echo on
  if not defined testfile echo missing testfile parameter & echo %funcendtext% %0  & goto :eof
  if not defined param2 echo missing action param2 parameter & echo %funcendtext% %0  & goto :eof
  rem set appendparam=
  rem set numbparamine=
  rem set numbparam=
  rem for /L %%v in (3,1,9) Do call :appendnumbparam numbparamine param %%v
  for /L %%v in (2,1,6) Do if defined param%%v if "!param%%v!" neq "!param%%v: =!" set param%%v="!param%%v!"
  set action=%param2:'="%
  rem @if defined info3 echo if not exist "%filename%" %param2% %numbparamine%
  rem if not exist "%testfile%" %param2% %numbparamine%
  set firstact=%param2:~0,1%
  if not exist "%testfile%" (
    if defined info3 echo Test: TRUE   %testfile% does not exist. 
      if defined info4 echo %param2% %param3% %param4% %param5% %param6%
      %param2% %param3% %param4% %param5% %param6% 
  ) else (
    if defined info3 echo Test: FALSE   %filename% does exist. No action %param2% taken.
  )
  rem echo off
  @if defined unittest set utreturn=%testfile%, %action%, %param3%, %param4%, %param5%, %param6%
  @call :funcend %0

goto :eof

:inc
:: Description: Increase the number variable
:: Usage: call :inc varname
  @call :funcbegin %0 "'%~1'"
  set /A %~1+=1
  @if defined unittest set utreturn=!%~1!
  @call :funcend %0 !%~1!
goto :eof

:exit-prompt
:: Description: runs an exe file that brings up a prompt
exit-cmd.exe
if exist "%tmp%\yes" (set ans=exit & del /q /f "%tmp%\yes") else (set ans=echo.)
%ans%

goto :eof

:inccount
:: Description: Increments the count variable
:: Usage: call :inccount
  @call :funcbegin %0
  set /A count=%count%+1
  set writecount=%count%
  if %count% lss 10 set writecount=%space%%count%
  @if defined unittest set utreturn=%count%, %writecoun%
  @call :funcend %0
goto :eof

:infile
:: Description: If infile is specifically set then uses that else uses previous outfile.
:: Usage: call :infile "%file%" calling-func
:: Depends on: fatal
  @call :funcbegin %0 "'%~1' '%~2'"
  set infile=%~1
  set callingfunc=%~2
  @if not defined infile set infile=%outfile%
  @if exist "%infile%" set missinginput=
  @if not exist "%infile%" call :fatal %0 ":infile %~nx1 not found for %callingfunc%"
  @if defined info4 echo Info: infile = %infile%
  @if defined unittest set utreturn=%infile%
  @call :funcend %0
goto :eof

:ini2xslt2
:: Description: Convert ini file to xslt
:: Usage: call :ini2xslt file.ini output.xslt subfunc sectionexit
:: Depends on: inccount, infile, outfile.
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

:ini2xslt
:: Description: Convert ini file to xslt
:: Usage: call :ini2xslt file.ini output.xslt subfunc sectionexit
:: Depends on: inccount, infile, outfile.
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

:rexxini
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
  @if defined unittest set utreturn=%utreturn%, %line%
  @call :funcend %0
goto :eof


:iniparse4xslt
:: Description: Parse the = delimited data and write to xslt . Skips sections and can exit when
:: Usage: call :iniparse4xslt outfile section element att1name att1val att2name att2val
:: Depends on: inccount
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
  rem FOR /F "eol=] delims=`" %%q IN (%list%) DO set utreturn=!utreturn!, "%%q"
  set sectionstart=
  @if defined info2 echo Setup: tasks created from: %~nx1
  @if defined unittest set utreturn=%list%, %tasklinewrite%, !utreturn!
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
:: Depends on: inccount, infile, outfile, nameext, name, funcend 
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
  @if defined unittest set utreturn=%last%, %~1, %~2
goto :eof

:loopfolders
:: Description: Loops through all subfolders in a folder
:: Usage: call :loopdir grouporfunc basedir [param[3-9]]
:: Depends on: * - May be any function or project Taskgroup
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined loopdirecho echo on
  set grouporfunc=%~1
  set basedir=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set appendparam=
  set numbparam=
  if not defined grouporfunc echo Missing function or task-group parameter & goto :eof
  if not defined basedir echo Missing basedir parameter & goto :eof
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  for /L %%v in (3,1,9) Do call :last par %%v
  set grouporfunc=%grouporfunc:'="%
  if defined last echo %last%
  if "%grouporfunc:~0,1%" == ":" FOR /F " delims=" %%s IN ('dir /b /a:d "%basedir%"') DO call :%grouporfunc% "%%s" %numbparam%
  if "%grouporfunc:~0,1%" neq ":" FOR /F " delims=" %%s IN ('dir /b /a:d "%basedir%"') DO call :taskgroup %grouporfunc% "%%s" %numbparam%
  @call :funcend %0
  @if defined loopdirecho echo off
goto :eof

:loopfiles
:: Description: Used to loop through a subset of files specified by the filespec from a single directory
:: Usage: call :loopfiles sub_name file_specs [param[3-9]]
:: Depends on: appendnumbparam, last, taskgroup. Can also use any other function.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined loopfilesecho echo on
  if defined fatal goto :eof
  set grouporfunc=%~1
  set filespec=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set numbparam=
  set appendparam=
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
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info3 if defined numbparam set numbparam
  if defined info4 if defined comment echo %last%
  if not defined unittest (
    if "%grouporfunc:~0,1%" == ":" (
        FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n "%filespec%"') DO  call %grouporfunc% "%%s" %numbparam%
      ) else (
        FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n "%filespec%"') DO  call :taskgroup %grouporfunc% "%%s" %numbparam%
    )  
  )  
  @if defined unittest set utreturn= %filespec%, %sub%, %numbparam%, %last%
  if defined unittest FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO call :unittestaccumulate "%%s" %sub% %numbparam%
  @call :funcend %0
  @if defined loopfilesecho echo off
goto :eof

:looplist
:: Description: Used to loop through list supplied in a file
:: Usage: call :looplist sub_name list-file_specs [param[3-9]]
:: Depends on: appendnumbparam, last, taskgroup. Can also use any other function.
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  if defined fatal goto :eof
  set grouporfunc=%~1
  set listfile=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set numbparam=
  set appendparam=
  if not defined grouporfunc echo %error% Missing func parameter[2]%reset%
  if not defined grouporfunc if defined info4 echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined listfile echo %error% Missing list-file parameter[1]%reset%
  if not defined listfile if defined info4 echo %funcendtext% %0 
  if not defined listfile goto :eof
  if not exist "%listfile%" echo %error% Missing source: %listfile% %reset%
  if not exist "%listfile%" if defined info4 echo %funcendtext% %0 
  if not exist "%listfile%" goto :eof
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info3 set numbparam
  if defined info4 if defined comment echo %last%
  if not defined unittest (
    if "%grouporfunc:~0,1%" == ":" (
        FOR /F " delims=" %%s IN (%listfile%) DO  call %grouporfunc% "%%s" %numbparam%
      ) else (
        FOR /F " delims=" %%s IN (%listfile%) DO  call :taskgroup %grouporfunc% "%%s" %numbparam%
  )  
    )  
  )  
  @if defined unittest set utreturn= %filespec%, %sub%, %numbparam%, %last%
  if defined unittest FOR /F " delims=" %%s IN ('dir /b /a:-d /o:n %filespec%') DO call :unittestaccumulate "%%s" %sub% %numbparam%
  @call :funcend %0
goto :eof

:loopnumber
:: Description: Loops through a set of numbers.
:: Usage: call :loopnumber grouporfunc start stop
:: Depends on: taskgroup. Can also use any other function.
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
  if "%grouporfunc:~0,1%" neq ":" FOR /L %%s IN (%start%,%step%,%end%) DO call :taskgroup %grouporfunc% "%%s"
  @call :funcend %0
  rem @echo off
goto :eof

:loopstring
:: Description: Loops through a list supplied in a space separated string.
:: Usage: call :loopstring grouporfunc "string" [param[3-9]]
:: Depends on: appendnumbparam, last, taskgroup. Can also use any other function.
:: Note: action may have multiple parts
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if defined fatal goto :eof
  rem echo on
  set grouporfunc=%~1
  set string=%~2
  set par3=%~3
  set par4=%~4
  set par5=%~5
  set par6=%~6
  set par7=%~7
  set par8=%~8
  set par9=%~9
  set numbparam=
  set appendparam=
  if not defined grouporfunc echo Missing action parameter
  if not defined grouporfunc echo %funcendtext% %0 
  if not defined grouporfunc goto :eof
  if not defined string echo Missing string parameter
  if not defined string if defined info4 echo %funcendtext% %0 
  if not defined string goto :eof
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam par %%v 
  for /L %%v in (3,1,9) Do call :last par %%v
  if defined info3 set numbparam
  if defined info2 echo %last%
  if "%grouporfunc:~0,1%" == ":" FOR %%s IN (%string%) DO call %grouporfunc% "%%s" %numbparam%
  if "%grouporfunc:~0,1%" neq ":" FOR %%s IN (%string%) DO call :taskgroup %grouporfunc% "%%s" %numbparam%
  @call :funcend %0
  rem @echo off
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: :setup, :taskgroup and may use unittestaccumulate
  @if defined info4 echo {---- :main %~1
  set group=%~1
  call :time2sec starttime
  @echo Start Seconds: %starttime%
  @echo Xrunner Started: %time:~0,8%
  call :setup
  if defined fatal goto :eof
  if defined group set taskgroup=%group%
  @if defined unittest set utreturn=-,%group%,
  if not defined unittest for %%g in (%taskgroup%) do call :taskgroup %tasgroupprefix%%%g
  @if defined info2 echo Info: xrun finished!
  if defined espeak if defined info2 call "%espeak%" "x run finished"
  if defined unittest for %%g in (%taskgroup%) do call :unittestaccumulate t%%g
  @call :funcend :main
  rem if defined pauseatend call :exit-prompt
  @if %infolevel% == 4 echo on
  call :time2sec endtime
  set /A sec=%endtime%-%starttime%
  @echo Completed in %sec% seconds at %time:~0,8%
  rem call :sec2time elapsed %sec%
  @if %infolevel% == 4 @echo off
  if defined pauseatend pause
goto :eof

:mergevar
:: Description: Merge two numbered variable into one with a space between them
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4'"
  set pname=%~1
  set vname=%~2
  set v1=%~3
  set v2=%~4
  set %vname%=!%pname%%v1%!!%pname%%v2%!
  @if defined unittest set utreturn=!%vname%!
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
  @if defined info3 set nameext
  @call :funcend %0
goto :eof

:outfile
:: Description: If out file is specifically set then uses that else uses supplied name.
:: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck
:: Depends on: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set toutfile=%~1
  set outnx=%~nx1
  set defaultoutfile=%~2
  set defaultoutdp=%~dp2
  set defaultoutnx=%~nx2
  set outpath=%~dp1
  set outpath=%outpath:~-1%
  rem the folloing is to preserve wildcards in the outfile. Since *.* when using %~nx1 becomes . not *.*
  @if defined info4 set outnx
  @if defined info4 set defaultoutfile
  set nocheck=%~3
  rem now if toutfile is not defined then use default value
  if defined toutfile (set outfile=%toutfile%) else (set outfile=%defaultoutfile%)
  if not defined toutfile set outpath=%defaultoutdp%
  if not defined toutfile set outnx=%defaultoutnx%
  if not defined nocheck if not exist "%outpath%" md "%outpath%"
  rem remove %outfile%.prev if it exists. Works with wildcards
  if exist "%outfile%.prev" del "%outfile%.prev"
  rem if outfile exists then rename to file.ext.prev; this works with wild cards too now.
  if exist "%outfile%" ren "%outfile%" "%outnx%.prev"
  @if defined unittest set utreturn=%outfile%, %defaultoutfile%, %nocheck%, %outpath%, %outnx%
  if defined info4 set utreturn
  @if defined info4 echo.
  @if defined info4 echo Info: outfile = %outfile%
  @call :funcend %0
goto :eof

:outputfile
:: Description: Copies last out file to new name. Used to make a static name other tasklists can use.
:: Usage: :outputfile drive:\path\file.ext [start] [validate] [copy]
:: Depends on: checkdir, funcend, validate
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
  @if defined unittest set utreturn=%infile%, %outfile%, %var2%, %var3%
  @call :funcendtest %0 Renamed:
goto :eof

:paratextio
:: Description: Loops through a list of books and extracts USX files.
:: Usage: call :paratextio project "book_list" [outpath] [write] [usfm]
:: Depends on: ptbook
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
:: Depends on: inccount, infile, outfile, funcend
:: External program: ccw32.exe https://software.sil.org/cc/
:: Required variable: ccw32
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
  @if defined unittest set utreturn=%perl%, %script%, %infile%, %outfile%, %par1%
  @call :funcendtest %0
goto :eof

:prerender
:: Description: Prerenders HTML with JS into plain HTML
:: Usage: call :prerender url outpath
:: Depends on: inccount, infile, outfile, funcend
:: External program: chrome.exe 
:: Required variable: chrome outpath
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
:: Depends on: infile, outfile, funcend
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
  if defined infile2 set infile2="%infile2%"
  if defined infile3 set infile3="%infile3%"
  if defined infile4 set infile4="%infile4%"
  if defined infile5 set infile5="%infile5%"
  if defined infile6 set infile6="%infile6%"
  if defined infile7 set infile7="%infile7%"
  if defined css set css=-s "%css%"
  set curcommand=call "%prince%" %css% "%infile%" %infile2% %infile3% %infile4% %infile5% %infile6% %infile7% -o "%outfile%"
  @if defined info2 echo %curcommand%
  %curcommand%
  @if defined unittest set utreturn=%infile%, %outfile%, %css%, %prince%, %curcommand%
  @call :funcendtest %0
goto :eof

:ptbook
:: Description: Extract USX from Paratext
:: Usage: call :ptbook project book [outpath] [write] [usfm]
:: Depends on: outfile, funcend, ptbkno
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

:regex
:: Description: Run a regex on a file
:: Usage: call :regex find replace infile outfile
:: Depends on: inccount, infile, outfile, funcend
:: External program: rxrepl.exe  https://sites.google.com/site/regexreplace/
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :inccount
  if defined missinginput color 06& echo %funcendtext% %0  & goto :eof
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
  if defined missinginput color 06& echo %funcendtext% %0  & goto :eof
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

:rho
:: Description: Create xml from .rho file markup
:: Usage: call :rho infile outfile
:: Depends on: infile, outfile, funcend NodeJS NPM program Rho
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
  if defined info3 echo ????? Searching other projects for missing script: %nameext% ?????
  if exist "%cd%\scripts\generic-pool\%nameext%" (
    copy "%cd%\scripts\generic-pool\%nameext%" "%scripts%"
    ) else (
    FOR /F "" %%f IN ('dir /b /s %projecthome%\%nameext%') DO xcopy "%%f" "%scripts%" /d /y 
    )
  if not exist "%scripts%\%nameext%" call :fatal %funcname% "missing script: %nameext%"
  @call :funcend %0
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
  rem turn off echo for the remaining levels
  rem if  "%~1" LSS "5" echo off
  @if defined unittest set utreturn=%~1, %info1%, %info2%, %info4%, %info3%, %info5%, %funcstarttext%, %funcendtext%
  @call :funcend %0
goto :eof



:setup-xslt2
:: Description: Sets up the for using Java, Saxon and XSLT2
:: Usage: call :setup-xslt2 "%projectpath%\project.txt"
:: Depends on: variableslist, task2cmd
  @call :funcbegin %0 "'%~1'"
  if defined firstxslt goto :eof
  if defined detectjava call :javahometest
  if defined nojava set fatal=on & goto :eof
  if "%needsaxon%" == "true" if not exist "%saxon%" call :fatal %0 "Saxon9he.jar not found." "This program will exit now!"  & goto :eof
  if not exist "%scripts%\project.xslt" ( set newerthan=on)
  if exist "%scripts%\project.xslt" (
    call :newerthan "%projectpath%\project.txt" "%scripts%\project.xslt"
    call :newerthan "%projectpath%\lists.tsv" "%scripts%\project.xslt"
    call :newerthan "%projectpath%\keyvalue.tsv" "%scripts%\project.xslt"
  )
  if defined info 2 call :fb info "set newerthan = %newerthan%"
  set firstxslt=on
  rem call :ini2xslt "%cd%\setup\xrun.ini" "%cd%\scripts\xrun.xslt" iniparse4xslt setup
  rem copy /y "scripts\dummy-xrun.xslt" "%projectpath%\scripts" >> log.txt
  rem if not exist "%cd%\scripts\xrun.xslt" call :fatal %0 "xrun.xslt not created" & goto :eof
  rem if exist "%scripts%\project.xslt" del "%scripts%\project.xslt"
  @rem if defined info2 echo Info: Java:saxon parse project.txt
  rem call xslt3 -xsl:"scripts\variable2xslt-3.sef.json" -s:blank.xml  -o:"%scripts%\project.xslt"
 rem  if defined newerthan copy /y "%cd%\scripts\projectvariables-v2.xslt" "%projectpath%\scripts\"
  if defined newerthan call "%ccw32%" %cctparam%  -t "%cd%\scripts\proj-var.cct" -o "%projectpath%\tmp\proj-var.xml" "%projectpath%\project.txt"
  if defined newerthan call %java% -jar "%saxon%" -o:"%scripts%\project.xslt" "%projectpath%\tmp\proj-var.xml" "%cd%\scripts\projectvariables-v2.xslt" projectpath="%projectpath%" USERPROFILE=%USERPROFILE%
  if not exist "%scripts%\project.xslt" call :fatal %0 "project.xslt not created" & goto :eof
  if defined newerthan if exist "%scripts%\project.xslt" if defined info2 echo Built: project.xslt from: project.txt
  @rem the following sets the default script path but it can be overridden by a scripts= in the project.txt
  set scripts=%projectpath%\scripts
  if not exist "%scripts%\inc-lookup.xslt" copy "%cd%\scripts\inc-lookup.xslt" "%scripts%\inc-lookup.xslt"
  if not exist "%scripts%\inc-file2uri.xslt" copy "%cd%\scripts\inc-file2uri.xslt" "%scripts%\inc-file2uri.xslt"
  if not exist "%scripts%\inc-copy-anything.xslt" copy "%cd%\scripts\inc-copy-anything.xslt" "%scripts%\inc-copy-anything.xslt"
  rem call "%projectpath%\tmp\project.cmd"
  rem if defined model call :loopfiles "%model%\*.*" :modelcheck "%model%"
  @call :funcend %0
goto :eof

:newerthan
:: Description: Compares two files an returns variable newerthan=on if true
:: Usage: call :newerthan file1 file2
  @call :funcbegin %0 "'%~1' '%~2'"
  call :getfiledatetime file1 "%~1"
  call :getfiledatetime file2 "%~2"
  if defined info4 echo if %file1%. gtr %file2%. set newerthan=on
  if %file1%. gtr %file2%. set newerthan=on
  if defined info3 echo newerthan = %nererthan%
  @call :funcend %0
  goto :eof

:unicodecount
:: Description: Count unicode characters in file
:: Usage: t=:unicodecount "infile" "outfile"
:: Depends on: External program UnicodeCCount.exe from https://scripts.sil.org/cms/scripts/page.php?item_id=UnicodeCharacterCount
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%count%-unicodecount.txt"
  if not exist "%unicodecharcount%" call :fatal "Unicode Character count executable not found or not defined in xrun.ini"
  call "%unicodecharcount%" -o "%outfile%" "%infile%"
  @call :funcendtest %0
goto :eof

:uniqcount
:: Description: Create a sorted ist that is then reduced to a Uniq list
:: Usage: t=:uniqcount infile outfile
:: Depends on: External program C:\Windows\System32\sort.exe found in Windows
:: Depends on: External program uniq.exe from http://unixutils.sourceforge.net/
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%count%-sorted-list.txt"
  set nocount=%~3
  set countuniq=-c
  if defined nocount set countuniq=
  if defined info2 echo.
  if defined info2 echo C:\Windows\System32\sort.exe "%infile%" /O "%projectpath%\tmp\tmp1.txt"
  call C:\Windows\System32\sort.exe "%infile%" /O "%projectpath%\tmp\tmp1.txt"
  if defined info2 echo.
  if defined info2 echo %uniq% %countuniq% "%projectpath%\tmp\tmp1.txt" "%outfile%"
  call %uniq% %countuniq% "%projectpath%\tmp\tmp1.txt" "%outfile%"
  @call :funcendtest %0
goto :eof

:spawnbat
:: Depreciated:
  set p1=%~1
  set p2=%~2
  set p3=%~3
  set p4=%~4
  set p5=%~5
  set p6=%~6
  set p7=%~8
  set p8=%~8

start "" %p1% "%p2%" "%p3%" "%p4%"
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
  if not defined p1 if not exist "%p2%" Echo Error: valid file not found to start! & goto :eof
  if defined p1 if defined p2 if not exist "%p2%" Echo Error: valid file2 not found to start! & goto :eof
  if exist "%p1%" echo start "" %curcommand% & start "" %curcommand%
  if not exist "%p1%" echo start %curcommand% & start %curcommand%
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
  echo start /b %curcommand%
  start /b %curcommand%
  @call :funcend %0
goto :eof

:sub
:: Depreciated:
:: Description: Starts a sub loop, this is similar to taskgroup
:: Usage: call :sub "subname" ['param1' ['param2' ['param3' ['param4']]]]
:: Depends on: appendnumbparam and when unit testing: unittestaccumulate
  @call :funcbegin %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set sub1=%~1
  set sub2=%~2
  Set sub3=%~3
  Set sub4=%~4
  Set sub5=%~5
  Set sub6=%~6
  Set sub7=%~7
  Set sub8=%~8
  Set sub9=%~9
  set appendparam=
  If not defined sub1 echo Error: Missing variable in par1. Exit function!& if defined info4 echo %funcendtext% %0  & goto :eof
  If not defined sub2 echo Error: Missing variable in par2. Exit function!& if defined info4 echo %funcendtext% %0  & goto :eof
  rem now run all possible
  rem call scripts\%sub2%.cmd
  if defined info3 echo Info: Starting :sub [%sub1%]
  for /L %%v in (2,1,9) Do call :appendnumbparam numbparam sub %%v
  FOR /F "eol=[ delims=;" %%q IN (scripts\%sub2%.xrun) DO %%q
  rem the following 3 lines are for Unit testing.
  for /L %%v in (3,1,9) Do call :appendnumbparam numbparam sub %%v
  @if defined unittest set utreturn= %varin%, %subname%, %numbparam%, %taskend%, 
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO if defined %sub2%%%c call :unittestaccumulate %sub2%%%c
  @call :funcend %0 %sub2%
goto :eof

:taskcall
:: Description: Loop that triggers each taskgroup.
:: Usage: call :taskgroup group
:: Depends on: unittestaccumulate. Can depend on any procedure in the input task group.
@echo off
  @if defined fatal if defined info4 echo %funcendtext% %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined fatal goto :eof
  @call :funcbegin %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set group=%~1
  rem Do not remove these tgvarX variables some sub groups rely on them
  set tgvar2=%~2
  set tgvar3=%~3
  set tgvar4=%~4
  set tgvar5=%~5
  set tgvar6=%~6
  set tgvar7=%~7
  set tgvar8=%~8
  set tgvar9=%~9
  rem if not exist "scripts\proj.cmd" call :fatal %0 "Project cmd file proj.cmd missing!" "Process can't preceed." & goto :eof
  set taskend=!%~1count!
  rem if not defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :task %group%%%c
  call :%group:"=%
  rem set utreturn= %group%
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :unittestaccumulate %group%%%c
  @call :funcend %0 %~1
goto :eof


:taskgroup
:: Description: Loop that triggers each task in the group.
:: Usage: call :taskgroup group
:: Depends on: unittestaccumulate. Can depend on any procedure in the input task group.
  @if defined fatal if defined info4 echo %funcendtext% %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  @if defined fatal goto :eof
  @call :funcbegin %0 "%~1 '%~2' '%~3' '%~4' '%~5' '%~6' '%~7' '%~8' '%~9'"
  set group=%~1
  rem Do not remove these tgvarX variables some sub groups rely on them
  set tgvar2=%~2
  set tgvar3=%~3
  set tgvar4=%~4
  set tgvar5=%~5
  set tgvar6=%~6
  set tgvar7=%~7
  set tgvar8=%~8
  set tgvar9=%~9
  rem if not exist "scripts\%group%.xrun" call :fatal %0 "Taskgroup file %group%.xrun missing!" "Process can't preceed." & goto :eof

  set taskend=!%~1count!
  rem if not defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :task %group%%%c
  if not defined unittest FOR /F "eol=] delims=[" %%q IN (scripts\%group%.xrun) DO %%q "%~2" "%~3" "%~4" "%~5" "%~7" "%~8" "%~9"
  @if defined unittest set utreturn= %group%
  if defined unittest FOR /L %%c IN (1,1,%taskend%) DO call :unittestaccumulate %group%%%c
  @call :funcend %0 %~1
goto :eof


:task2cmd
:: Description: Converts sections in project.txt to x.xrun for later use
:: Usage: call :task2cmd list
:: Depends on: :task2cmdset
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set list=%~1
  @if defined info2 echo Setup: Include cmd tasks from: %~nx1 
  if exist "%cd%\scripts\a.xrun" del /q "%cd%\scripts\*.xrun"
  set xrunfile=%cd%\scripts\variables.xrun
  rem set utreturn=%list%
  FOR /F "eol=] delims=#" %%q IN (%list%) DO (
    set line=%%q
    call :task2cmdset
  )
  @call :funcend %0
goto :eof

:task2cmdset
:: Description: Creates x.xrun file for each section
:: Usage: call :variableset line sectiontoexit
:: Depends on: :xrunstart
  @call :funcbegin %0 
  if "%line:~0,1%" == "[" (
    set section=%line:~1,-1%
    set xrunfile=%cd%\scripts\%line:~1,-1%.xrun
    call :xrunstart "%cd%\scripts\%line:~1,-1%.xrun"
    rem echo rem auto generated file ^> %xrunfile%  & echo header copied to: %xrunfile%
  ) else (
  if "%line:~0,2%" == "t=" (
    echo call %line:~2% >> %xrunfile%
    if defined info3 echo call %line:~2% ^>^> %xrunfile%
    if defined info3 echo line copied: %line:~2%
    if defined info3 echo   copied to: %xrunfile%
    ) else (
    if "%section%" == "variables" (
        if "%line:~0,1%" neq "#" set %line%
    )
    if "%section%" == "setup" (
      if "%line:~0,1%" neq "#" set %line%
    )
    if "%section%" == "tools" (
      if "%line:~0,1%" neq "#" set %line%
    )
    )
  )  
  rem set utreturn=%utreturn%, %line%
  @call :funcend %0
goto :eof

:xrunstart
 echo rem auto generated file from project.txt > %~1  
 if defined info3 echo header copied to: %~1
goto :eof

:taskwritexrun
:: Description: Sets variables from one section
:: Usage: call :variableset line sectiontoexit
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set line=%~1
  set sectionget=%~2
  if "%line%" == "[%~2]" set sectionstart=on
  if "%line:~0,1%" == "[" goto :eof
  if "%line:~0,1%" == "[" @call :funcend %0 
  if not defined sectionstart goto :eof

  if defined sectionstart if "%line:~0,2%" == "t=" echo call %line:~2%>> scripts\%sectionget%-test.xrun   

  @if defined unittest set utreturn=%utreturn%, %line%
  @call :funcend %0
goto :eof

:test
:: Description: Used for unit testing
:: Usage: call :test val1 val2 valn report
:: Depends on:  calcnumbparam, last
  @if defined info4 echo %0 "'%~1' '%~2' '%~3' '%~4' '%~5' '%~6' '%~7'"
  set val1=%~1
  set val2=%~2
  set val3=%~3
  set val4=%~4
  set val5=%~5
  set val6=%~6
  set val7=%~7
  set val8=%~8
  set val9=%~9
  set t=
  set last=
  if defined info3 for /L %%v in (4,1,9) Do set val%%v
  rem if defined val4 if "%val4%" neq "%val4: =%" set val4="%val4%"
  rem if defined val5 if "%val5%" neq "%val5: =%" set val5="%val5%"
  rem set the correct parameters for the command and the echo by the number of variables declared on each task line
  set preaddnumbparam=%val1%
  for /L %%v in (4,1,9) Do call :calcnumbparam val %%v -1
  for /L %%v in (9,-1,4) Do call :last val %%v
  echo Unit test %preaddnumbparam%
  call %preaddnumbparam%
  rem Increment the test count
  set /A tcount+=1
  rem now echo the input values
  echo test input1: %val3%
  if defined val5 echo test input2: %val4%
  if defined val6 echo test input3: %val5%
  if defined val7 echo test input4: %val6%
  rem now output each  output followed by the expected output
  for /F "tokens=1-12 delims=," %%g in ("%val2%") do (
    set expect1=%%g
    set expect2=%%h
    set expect3=%%i
    set expect4=%%j
    set expect5=%%k
    set expect6=%%l
    set expect7=%%m
    set expect8=%%n
    set expect9=%%o
    set expect10=%%p
    set expect11=%%q
    set expect12=%%r
    )
  for /F "tokens=1-12 delims=," %%g in ("%utreturn%") do (
    @if defined unittest set utreturn1=%%g
    @if defined unittest set utreturn2=%%h
    @if defined unittest set utreturn3=%%i
    @if defined unittest set utreturn4=%%j
    @if defined unittest set utreturn5=%%k
    @if defined unittest set utreturn6=%%l
    @if defined unittest set utreturn7=%%m
    @if defined unittest set utreturn8=%%n
    @if defined unittest set utreturn9=%%o
    @if defined unittest set utreturn10=%%p
    @if defined unittest set utreturn11=%%q
    @if defined unittest set utreturn12=%%r
    )
    call :var utreturn1 %utreturn1%
  for /L %%n in (1,1,12) Do (
    if defined expect%%n (
      echo test output%%n: !utreturn%%n!
      echo    expected%%n: !expect%%n!
      rem echo on
      if "!utreturn%%n!" == "!expect%%n!" set t=!t!0
      if "!utreturn%%n!" neq "!expect%%n!"  set t=!t!1
      rem echo off
      )
  ) 
  set tword=passed & color 07
  if %t% gtr 0 set tword=failed & color 06
  echo Test: %tword%  %t%  %val1% test %tcount% %last%
  @echo.
  if "%tword%" == "failed" pause
  if not defined unittest if defined funcgrp4 echo %funcendtext% %0
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
    set curhhmm=%%A%%B
    set curhhmmss=%%A%%B%%C
    set curisohhmmss=%%A-%%B-%%C
    set curhh_mm=%%A:%%B
    set curhh_mm_ss=%%A:%%B:%%C
  )
  @call :funcend %0
goto :eof

:time2sec
set varname=%~1
for /F "tokens=1-3 delims=:.," %%a in ("%TIME%") do (
	set /A "%varname%=(%%a*60+1%%b-100)*60+(1%%c-100)
)
goto :eof

:sec2time
set /A hh=%~2/%sph%
set /A sh=%hh%*%sph%
set /A mm=(%~2-%sh%)/%spm%
set /A sm=%mm%*%spm%
set /A ss=(%~2 - %sh% - %sm%) 
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
set %~1=%hh%:%mm%:%ss%
goto :eof

:ut
:: Description: Used for unit testing
:: Usage: only used internally
:: Depends on: setup,
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set group=%~1
  call :setup
  if defined group set taskgroup=%group%
  FOR /F "eol=[ delims=`" %%q IN (scripts\ut-%group%.xrun) DO %%q
  @if defined info2 echo Info: unit test for scripts\ut%group%.xrun
  rem FOR %%g in (%taskgroup%) do call :unittestgroup ut%%g
  @call :funcend %0
goto :eof

rem :unittestgroup
rem   set groupname=%~1
rem   FOR /L %%c IN (1,1,%taskend%) DO if defined %groupname%%%c call :test !%groupname%%%c!
rem goto :eof

:unittestaccumulate
:: Description: Acumulate %utreturn% variables into a coma space separated list.
  @if defined unittest set utreturn=%utreturn%,%~1
goto :eof

:v2
:: Depreciated: no longer needed or used.
  @call :funcbegin %0 "'%~1' '%~2'"
  set vname=%~1
  set value=%~2
  if not defined vname echo Name value missing. Var not set& echo %funcendtext% %0  & goto :eof
  set %~1=%value%
  @if defined unittest set utreturn=%value%
  @call :funcend %0
goto :eof

:validate
:: Description: Validate an XML file
:: Usage: call :validate "xmlfile"
:: Depends on: External program 'xml.exe' from  XMLstarlet http://xmlstar.sourceforge.net/
  set xmlfile=%~1
  set isxml=%outfile:~-3%
  if not defined xmlfile if "%isxml%" == "xml" set xmlfile=%outfile%
  if not defined xmlfile echo xml file parameter missing & goto :eof
  if not exist "%xmlfile%" echo XML file not found & goto :eof
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
  if not defined vname echo Name value missing. Var not set& echo %funcendtext% %0 & set utreturn=missing vname & goto :eof
  rem no longer needed call :v2 retval "%value%"
  set %vname%=%value%
  @if defined unittest set utreturn=%vname%, !%vname%!
  @call :funcend %0
goto :eof

:variableset
:: Description: Sets variables sent from variableslist.
:: Usage: call :variableset line sectiontoexit
  @call :funcbegin %0 "'%~1'"
  if defined sectionexit @call :funcend %0  & goto :eof
  set line=%~1
  if "%line%" == "[%~2]" set sectionexit=on
  if "%line:~0,1%" == "[" @call :funcend %0 & goto :eof
  if "%line:~0,1%" neq "#" set %line%
  @if defined unittest set utreturn=%utreturn%, %line%
  @call :funcend %0
goto :eof

:variableslist
:: Description: Handles variables list supplied in a file.
:: Usage: call :variableslist list sectiontoexit
:: Depends on: :variableset
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set list=%~1
  set sectiontoexit=%~2
  @if defined info2 echo Setup: Include cmd variables from: %~nx1 
  @if defined unittest set utreturn=%list%
  FOR /F "eol=] delims=`" %%q IN (%list%) DO call :variableset "%%q" %sectiontoexit%
  set sectionexit=
  @call :funcend %0
goto :eof

:wait
timeout /t %~1 /nobreak
goto :eof

:task2cmd
:: Description: Converts sections in project.txt to x.xrun for later use
:: Usage: call :task2cmd list
:: Depends on: :settask2cmd
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set list=%~1
  set sectiontoexit=%~2
  @if defined info2 echo Setup: Include cmd variables from: %~nx1 
  @if defined unittest set utreturn=%list%
  FOR /F "eol=] delims=`" %%q IN (%list%) DO call :task2cmdset "%%q" %sectiontoexit%
  set sectionexit=
  @call :funcend %0
goto :eof

:task2cmdset
:: Description: Creates x.xrun file for each section
:: Usage: call :variableset line sectiontoexit
  @call :funcbegin %0 "'%~1'"
  if defined sectionexit @call :funcend %0  & goto :eof
  set line=%~1
  if "%line:~0,1%" == "[" set xrunfile=scripts\%line:~1%.xrun
  if "%line:~0,1%" == "t" echo call %line:~2% > %xrunfile%
  @if defined unittest set utreturn=%utreturn%, %line%
  @call :funcend %0
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
  set param=%allparam:'="%
  set curcommand="%java%" net.sf.saxon.Query -o:"%outfile%" -s:"%infile%" "%script%" %param%
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
  call :setup-xslt2
  call :inccount
  if defined scripts set script=%scripts%\%~1
  if not defined scripts set script=scripts\%~1
  call :infile "%~2" %0
  call :outfile "%~3" "%projectpath%\tmp\%group%-%count%-%~n1.xml" nocheck
  rem echo on
  set params=%~4
  if defined suppressXsltNamespace set suppressXsltNamespaceCheck=--suppressXsltNamespaceCheck on
  if not defined xslt set xslt=xslt2
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  if defined fatal goto :eof
  if "%xslt%" == "xslt1" (
    @if defined info2 echo %xml% tr "%script%" "%infile%" ^> "%outfile%"
    call "%xml%" tr "%script%" "%infile%" > "%outfile%" 
  )  
  if "%xslt%" == "xslt1ms" (
    @if defined info2 echo %xml% tr "%script%" "%infile%" ^> "%outfile%"
    call "%msxsl%" "%infile%" "%script%" -o "%outfile%" 
  ) 
  if "%xslt%" == "xslt2" (
    @if defined info2 echo %java% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%
    %java% -Xmx1024m  %suppressXsltNamespaceCheck% -jar "%saxon%" -o:"%outfile%" "%infile%" "%script%" %params%  
  )
  if "%xslt%" == "xslt3" (
    @if defined info2 echo xslt3 -xsl:"%script%" -s:"%infile%" -o:"%outfile%" %params%
    call :xslt3 -xsl:"%script%" -s:"%infile%" -o:"%outfile%" %params%
  ) 
  @if defined unittest set utreturn=%saxon%, %script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
  rem echo off
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
  @if defined unittest set utreturn=%saxon%, %script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
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
  @if defined unittest set utreturn=%saxon%, %script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
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
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo.
  @if defined info2 echo %xml% tr "%script%" "%infile%" ^> "%outfile%"
  call "%xml%" tr "%script%" "%infile%" > "%outfile%" 
  @if defined unittest set utreturn=%script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
  @call :funcendtest %0
goto :eof

:xsltms
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
  rem if not exist "%script%" call :fatal %0 "missing script: %script%"
  if not exist "%script%" call :scriptfind "%script%" %0
  if defined missinginput call :fatal %0 "infile not found!"
  if defined params set params=%params:'="%
  rem if defined params set params=%params:::==%
    )
  if defined fatal goto :eof
  @if defined info2 echo.
  @if defined info2 echo %msxsl% "%script%" "%infile%" -o "%outfile%"
  call "%msxsl%" "%infile%" "%script%" -o "%outfile%" 
  @if defined unittest set utreturn=%script%, %infile%, %outfile%, %group%-%count%-%~n1.xml
  @call :funcendtest %0
goto :eof



:setup-unused
  @rem call :variableslist "%projectpath%\project.txt" a
  @set utreturn=
  @rem for %%k in (%taskgroup%) do set t%%kcount=%defaulttaskcount% & set utreturn=%utreturn% %%k
  @rem set maxsubcount=%defaulttaskcount%
  @rem if not exist "%ProgramFiles%\java" call :fatal %0 "Is java installed?"  & goto :eof
  @rem call :javahometest
  if defined nojava set fatal=on & goto :eof
  if "%needsaxon%" == "true" if not exist "%saxon%" call :fatal %0 "Saxon9he.jar not found." "This program will exit now!"  & goto :eof
  call :ini2xslt "%cd%\setup\xrun.ini" "%cd%\scripts\xrun.xslt" iniparse4xslt setup
  @rem if exist "%cd%\scripts\xrun.xslt" del "%cd%\scripts\xrun.xslt"
  @rem call :rexxini "%cd%\setup\xrun.ini" "%cd%\scripts\xrun.xslt" tools writexslt
  copy /y "scripts\xrun.xslt" "%projectpath%\scripts" >> log.txt
  @rem create ?.xrun with batch
  @rem  echo on 
  @rem call :tasks2xrun "%projectpath%\project.txt" %groupin% taskwritexrun
  @rem  echo off 
  @rem call "%ccw32%" -u -b -q -n -t "scripts\ini2xslt2.cct" -o "scripts\setup.xslt" "setup\xrun.ini"
  if not exist "%cd%\scripts\xrun.xslt" call :fatal %0 "xrun.xslt not created" & goto :eof
  if exist "%scripts%\project.xslt" del "%scripts%\project.xslt"
  @rem if defined info2 echo Info: Java:saxon parse project.txt
  call %java% -jar "%saxon%" -o:"%scripts%\project.xslt" "blank.xml" "scripts\variable2xslt-3.xslt" projectpath="%projectpath%" xrunnerpath="%cd%" unittest=%unittest% xsltoff=%xsltoff%  USERPROFILE=%USERPROFILE%
  @rem if exist "%projectpath%\scripts\project.xslt" del "%projectpath%\scripts\project.xslt"
  @rem call :rexxini "%projectpath%\project.txt" "%projectpath%\scripts\project.xslt" variables writexslt
  @rem call :rexxini "%projectpath%\project.txt" "%cd%\scripts\%groupin%.xrun" %groupin% writecmdtasks
  @rem call :rexxini "%projectpath%\project.txt" "%projectpath%\tmp\project.cmd" variables writecmdvar
  if not exist "%scripts%\project.xslt" call :fatal %0 "project.xslt not created" & goto :eof
  if not exist "%scripts%\project.xslt" call :fatal %0 "project.xslt not created" & goto :eof
  @rem call :xslt variable2xslt-2.xslt blank.xml %scripts%\project.xslt "projectpath='%projectpath%' 'unittest=%unittest%'"
  @rem the following sets the default script path but it can be overridden by a scripts= in the project.txt
  set scripts=%projectpath%\scripts
  if not exist "%scripts%\inc-lookup.xslt" copy "scripts\inc-lookup.xslt" "%scripts%\inc-lookup.xslt"
  if not exist "%scripts%\inc-file2uri.xslt" copy "scripts\inc-file2uri.xslt" "%scripts%\inc-file2uri.xslt"
  if not exist "%scripts%\inc-copy-anything.xslt" copy "scripts\inc-copy-anything.xslt" "%scripts%\inc-copy-anything.xslt"
  call "%projectpath%\tmp\project.cmd"
  if defined model call :loopfiles "%model%\*.*" :modelcheck "%model%"
  if exist "%scripts%\project.xslt" if defined info2 echo Setup: project.xslt from: project.txt
  
  
  call :setinfolevel %infolevel%
  @if defined info1 echo Setup: complete
  set /A count=0
  @if defined unittest set utreturn=%scripts%
  @call :funcend %0
goto :eof

