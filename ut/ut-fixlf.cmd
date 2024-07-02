call :fixlf USX_Views_show.cms
goto :eof

:fixlf
set curfile=%~1
set ext=%~x1
if .%ext% == ..cms (
  more /P < %curfile% > tmp.txt
  ren /y tmp.txt %curfile%
)
goto :eof
