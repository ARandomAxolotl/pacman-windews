@echo off
setlocal enabledelayedexpansion
chcp 65001 >nul

for /F "delims=" %%A in ('echo prompt $E^| cmd') do set "esc=%%A"

set "reset=%esc%[0m"

set "bold=%esc%[1m"
set "underline=%esc%[4m"

set "red=%esc%[91m"
set "green=%esc%[92m"
set "yellow=%esc%[93m"
set "blue=%esc%[94m"
set "cyan=%esc%[96m"
set "white=%esc%[97m"

if exist "%~dp0lock.lck" (
  echo Lockfile found!
  exit /b 1
)

if "%*"=="" goto :GetHelp

set "verb=%~1"
set /a i=0

:ParserLoop
if "!verb:~%i%,1!"=="" goto ParserDone

if "!verb!"=="--help" goto :GetHelp

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

    if "!Arg!"=="R" (
      echo Remove>> "%~dp0lock.lck"
      set Run=Remove
    )

    if "!Arg!"=="h" (
      goto :GetHelp
    )
  )
)

if "!Run!"=="Sync" (
  if "!Arg!"=="y" echo Database>> "%~dp0lock.lck"
  if "!Arg!"=="u" echo UpdateAll>> "%~dp0lock.lck"
  if "!Arg!"=="i" echo Info>> "%~dp0lock.lck"
  if "!Arg!"=="s" echo Search>> "%~dp0lock.lck"
)

if "!Run!"=="Query" (
  if "!Arg!"=="i" echo Info>> "%~dp0lock.lck"
)

if "!Run!"=="Remove" (
  rem Idk what to do with ts
)

if "!Arg!"=="v" (
  @echo on
  set "_prompt_=%prompt%"
  set "prompt=$T> "
  echo MizukiInvestigating >> "%~dp0lock.lck"

  set "transBLUE=%esc%[38;2;91;206;250m"
  set "transPINK=%esc%[38;2;245;169;184m"
  set "transWHITE=%esc%[38;2;255;255;255m"

  echo %underline%%transBLUE%Aki%transPINK%yama%transWHITE% Mizu%transPINK%ki%reset% is%transBLUE% %underline%%bold%tuff%reset%
  
) 

set /a i+=1
goto ParserLoop

:ParserDone

if not exist "%~dp0lock.lck" (
  echo Sync>> "%~dp0lock.lck"
  echo Search>> "%~dp0lock.lck"
) else (
  shift
)

set "pkg=%~1"

shift

:PkgParseLoop
if "%~1"=="" goto PkgParseDone
set "pkg=%pkg% %~1"
shift
goto PkgParseLoop

:PkgParseDone

for /f "tokens=*" %%A in ('type "%~dp0lock.lck"') do set "%%A=1"

if "%Sync%"=="1" (

  set DoInstall=1

  if "%UpdateAll%"=="1" (
    echo %green% Running : %reset% %yellow% winget upgrade --all --source winget --silent --accept-source-agreements  --accept-package-agreements %RESET%
   
    choice /M "Proceed"
    if errorlevel 2 goto :ErrFinish

    winget upgrade --all --source winget --silent --accept-source-agreements  --accept-package-agreements

    if not "%pkg%"=="" (
      echo %green% Running : %reset% %yellow% winget install --source winget --silent --accept-source-agreements  --accept-package-agreements %pkg% %RESET%

      choice /M "Proceed"
      if errorlevel 2 goto :ErrFinish

      winget install --source winget --silent --accept-source-agreements --accept-package-agreements %pkg%
    )
    set DoInstall=0
  )
  
  if "%Info%"=="1" (
    echo %green% Running : %reset% %yellow% winget show --accept-source-agreements %pkg% %reset%
    winget show --accept-source-agreements %pkg%
    set DoInstall=0
  )

  if "%Search%"=="1" (
    if not "%pkg%"=="" (
      echo %green% Running : %reset% %yellow% winget search --query %pkg% %reset%
      winget search --query %pkg%
    ) else (
      echo %green% Running : %reset% %yellow% winget search --query "" %reset%
      winget search --query ^"^"
    )
    set DoInstall=0
  )

  if "%Database%"=="1" (
    echo %green% Running : %reset% %yellow% winget source update --disable-interactivity %reset%
    winget source update --disable-interactivity
  )

  if "!DoInstall!"=="1" (
    if not "%pkg%"=="" (
      echo %green% Running : %reset% %yellow% winget install --source winget --silent --accept-source-agreements  --accept-package-agreements %pkg% %reset%

      choice /M "Proceed"
      if errorlevel 2 goto :ErrFinish

      winget install --source winget --silent --accept-source-agreements --accept-package-agreements %pkg%
    ) else (
      echo %red% No package provided :( %reset%
    )
  )
)

if "%Query%"=="1" (
  if "%Info%"=="1" (
    echo %green% Running : %reset% %yellow% winget show --accept-source-agreements %pkg% %reset%
    winget show --accept-source-agreements %pkg%
  ) else if not "%pkg%"=="" (
    echo %green% Running : %reset% %yellow% winget list --query %pkg% %reset%
    winget list --query %pkg%
  ) else (
    echo %green% Running : %reset% %yellow% winget list %reset%
    winget list
  )
)

if "%Remove%"=="1" (
  if not "%pkg%"=="" (
    echo Running : winget uninstall --silent --accept-source-agreements --all-versions %pkg%

    choice /M "Proceed"
    if errorlevel 2 goto :ErrFinish

    winget uninstall --silent --accept-source-agreements --all-versions %pkg%
  ) else (
    echo nothing to remove :(
  )
)

del "%~dp0lock.lck"
set "prompt=%_prompt_%"
endlocal
exit /b

:GetHelp
echo !cyan!!bold!%~nx0!reset! [Command] [Packages]
echo.
echo !yellow!!bold!Commands :!reset!
echo !green!-S[yuis]!reset! !cyan![package]!reset! -^> Install [package]
echo !white!├──!reset! !green!y!reset! -^> update database
echo !white!│  !reset!   !yellow!Tip :!reset! This is not required as winget will automatically do
echo !white!├──!reset! !green!u!reset! -^> upgrade system
echo !white!│  !reset!   !yellow!Tip :!reset! %~nx0 -Su [package] to upgrade system then install [package]
echo !white!├──!reset! !green!i!reset! -^> show information about [package]
echo !white!└──!reset! !green!s!reset! -^> search for [package]
echo !white!   !reset!   !yellow!Tip :!reset! %~nx0 [package] to search for [package]
echo.
echo !green!-Q[i]!reset! !cyan![package]!reset! -^> Query [package]
echo !white!└──!reset! !green!i!reset! -^> show information about an installed package
echo !white!   !reset!   !yellow!Tip :!reset! provide no package will list installed package
echo.
echo !red!-R!reset! !cyan![package]!reset! -^> Uninstall [package]
echo.
echo !green!-h, --help!reset! -^> show this help message
echo.
echo !green!-v!reset! -^> verbose mode
exit /b

:ErrFinish
del "%~dp0lock.lck"
set "prompt=%_prompt_%"
endlocal
exit /b 1
