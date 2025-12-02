:init
:: Description: xrunner.cmd
:: Usage: xrunner C:\path\project.txt [group [infolevel [pauseatend [unittest]]]]
:: Note: xrunner requires a project file. The group parameter is normally a letter in the range a-z.
:: Xrunner 2 uses ccw to generate the needed initial files.
:: Now the tasklists are converted into functions. Appended to that is the xrun.ini variables, the xruni.ini tools and the project.txt variables and the old xrun.cmd functions.
@echo off
cls
set projectfile=%1
set projectpath=%~dp1
set group=%2
set infolevel=%3
set pauseatend=%4
call :colorvar
call :setinfolevel %infolevel%
rem Required tools. May need to edit the next three lines
set ccw=%cd%\tools\cct\Ccw64.exe
set make=%cd%\tools\bin\make.exe
set saxon=%cd%\tools\saxon\saxon12he.jar
if not exist "%ccw%" echo %redbg%%ccw% not found! Fix and try again!%reset%& goto :eof
if not exist "%make%" echo %redbg%%make% not found! Fix and try again%& goto :eof
@if defined info4 echo %magenta%%funcstarttext%%reset%
@if defined info3 echo %magentabg%:xrunner%reset% %fparams%
call :main %group%
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
  echo Source: %green%https://github.com/SILAsiaPub/xrunner2%reset%
  if exist "%projectfile%" (
    echo Project: %green%%projectfile%%reset%
    echo.
    if defined info5 echo on
  ) else (
    echo.
    rem This is to ensure there is a parameter for the project.txt file.
    echo %redbg%A valid project file must be provided. It is a required parameter.%reset%
    echo Usage: xrunnner C:\path\project.txt group [infolevel [pauseatend]]
    echo.
    echo %redbg%This script will exit.%reset%
    echo.
    pause
    goto :eof
  )
  @if defined info1 echo Xrunner Started: %yellow%%time:~0,8%%reset%
  call :time2sec starttime
  @if defined info3 echo Start Seconds: %starttime%
  call :setup
  if not defined group set fatal=on
  if defined fatal goto :eof
  call "%projcmd%" %group%
  if defined espeak if defined info2 call "%espeak%" "x runner finished"
  @call :funcend :main
  call :time2sec endtime
  set /A sec=%endtime%-%starttime%
  call :sec2time etime %sec%
  @if defined info2 echo %green%Xrunner finished in %reset%%yellow%%etime%%reset% %etime-units% at %time:~0,8%
  @call :funcend :xrunner
  if defined pauseatend (pause ) else (timeout 30)
goto :eof

:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
:: Purpose: make folder only if not present
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

:getdatetime
:: Description: Returns multiple variables with 6 individual date and time vraiable prefixed by 00.
:: Used by: :date
:: Created: 2016-05-04
:: Modified: 2024-09-11
:: Source: got this from: http://www.robvanderwoude.com/datetiment.php#IDate but modified into two func
  FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
    IF "%%~L"=="" goto :eof
    set _yyyy=%%L
    set _mm=00%%J
    set _dd=00%%G
    set _hour=00%%H
    set _minute=00%%I
    set _second=00%%K
  )
goto :eof

