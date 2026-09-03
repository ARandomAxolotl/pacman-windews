@echo off
setlocal enabledelayedexpansion

if exist "%~dp0lock.lck" (
  echo Lockfile found!
  exit /b 1
)

set "verb=%~1"
set /a i=0

:ParserLoop
if "!verb:~%i%,1!"=="" goto ParserDone

set "Arg=!verb:~%i%,1!"

if "!Arg!"=="-" set "Do=1"

if defined Do (
  if not defined Run (
    if "!Arg!"=="S" ( 
      echo Sync>> "%~dp0lock.lck"
      set Run=Sync
    )

    if "!Arg!"=="Q" (
      echo Query>> "%~dp0lock.lck"
      set Run=Query
    )
  )
)

if "!Run!"=="Sync" (
  if "!Arg!"=="y" echo Database>> "%~dp0lock.lck"
  if "!Arg!"=="u" echo UpdateAll>> "%~dp0lock.lck"
  if "!Arg!"=="i" echo Info>> "%~dp0lock.lck"
)

if "!Run!"=="Query" (
  if "!Arg!"=="i" echo Info>> "%~dp0lock.lck"
)

set /a i+=1
goto ParserLoop

:ParserDone

shift
:PkgParseLoop
if "%~1"=="" goto PkgParseDone
set "pkg=%pkg% %~1"
shift
goto PkgParseLoop

:PkgParseDone

for /f "tokens=*" %%A in ('type "%~dp0lock.lck"') do set "%%A=1"

if "%Sync%"=="1" (
  if "%UpdateAll%"=="1" (
    echo Running : winget upgrade --all --source winget --silent --accept-source-agreements  --accept-package-agreements 
    winget upgrade --all --source winget --silent --accept-source-agreements  --accept-package-agreements
    if not "%pkg%"=="" (
      echo Running : winget install --source winget --silent --accept-source-agreements  --accept-package-agreements %pkg%
      winget install --source winget --silent --accept-source-agreements --accept-package-agreements %pkg%
    )
  else if "%Info%"=="1"(
    echo Running : winget show --accept-source-agreements %pkg%
    winget show --accept-source-agreements %pkg%
  ) else (
    if not "%pkg%"=="" (
      echo Running : winget install --source winget --silent --accept-source-agreements  --accept-package-agreements %pkg%
      winget install --source winget --silent --accept-source-agreements --accept-package-agreements %pkg%
    ) else (
      echo No package provided :(
    )
  )
)

if "%Query%"=="1" (
  if "%Info%"=="1" (
    echo Running : winget show --accept-source-agreements %pkg%
    winget show --accept-source-agreements %pkg%
  ) else if not "%pkg%"=="" (
    echo Running : winget list --query %pkg%
    winget list --query %pkg%
  ) else (
    echo Running : winget list
    winget list
  )
)

del "%~dp0lock.lck"
