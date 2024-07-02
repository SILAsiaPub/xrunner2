
@echo off
cls
call :colorvar
call :setinfolevel 3
set projectpath=D:\All-SIL-Publishing\_xrunner2_projects\_GPS\GPS-ES\EXGSUM64JN1-ver2
call :appendfile "%projectpath%\tmp\dateout.txt" "..\tmp\test.txt"
call :appendfile "%projectpath%\tmp\epubrpt.txt" "..\tmp\test.txt"
call :appendfile "%projectpath%\tmp\epub-old-report.txt" "..\tmp\test.txt"

goto :eof

:appendfile
:: Description: Appends one file to the end of another file.
:: Usage: call :appendfile filetoadd filetoappendto
:: Purpose: append file
:: Functions called: funcbegin funcend 
  if defined fatal goto :eof
  @call :funcbegin %0 "'%~1' '%~2' '%~3'"
  call :infile "%~1" %0
  call :outfile "%~2" "%projectpath%\tmp\%group%-%count%-appendfile.xml" nocheck
  rem if not exist "%outfile%" copy nul "%outfile%"
  rem if not exist "%infile%" call :funcend %0 "Warning: File to append does not exist. File: %~1" & pause & goto :eof
  if exist "%infile%" (
    @if defined info2 echo %green%Appending file '%~nx1`' to '%~nx2'%reset%
    type "%infile%" >> "%outfile%"
    )
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
goto :eof

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