:date
:: Description: Returns multiple variables with date in three formats, the year in two formats, month, day date and time.
:: Functions called: funcend funcbegin
:: Variables Created: _mm _dd _hour _minute _second curhhmm curhhmmss curisohhmmss curhh_mm curhh_mm_ss curdate curisodatetime curisodate yyyy-mm-dd curyyyy-mm curyyyymmdd curyymmdd curUSdate curAUdate curyyyy curyy curmm curdd 
:: Created: 2016-05-04
:: Modified: 2024-09-11
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :getdatetime
  Set _mm=%_mm:~-2%
  Set _dd=%_dd:~-2%
  Set _hour=%_hour:~-2%
  Set _minute=%_minute:~-2%
  Set _second=%_second:~-2%
  set curhhmm=%_hour%%_minute%
  set curhhmmss=%_hour%%_minute%%_second%
  set curisohhmmss=%_hour%-%_minute%-%_second%
  set curhh_mm=%_hour%:%_minute%
  set curhh_mm_ss=%_hour%:%_minute%:%_second%
  set curdate=%_yyyy%-%_mm%-%_dd%
  set curisodatetime=%_yyyy%-%_mm%-%_dd%T%curisohhmmss%
  set curisodate=%_yyyy%-%_mm%-%_dd%
  set yyyy-mm-dd=%_yyyy%-%_mm%-%_dd%
  set curyyyy-mm=%_yyyy%-%_mm%
  set curyyyymmdd=%_yyyy%%_mm%%_dd%
  set curyymmdd=%_yyyy:~2%%_mm%%_dd%
  set curUSdate=%_mm%/%_dd%/%_yyyy%
  set curAUdate=%_dd%/%_mm%/%_yyyy%
  set curyyyy=%_yyyy%
  set curyy=%_yyyy:~2%
  set curmm=%_mm%
  set curdd=%_dd%
  @call :funcend %0
goto :eof
 
:encoding
:: Description: to check the encoding of a file
:: Usage: call :encoding file [validate-against]
:: Functions called: :infile
:: External program: file.exe http://gnuwin32.sourceforge.net/
:: Required variables: encodingchecker
:: Note: not the same as in func.cmd
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  if not defined encodingchecker echo Encoding not checked. Encoding Checker not defined. & echo %funcendtext% %0 error1 &goto :eof
  if not exist "%encodingchecker%" call :funcend %0 "file.exe not found! %fileext%" "Encoding not checked." & goto :eof
  set testfile=%~1
  set validateagainst=%~2
  set infile=%testfile%
  set nameext=%~nx1
  FOR /F "usebackq tokens=1-2 delims=;," %%A IN (`%encodingchecker% --mime-encoding "%infile%"`) DO set fencoding=%%B & echo %%~nxA is %magentabg%%%B %reset%
  @rem echo %magentabg%%fencoding%%reset%
  if defined validateagainst (
    if "%fencoding%" == " %validateagainst% "  ( 
      echo Encoding check: %green%%nameext%%reset% is %magentabg%%fencoding%%reset%
      set /A badencoding=0+%badencoding%
    ) else (
      if "%fencoding%" == " us-ascii " ( 
        echo Encoding check: %green%%nameext%%reset% is %magentabg%%fencoding%%reset% which is UTF-8 compatible.
        if "%validateagainst%" == "utf-8" set /A badencoding=0+%badencoding%
      ) else (
        echo Encoding check:  %red%%nameext%%reset% is %redbg%%fencoding% %reset% But it was expected to be: %red%%validateagainst%. %reset%
        set /A badencoding=1+%badencoding%
        
      )
    )
  )
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
  @if defined info4 echo %magenta%%funcstarttext%%reset%
  @if defined info3 echo %magentabg%%func%%reset% %fparams%
  @if defined info4 @if defined %funcname%echo echo  ============== %funcname%echo is ON =============== & echo on
@goto :eof

:funcend
:: Description: Used for non ouput file func
:: Usage: @call :funcend %0
:: Purpose: feedback
:: Functions used: 
:: Variables used: funcendtext
  @set func=%~1
  @if defined info4 echo %magenta%------------------------------------ %func% %funcendtext%%reset%
  @if defined %func:~1%pause pause
  @rem the following form of %func:~1% removes the colon from the begining of the func.
  @if defined !func:~1!echo echo ========= !func:~1!echo switched OFF =========& echo off
@goto :eof

