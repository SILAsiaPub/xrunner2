call :pre
call :getfile cms/USX_Views_hide.cms
call :tests
goto :eof

:getfile
  @echo.
  @set winfile=%~1
  @set outfile=%installpath%\%winfile:/=\%
  rem @call curl -o "%outfile%" --ssl-no-revoke %url-base%/%winfile%
  @call curl --ssl-no-revoke %url-base%/%winfile% |more /P > "%outfile%" 
  @FOR /F "usebackq" %%A IN ('%outfile%') DO @set size=%%~zA
  if %size%. == 14. (
    @echo %redbg%Error: %winfile% not found at %url-base%.%reset%
  ) else (
    @if exist "%outfile%" echo %green%Updated: %winfile%  %reset%
  )
@goto :eof

:tests
@Echo %green%           Original file size = %size1%%reset%
@Echo %green%Downloaded modified file size = %size%%reset%
@set /a expectedsize=%size1%+2
if %size% == %expectedsize% (
  @echo %green%Valid: Downloaded file is the expected size.%reset%&@echo %green%Downloaded files had lf modified to crlf. The expected size is two code points bigger than the original.%reset%
) else (
  @echo %redbg%Invalid: Downloaded file is not the expected size!%reset%
)
@goto :eof

:pre
echo off
cls
set size1=
set size=
set installpath=C:\Users\Public\PT-Bamboo-Views
set viewsaction=user-views-action.cmd
set url-base=https://raw.githubusercontent.com/sillsdev/PT-Views/master/Bamboo
@set redbg=[101m
@set magentabg=[105m
@set magenta=[35m
@set green=[32m
@set reset=[0m
echo on
@FOR /F "usebackq" %%A IN ('cms\USX_Views_hide.cms') DO @set size1=%%~zA
@goto :eof

