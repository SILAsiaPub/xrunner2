@set targetecho=off
@set supportecho=off
@echo %targetecho%
cls
:: setup variables
call :colorvar
call :setinfolevel 2
set cctparam=-u -b -q -n
set dateformat=1
set dateseparator=/
set java=D:\programs\javafx\bin\java.exe
set epub=D:\All-SIL-Publishing\_xrunner2_projects\_GPS\GPS-ES\EXGSUM64JN1-ver2\output\John_1-9_2024-06-25.epub
set epubcheckjar=C:\programs\xrunner2\tools\epubcheck\epubcheck.jar
set projectpath=C:\programs\xrunner2\ut\project
set scripts=%projectpath%\scripts
:: run function
call :epubcheck "%epub%"
goto :eof


:epubcheck
:: Description: Check Epub file
:: Usage: call :epubcheck epubfile [report_file]
:: Note: The epub-report is cumulative with the latest at the top, after the ISO date-time
:: Updated: 2024-06-25
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\check\epub-report.txt" 
  set tempout=%projectpath%\tmp\epubrpt.txt
  rem set oldout=%projectpath%\tmp\epub-old-report.txt
  set dateout=%projectpath%\tmp\dateout.txt
  call :checkdir "%tempout%"
  rem call :date
  if %dateformat%. == 0. echo %date:~10,4%-%date:~4,2%-%date:~7,2% %time:~0,5%> "%outfile%"
  if %dateformat%. == 1. echo %date:~10,4%-%date:~7,2%-%date:~4,2% %time:~0,5%> "%outfile%"
  if %dateformat%. == 2. echo %date:~4,4%-%date:~9,2%-%date:~12,2% %time:~0,5%> "%outfile%"
  echo. >> "%outfile%"
  @if defined info2 echo %cyan%%java% -jar "%epubcheckjar%" "%infile%" 2^> "%tempout%"%reset%
  %java% -jar "%epubcheckjar%" %infile% 2> "%tempout%"
  set cctcommand="%ccw%" -u -b %cctparam% -t "epub-shorten-report.cct" -o "%tempout%2" "%tempout%"
  @if defined info2 echo %cyan%%cctcommand%%reset%
  pushd "%scripts%"
  call %cctcommand%
  popd
  @if defined info3 echo %cyan%type "%tempout%2" ^>^> "%outfile%"%reset%
  type "%tempout%2" >> "%outfile%"
  @if defined info3 echo.
  @if defined info3 echo %cyan%type "%outfile%.prev" ^>^> "%outfile%"%reset%
  type "%outfile%.prev" >> "%outfile%"
  @call :funcendtest %0
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

:funcendtest
:: Description: Used with func that output files. Like XSLT, cct, command2file
:: Usage: call :funcendtest %0 [alt_text]
:: Functions called: funcbegin funcend
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  @set functest=%~1
  @set alttext=%~2
  @if not defined alttext set alttext=Output:
  @if defined info1 if exist "%outfile%" echo %green%%alttext% %outfile% %reset%
  @if defined outfile if not exist "%outfile%" Echo %redbg%Task failed: Output file not created! %reset%
  @if defined outfile if not exist "%outfile%" set skiptasks=on  & if not defined unittest pause
  @if defined info2 if exist "%outfile%" echo.
  @call :funcend  %0
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

:infile
:: Description: If infile is specifically set then uses that else uses previous outfile.
:: Usage: call :infile "%file%" calling-func
:: Functions called: fatal
  @echo %supportecho%
  @call :funcbegin %0 "'%~1' '%~2'"
  set infile=%~1
  set callingfunc=%~2
  if not defined infile set infile=%outfile%
  if not exist "%infile%" call :fatal %0 "infile %~nx1 not found for %callingfunc%"
  @if defined info4 echo Info: %green%infile = %infile%%reset%
  @call :funcend %0
  @echo %targetecho%
goto :eof

:outfile
:: Description: If out file is specifically set then uses that else uses supplied name.
:: Usage: call :outfile "C:\path\file.ext" "%cd%\tmp\%script%.xml" nocheck_or_append
:: Functions called: funcbegin funcend
  @echo %supportecho%
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
  if defined toutfile (
    set outfile=%toutfile:)=%
  ) else (
    set outfile=%defaultoutfile%
  )
  if not defined toutfile set outpath=%defaultoutdp%
  if not defined toutfile set outnx=%defaultoutnx%
  if defined check if "%check%" neq "append" set check=nocheck
  if not defined check (
    if not exist "%outpath%" md "%outpath%"
    if "%outnx%" neq "" (
    	  rem remove %outfile%.prev if it exists. Works with wildcards
    	  if exist "%outfile%.prev" del "%outfile%.prev"
    	  rem if outfile exists then rename to file.ext.prev; this works with wild cards too now.
    	  if exist "%outfile%" ren "%outfile%" "%outnx%.prev"
    )
  )
  @if defined info5 echo.
  @if defined info4 echo %green%Info: outfile = %outfile%%reset%
  @call :funcend %0
  @echo %targetecho%
goto :eof

:colorvar
:: Description: Sets the inline color variables.
:: Usage: call :inlinecolor
:: Reference: https://stackoverflow.com/questions/2048509/how-to-echo-with-different-colors-in-the-windows-command-line
  @echo %supportecho%
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
  @echo %targetecho%
goto :eof

:setinfolevel
:: Description: Used for initial setup and after xrun.ini and project.txt
:: Usage: call :setinfolevel numb_level
:: Note: numb-level range 0-5
:: Purpose: create variables
:: Functions used:
:: Variables created: info1 info2 info3 info4 info5 funcstarttext funcendtext redbg magentabg green reset
  @echo %supportecho%
  for /L %%v in (1,1,5) Do set info%%v=
  rem set info levels from input
  for /L %%v in (1,1,5) Do if "%~1" geq "%%v" set info%%v=on
  @if defined info3 echo.
  if defined info3 FOR /F %%i IN ('set info') DO echo %green%Info: %%i%reset%
  if "%~1" geq "3" set clfeedback=on
  set funcstarttext={============================================================
  set funcendtext=  ----}
  @echo %targetecho%
goto :eof


:checkdir
:: Description: checks if dir exists if not it is created
:: Usage: call :checkdir C:\path\name.ext
:: Functions called: funcbegin funcend
  @echo %supportecho%
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
  @echo %targetecho%
goto :eof