:colorvar
:: Description: Sets the inline color variables.
:: Usage: call :inlinecolor
:: Reference: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
  set reset=[0m
  rem dull forground colors
  set black=[30m
  set red=[31m
  set green=[32m
  set yellow=[33m
  set blue=[34m
  set magenta=[35m
  set cyan=[36m
  set white=[37m
  rem strong forground colors
  set redb=[91m
  set greenb=[92m
  set yellowb=[93m
  set blueb=[94m
  set magentab=[95m
  set cyanb=[96m
  set whiteb=[97m
  rem strong background colors
  set redbg=[101m
  set greenbg=[102m
  set yellowbg=[103m
  set bluebg=[104m
  set magentabg=[105m
  set bluebg=[106m
  set whitebg=[107m
goto :eof

:makef
:: Description: This runs the makefile script for checking if the project.xslt is up to date
:: Usage: call :makef makefile-path-filename
:: Required variables: make 
  @call :funcbegin %0 "'%~1'"
  set makepath=%~dp1
  set makefile=%~nx1
  pushd "%makepath%"
  call %make% -f %makefile%
  popd
  @call :funcend %0
goto :eof

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
  if defined info3 FOR /F %%i IN ('set info') DO echo %green%Info: %%i%reset%
  if "%~1" geq "3" set clfeedback=on
  set funcstarttext={============================================================
  set funcendtext=  ----}
goto :eof

:setup
:: Description: Sets up the variables and does some checking.
:: Usage: call :setup
:: Purpose: create variables, create project.cmd
:: Functions used: funcbegin funcend checkdir detectdateformat
:: Programs used: ccw or ccw64 sys.cmd
:: Variables used: projectpath ccw green reset
:: Variables created: projectpath scripts cctparam syscmd taskscmd projcmd setupcct funccmd ccw count
:: Variable cleared: firstxslt
  @call :funcbegin %0 "%~1 %~2 %~3"
  @echo off
  if "%PUBLIC%" == "C:\Users\Public" (
      rem if "%PUBLIC%" == "C:\Users\Public" above is to prevent the following command running on Windows XP
      rem this still does not work for Chinese characters in the path
      chcp 65001
      )
  set setupxslt=on
  set projectpath=%projectpath:~0,-1%
  rem set checkencoding=on
  set scripts=%projectpath%\scripts
  set cctparam=-u -b -q -n
  set syscmd=%scripts%\sys.cmd
  set taskscmd=%scripts%\tasks.cmd
  set projcmd=%scripts%\proj.cmd
  set setupcct=%cd%\scripts\setup2.cct
  set funccmd=%cd%\scripts\func.cmd
  set xtest=%red%%yellowbg% Test: %reset%
  set xtestt=%xtest% %greenbg%%whiteb% TRUE %reset% -
  set xtestf=%xtest% %redbg% FALSE %reset% -
  set projxsltmake=%projectpath%\projxslt.make
  set au3=C:\Program Files (x86)\AutoIt3\AutoIt3.exe
  call :date
  rem xcopy /D /Y setup\proj-cmd.txt "%projectpath%\scripts"
  echo xrunnerpath := %cd%> setup\temp.txt
  echo projpath := %projectpath%>> setup\temp.txt
  echo ccw := %ccw%>> setup\temp.txt
  echo saxon := %saxon%>> setup\temp.txt
  if '%java%' == 'java' ( echo java := java>> setup\temp.txt
    ) else (echo java := %java%>> setup\temp.txt)
  copy setup\temp.txt+setup\projsetup.make %projectpath%\projsetup.make > nul 
  copy setup\temp.txt+setup\projxslt.make %projectpath%\projxslt.make > nul 
  rem xcopy /D /Y setup\*.make "%projectpath%" > nul
  call :makef "%projectpath%\projsetup.make"
  set curerrorlevel=%errorlevel%
  if exist "%au3%" call "%au3%" save-files.au3
  if %curerrorlevel%. neq %errorlevel%. echo %red%Autoit3 error from script save-files.au3%reset% & set errorlevel=0
  @if defined info3 echo %green%Setup: complete%reset%
  @if defined info1 echo.
  set /A count=0
  @call :funcend %0
  if "%~3" == "5" echo on
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

:tsv2xml
:: Description: Convert TSV to XML via NodeJS 
:: Usage: call :tsv2xml inputfile outputfile
:: Created: 2023-05-03
  call :infile "%~1"
  call :outfile "%~2"
  call parsjs -m -d tab -o xml -s "%outfile%" "%infile%"
goto :eof
