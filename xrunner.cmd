:: Description: xrunner.cmd
:: Usage: xrunner C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
:: Note: xrunner requires a project file. The group parameter is normally a letter in the range a-z.
:: Xrunner 2 uses CCW32 to generate the needed initial files.
:: Now the tasklists are converted into functions. Appended to that is the xrun.ini variables, the xruni.ini tools and the project.txt variables and the old xrun.cmd functions.
@echo off
cls
set projectfile=%1
set projectpath=%~dp1
set group=%2
set infolevel=%3
set pauseatend=%4
:: Unit test is depreciated
:: set unittest=%5
call :setinfolevel %infolevel%
call :main
goto :eof

:main
:: Description: Main Loop, does setup and gets variables then runs group loops.
:: Usage: call :main
:: Purpose: control
:: Functions used: funcbegin funcend time2sec setup project.cmd
  @call :funcbegin %0 "%~1"
  echo ==============================================================================
  echo                                     Xrunner2    
  echo ==============================================================================
  echo Source: https://github.com/SILAsiaPub/xrunner2
  echo Project: %projectfile%
  if "%infolevel%" == "5" echo on
  if not exist "%projectfile%" (
    rem This is to ensure there is a parameter for the project.txt file.
    echo A valid project file must be provided. It is a required parameter.
    echo Usage: xrunnner C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
    echo This script will exit.
    pause
    goto :eof
  )

  setlocal enabledelayedexpansion
  color 07
  @if defined info1 echo Xrunner Started: %time:~0,8%
  call :time2sec starttime
  @if defined info3 echo Start Seconds: %starttime%
  call :setup
  if not defined group set fatal=on
  if defined fatal goto :eof
  call "%projcmd%" %group%
  @if defined info2 echo Info: xrunner finished!
  if defined espeak if defined info2 call "%espeak%" "x runner finished"
  @call :funcend :main
  call :time2sec endtime
  set /A sec=%endtime%-%starttime%
  @echo Completed in %sec% seconds at %time:~0,8%
  @call :funcend xrun
  if defined pauseatend pause
goto :eof


:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
:: Purpose: make folder
:: Functions used: funcbegin funcend 
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
  @call :funcend %0
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in wo formats, month and day date.
:: Usage: call :date
:: Purpose: create date variables
:: Variables created: fdd fmm fyyyy curdate curisodate yyyy-mm-dd curyyyymmdd curyymmdd curUSdate curAUdate curyyyy curyy curmm curdd
:: Functions used: funcbegin funcend detectdateformat
:: Variables used: dateformat dateseparator timeseparator
:: Created: 2016-05-04
:: Source url: http://www.robvanderwoude.com/datetiment.php#IDate
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
:: Purpose: check registry, create variables
:: Functions used: funcbegin funcend
:: Variables created: dateformat dateseparator timeseparator
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

:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file [validate-against]
:: Functions used: funcbegin funcend infile
:: External program: file.exe http://gnuwin32.sourceforge.net/
:: Variables used: encodingchecker
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
:: Purpose: feedback
:: Functions used: 
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

:funcbegin
:: Descriptions: takes initialization out of funcs
:: Usage: @call :funcbegin %0 '%~1' '%~2' 'etc'
:: Purpose: feedback
:: Functions used: 
:: Variables used: magentabg reset funcstarttext 
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
:: Usage: @call :funcend %0
:: Purpose: feedback
:: Functions used: 
:: Variables used: outfile green reset redbg 
  set functest=%~1
  @if defined info2 if exist "%outfile%" echo.
  @if defined info1 if exist "%outfile%" echo %green%Output: %outfile% %reset%
  @if defined info1 if exist "%outfile%" set utret3=Output: %outfile%
  @if defined outfile if not exist "%outfile%" Echo %redbg%Task failed: Output file not created! %reset%
  @if defined outfile if not exist "%outfile%" set utret4=color 06
  @if defined outfile if exist "%outfile%" set utret4=
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & pause
@goto :eof

