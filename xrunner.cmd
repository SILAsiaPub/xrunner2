:: Description: xrunner.cmd
:: Usage: xrunner C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
:: Note: xrunner requires a project file. The group parameter is normally a letter in the range a-z.
:: Xrunner 2 uses CCW32 to generate the needed initial files.
:: Now the tasklists are converted into functions. Appended to that is the xrun.ini variables, the xruni.ini tools and the project.txt variables and the old xrun.cmd functions.
@echo off
set projectfile=%1
set projectpath=%~dp1
set group=%2
set infolevel=%3
set pauseatend=%4
:: Unit test is depreciated
set unittest=%5
call :main
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Depends on: :setup, :taskgroup and may use unittestaccumulate
  @if defined info4 echo {---- :main %group%
  if "%infolevel%" == "5" echo on
  if not exist "%projectfile%" (
    rem This is to ensure there is a parameter for the project.txt file.
    echo A valid project file must be provided. It is a required parameter.
    echo Usage: xrunnner C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
    echo This script will exit.
    pause
    goto :eof
  )
  set projectpath=%projectpath:~0,-1%
  set checkencoding=on
  call :checkdir "%projectpath%\scripts\"
  if not defined infolevel set infolevel=2
  setlocal enabledelayedexpansion
  call :setinfolevel %infolevel%
  @if defined info2 echo %0 "%1" %2 %3 %4 %5 
  color 07
  call :time2sec starttime
  @echo Start Seconds: %starttime%
  @echo Xrunner Started: %time:~0,8%
  call :setup
  if defined fatal goto :eof
  if defined group set taskgroup=%group%
  if exist "%scripts%\xrun.xslt" del "%scripts%\xrun.xslt"
  if exist "%scripts%\project.xslt" del "%scripts%\project.xslt"
  call "%projcmd%" %group%
  @if defined info2 echo Info: xrun finished!
  if defined espeak if defined info2 call "%espeak%" "x run finished"
  @call :funcend :main
  call :time2sec endtime
  set /A sec=%endtime%-%starttime%
  @echo Completed in %sec% seconds at %time:~0,8%
  rem if defined pauseatend call :exit-prompt
  @call :funcend xrun
  if defined pauseatend pause
goto :eof


:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set checkpath=%~1
  set drivepath=%~dp1
  if not defined checkpath echo missing required directory parameter for :checkdir& echo. %funcendtext% %0  & goto :eof
  set ext=%~x1
  if defined ext set checkpath=%~dp1
  if defined ext set checkpath=%checkpath:~0,-1%
  if exist "%checkpath%" if defined info3 echo Info: found path %checkpath%
  if not exist "%checkpath%" if defined info3 echo Info: creating path %checkpath%
  if not exist "%checkpath%" mkdir "%checkpath%"
  rem set utreturn=%checkpath%
  @call :funcend %0
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Required variables: detectdateformat
:: Created: 2016-05-04
rem got this from: http://www.robvanderwoude.com/datetiment.php#IDate
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
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
  set justpath=%~p1
  set drivelet=%drive:~0,1%
  set drivepath=%utdp:~0,-1%
  rem set utreturn=%drivepath%
  @call :funcend %0
goto :eof

:dummy
goto :eof

:echo
:: Description: Echo a message
:: Usage: call :echo "message text"
  set nl=%~2
  if defined nl (
    @echo.
  ) else (
    @echo %~1
  
  )
goto :eof

:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file [validate-against]
:: Depends on: :infile
:: External program: file.exe http://gnuwin32.sourceforge.net/
:: Required variables: encodingchecker
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
if not defined encodingchecker echo Encoding not checked. & echo %funcendtext% %0 error1 &goto :eof
if not exist "%encodingchecker%" echo file.exe not found! %fileext% &echo Encoding not checked. & echo %funcendtext% %0 error2 & goto :eof
set testfile=%~1
set validateagainst=%~2
call :infile "%testfile%"
set nameext=%~nx1
FOR /F "usebackq tokens=1-2" %%A IN (`%encodingchecker% --mime-encoding "%infile%"`) DO set fencoding=%%B
if defined validateagainst (
    if "%fencoding%" == "%validateagainst%"  (
        echo %green% Encoding is: %fencoding% for file %nameext%. %reset%
      ) else if "%fencoding%" == "us-ascii" (
        echo %magentabg% Encoding is: %fencoding% not %validateagainst% but is usable. %reset%
      ) else (
        echo %redbg% File %nameext% encoding is %fencoding%! %reset% 
        echo %redbg% Encoding is: %fencoding%  But it was expected to be: %validateagainst%. %reset%
        set errorsuspendprocessing=on
        pause
      )
) else  (              
    echo Encoding is: %magentabg% %fencoding% %reset% for file %nameext%.
    pause
) 
  rem set utreturn=%testfile%, %validateagainst%, %fencoding%, %nameext%
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
  @if defined info2 echo %fatal% In %func% %group%%reset% 
  echo %fatal% Task %count% %message% %reset%
  if defined message2 echo %fatal% Task %count% %message2%%reset%
  rem set utreturn=%message%
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
  @if defined info3 echo %func% %fparams%
  @if defined info4 echo %funcstarttext% %func% %fparams%
  @if defined info4 @if defined %funcname%echo echo  ============== %funcname%echo is ON =============== & echo on
@goto :eof
:funcendtest
:: Description: Used with func that output files. Like XSLT, cct, command2file
:: Usage: call :funcend %0
  set functest=%~1
  @if defined info2 if exist "%outfile%" echo.
  @if defined info1 if exist "%outfile%" echo %green%Output: %outfile% %reset%
  @if defined info1 if exist "%outfile%" set utret3=Output: %outfile%
  @if defined outfile if not exist "%outfile%" Echo %redbg%Task failed: Output file not created! %reset%
  @if defined outfile if not exist "%outfile%" set utret4=color 06
  @if defined outfile if exist "%outfile%" set utret4=
  @if not defined info4 set utret5=
  @if defined info4 set utret5=%funcendtext% %functest%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & if not defined unittest pause
  rem set utreturn= %functest%, %info1%, %info4%, %utret3%, %utret4%, %utret5%
  @call :funcend %functest%
@goto :eof

:funcend
:: Description: Used for non ouput file func
:: Usage: call :funcend %0
  @set func=%~1
  @if defined info4 echo %funcendtext% %func%
  @if defined %func:~1%pause pause
  @rem the following form of %func:~1% removes the colon from the begining of the func.
  @if defined !func:~1!echo echo ========= !func:~1!echo switched OFF =========& echo off
@goto :eof

:exit-prompt
:: Description: runs an exe file that brings up a prompt
exit-cmd.exe
if exist "%tmp%\yes" (set ans=exit & del /q /f "%tmp%\yes") else (set ans=echo.)
%ans%
goto :eof

   
:name
:: Description: Returns a variable name containg just the name from the path.
  @call :funcbegin %0 %~1
  set name=%~n1
  set ext=%~x1
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
  rem set utreturn=%~1, %info1%, %info2%, %info4%, %info3%, %info5%, %funcstarttext%, %funcendtext%
  @call :funcend %0
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Depends on: variableslist, detectdateformat, ini2xslt, iniparse4xslt, setinfolevel, fatal
  if "%PUBLIC%" == "C:\Users\Public" (
      rem if "%PUBLIC%" == "C:\Users\Public" above is to prevent the following command running on Windows XP
      rem this still does not work for Chinese characters in the path
      chcp 65001
      )
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  set redbg=[101m
  set magentabg=[105m
  set green=[32m
  set reset=[0m
  set cctparam=-u -b -q -n

  set syscmd=%projectpath%\scripts\sys.cmd
  set taskscmd=%projectpath%\scripts\tasks.cmd
  set projcmd=%projectpath%\scripts\proj.cmd
  set setupcct=%cd%\scripts\setup.cct
  set funccmd=%cd%\scripts\func.cmd
  copy /y "%setupcct%" "%projectpath%\scripts"
  set ccw32=C:\programs\cc\Ccw32.exe
  rem the following line cleans up from previous runs.
  if not defined unittest if exist scripts\*.xrun del scripts\*.xrun
  set scripts=%projectpath%\scripts
  if not exist "%scripts%" md "%scripts%"
  set /A count=0
  if exist "%syscmd%" del "%syscmd%"
  call "%ccw32%" %cctparam% -t "%setupcct%" -o "%syscmd%" "setup\xrun.ini"
  rem call :cct setup.cct "setup\xrun.ini" "%syscmd%"
  echo.
  call :detectdateformat
  call %syscmd%
  call :setup-batch
  @if defined info1 echo Setup: complete
  set /A count=0
  rem set utreturn=%scripts%
  @call :funcend %0
  if "%~3" == "5" echo on
goto :eof

:setup-batch
:: Description: Sets up the xrun files from the project.txt
:: Usage: call :setup-batch "%projectpath%\project.txt"
:: Depends on: variableslist, task2cmd
  @call :funcbegin %0 "'%~1'"
  call :checkdir "%cd%\scripts"
  rem if exist "%projcmd%" del "%projcmd%"
  rem call :variableslist "%projectpath%\project.txt" a
  call "%ccw32%" %cctparam% -t "%setupcct%" -o "%taskscmd%" "%projectpath%\project.txt"
  copy "%taskscmd%"+"%funccmd%"+"%syscmd%" "%projcmd%"
  @call :funcend %0
goto :eof


:time
:: Description: Retrieve time in several shorter formats than %time% provides
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

