@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TARGET_DIR=%USERPROFILE%\.config\opencode"
set "LOG_PREFIX=[OpenCode Setup]"

echo %LOG_PREFIX% Starting Windows setup...
echo.

call :require_source "%SCRIPT_DIR%\opencode.json"
if errorlevel 1 goto :fail

call :require_source "%SCRIPT_DIR%\opencode.jsonc"
if errorlevel 1 goto :fail

call :require_source "%SCRIPT_DIR%\.opencode"
if errorlevel 1 goto :fail

call :ensure_node
if errorlevel 1 goto :fail

call :ensure_npm
if errorlevel 1 goto :fail

call :persist_known_node_paths
call :refresh_runtime_path

echo %LOG_PREFIX% Installing or updating OpenCode with npm...
call npm install -g opencode-ai
if errorlevel 1 (
  echo %LOG_PREFIX% Failed to install opencode-ai.
  goto :fail
)

call :persist_global_npm_path
call :refresh_runtime_path

where opencode >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% OpenCode was installed but is not available in PATH yet.
  echo %LOG_PREFIX% Open a new terminal and run the script again.
  goto :fail
)

if not exist "%TARGET_DIR%" (
  echo %LOG_PREFIX% Creating global config directory...
  mkdir "%TARGET_DIR%"
  if errorlevel 1 (
    echo %LOG_PREFIX% Failed to create %TARGET_DIR%
    goto :fail
  )
)

echo %LOG_PREFIX% Copying global config files...
copy /Y "%SCRIPT_DIR%\opencode.json" "%TARGET_DIR%\opencode.json" >nul
if errorlevel 1 (
  echo %LOG_PREFIX% Failed to copy opencode.json
  goto :fail
)

copy /Y "%SCRIPT_DIR%\opencode.jsonc" "%TARGET_DIR%\opencode.jsonc" >nul
if errorlevel 1 (
  echo %LOG_PREFIX% Failed to copy opencode.jsonc
  goto :fail
)

echo %LOG_PREFIX% Copying .opencode assets into the global config directory...
robocopy "%SCRIPT_DIR%\.opencode" "%TARGET_DIR%" /E /NFL /NDL /NJH /NJS /NP /XD node_modules .git .github .cache dist build >nul
set "ROBOCOPY_EXIT=%ERRORLEVEL%"
if %ROBOCOPY_EXIT% GEQ 8 (
  echo %LOG_PREFIX% Failed to copy .opencode assets. robocopy exit code: %ROBOCOPY_EXIT%
  goto :fail
)

echo.
echo %LOG_PREFIX% Verifying installation...
call node -v
if errorlevel 1 goto :fail

call npm -v
if errorlevel 1 goto :fail

call opencode --version
if errorlevel 1 goto :fail

echo.
echo %LOG_PREFIX% Inspecting resolved OpenCode config...
call opencode debug config
if errorlevel 1 (
  echo %LOG_PREFIX% OpenCode is installed, but config verification returned an error.
  echo %LOG_PREFIX% You can still run opencode and finish provider setup with /connect.
)

echo.
echo %LOG_PREFIX% Setup complete.
echo %LOG_PREFIX% Global config directory: %TARGET_DIR%
echo %LOG_PREFIX% Next steps:
echo   1. Run: opencode
echo   2. In the TUI, run: /connect
echo   3. In a project, run: /init
goto :end

:require_source
if exist "%~1" exit /b 0
echo %LOG_PREFIX% Missing required source: %~1
exit /b 1

:ensure_node
where node >nul 2>nul
if not errorlevel 1 exit /b 0

echo %LOG_PREFIX% Node.js was not found. Installing Node.js LTS with winget...
where winget >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% winget is not available.
  echo %LOG_PREFIX% Install Node.js LTS manually, then rerun this script.
  exit /b 1
)

winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements --scope user
if errorlevel 1 (
  echo %LOG_PREFIX% winget failed to install Node.js LTS.
  exit /b 1
)

call :persist_known_node_paths
call :refresh_runtime_path

where node >nul 2>nul
if not errorlevel 1 exit /b 0

echo %LOG_PREFIX% Node.js was installed, but PATH has not refreshed in this terminal.
echo %LOG_PREFIX% Open a new terminal and rerun this script.
exit /b 1

:ensure_npm
where npm >nul 2>nul
if not errorlevel 1 exit /b 0

call :refresh_runtime_path
where npm >nul 2>nul
if not errorlevel 1 exit /b 0

echo %LOG_PREFIX% npm is not available even though Node.js is installed.
exit /b 1

:persist_known_node_paths
call :persist_node_path "%ProgramFiles%\nodejs"
if defined ProgramFiles(x86) call :persist_node_path "%ProgramFiles(x86)%\nodejs"
call :persist_node_path "%LOCALAPPDATA%\Programs\nodejs"
exit /b 0

:persist_node_path
if exist "%~1\node.exe" call :persist_path_entry "%~1"
exit /b 0

:persist_global_npm_path
set "GLOBAL_NPM_PREFIX="
for /f "usebackq delims=" %%I in (`npm prefix -g`) do set "GLOBAL_NPM_PREFIX=%%I"
if defined GLOBAL_NPM_PREFIX call :persist_path_entry "%GLOBAL_NPM_PREFIX%"
exit /b 0

:persist_path_entry
set "PATH_ENTRY=%~1"
if not exist "%PATH_ENTRY%" exit /b 0

echo ;%PATH%; | find /I ";%PATH_ENTRY%;" >nul
if errorlevel 1 set "PATH=%PATH_ENTRY%;%PATH%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$entry = [System.IO.Path]::GetFullPath($env:PATH_ENTRY); $userPath = [Environment]::GetEnvironmentVariable('Path','User'); $parts = @(); if ($userPath) { $parts = $userPath -split ';' | Where-Object { $_ } }; if ($parts -notcontains $entry) { $newPath = @($parts + $entry) -join ';'; [Environment]::SetEnvironmentVariable('Path', $newPath, 'User') }" >nul
exit /b 0

:refresh_runtime_path
call :prepend_runtime_path "%ProgramFiles%\nodejs"
if defined ProgramFiles(x86) call :prepend_runtime_path "%ProgramFiles(x86)%\nodejs"
call :prepend_runtime_path "%LOCALAPPDATA%\Programs\nodejs"
call :prepend_runtime_path "%APPDATA%\npm"
exit /b 0

:prepend_runtime_path
if not exist "%~1" exit /b 0
echo ;%PATH%; | find /I ";%~1;" >nul
if errorlevel 1 set "PATH=%~1;%PATH%"
exit /b 0

:fail
echo.
echo %LOG_PREFIX% Setup did not complete.

:end
echo.
pause
endlocal