:funcend
:: Description: Used for non ouput file func
:: Usage: @call :funcend %0
:: Purpose: feedback
:: Functions used: 
:: Variables used: funcendtext
  @set func=%~1
  @if defined info4 echo %func% %funcendtext%
  @if defined %func:~1%pause pause
  @rem the following form of %func:~1% removes the colon from the begining of the func.
  @if defined !func:~1!echo echo ========= !func:~1!echo switched OFF =========& echo off
@goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb_level
:: Note: numb-level range 0-5
:: Purpose: create variables
:: Functions used:
:: Variables created: info1 info2 info3 info4 info5 funcstarttext funcendtext redbg magentabg green reset
  for /L %%v in (1,1,5) Do set info%%v=
  rem set info levels from input
  for /L %%v in (1,1,5) Do if "%~1" geq "%%v" set info%%v=on
  @if defined info3 echo.
  if defined info3 FOR /F %%i IN ('set info') DO echo Info: %%i
  if "%~1" geq "3" set clfeedback=on
  set funcstarttext={---
  set funcendtext=       ----}
  set redbg=[101m
  set magentabg=[105m
  set green=[32m
  set reset=[0m
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Purpose: create variables, create project.cmd
:: Functions used: funcbegin funcend checkdir detectdateformat
:: Programs used: ccw32 or ccw64 sys.cmd
:: Variables used: projectpath ccw32 green reset
:: Variables created: projectpath scripts cctparam syscmd taskscmd projcmd setupcct funccmd ccw32 count
:: Variable cleared: firstxslt
  @call :funcbegin %0 "%~1 %~2 %~3"
  if "%PUBLIC%" == "C:\Users\Public" (
      rem if "%PUBLIC%" == "C:\Users\Public" above is to prevent the following command running on Windows XP
      rem this still does not work for Chinese characters in the path
      chcp 65001
      )
  set projectpath=%projectpath:~0,-1%
  rem set checkencoding=on
  set firstxslt=
  set scripts=%projectpath%\scripts
  set cctparam=-u -b -q -n
  set syscmd=%scripts%\sys.cmd
  set taskscmd=%scripts%\tasks.cmd
  set projcmd=%scripts%\proj.cmd
  set setupcct=%cd%\scripts\setup.cct
  set funccmd=%cd%\scripts\func.cmd
  set ccw32=C:\programs\xrunner2\tools\cct\Ccw64.exe
  call :checkdir "%projectpath%\scripts\"
  call :checkdir "%projectpath%\tmp"
  call "%ccw32%" %cctparam% -t "%setupcct%" -o "%syscmd%" "setup\xrun.ini"
  call :detectdateformat
  call %syscmd%
  call "%ccw32%" %cctparam% -t "%setupcct%" -o "%taskscmd%" "%projectpath%\project.txt"
  copy "%taskscmd%"+"%funccmd%"+"%syscmd%" "%projcmd%" > nul
  @if defined info1 echo %green%Setup: complete%reset%
  @if defined info1 echo.
  set /A count=0
  @call :funcend %0
  if "%~3" == "5" echo on
goto :eof

:time
:: Description: Retrieve time in several shorter formats than %time% provides
:: Usage: call :time
:: Purpose: create variables
:: Functions used: funcbegin funcend
:: Variables used: time
:: Variables created: curhhmm curhhmmss curisohhmmss curhh_mm curhh_mm_ss
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
:: Description: Retrieve the time in seconds
:: Usage: call :time2sec var_name
:: Purpose: create variable
:: Functions used:
:: Variable used: time
:: Variable created: var_name
set varname=%~1
for /F "tokens=1-3 delims=:.," %%a in ("%TIME%") do (
	set /A "%varname%=(%%a*60+1%%b-100)*60+(1%%c-100)
)
goto :eof
