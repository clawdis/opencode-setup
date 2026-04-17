@echo off
setlocal EnableExtensions

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TARGET_DIR=%USERPROFILE%\.config\opencode"
set "LOG_PREFIX=[OpenCode Setup]"
set "GLOBAL_NPM_PREFIX="

echo %LOG_PREFIX% Starting Windows setup...
echo.

if not exist "%SCRIPT_DIR%\opencode.json" (
  echo %LOG_PREFIX% Missing required source: %SCRIPT_DIR%\opencode.json
  goto :fail
)

if not exist "%SCRIPT_DIR%\opencode.jsonc" (
  echo %LOG_PREFIX% Missing required source: %SCRIPT_DIR%\opencode.jsonc
  goto :fail
)

if not exist "%SCRIPT_DIR%\.opencode" (
  echo %LOG_PREFIX% Missing required source: %SCRIPT_DIR%\.opencode
  goto :fail
)

where node >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% Node.js was not found. Installing Node.js LTS with winget...

  where winget >nul 2>nul
  if errorlevel 1 (
    echo %LOG_PREFIX% winget is not available.
    echo %LOG_PREFIX% Install Node.js LTS manually, then rerun this script.
    goto :fail
  )

  winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements --scope user
  if errorlevel 1 (
    echo %LOG_PREFIX% winget failed to install Node.js LTS.
    goto :fail
  )
)

set "PATH=%ProgramFiles%\nodejs;%LOCALAPPDATA%\Programs\nodejs;%PATH%"

powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths = @('%ProgramFiles%\nodejs','%LOCALAPPDATA%\Programs\nodejs'); $userPath = [Environment]::GetEnvironmentVariable('Path','User'); $parts = @(); if ($userPath) { $parts = $userPath -split ';' | Where-Object { $_ } }; foreach ($candidate in $paths) { if (Test-Path $candidate) { $full = [System.IO.Path]::GetFullPath($candidate); if ($parts -notcontains $full) { $parts += $full } } }; [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')" >nul

where node >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% Node.js is still not available in PATH.
  echo %LOG_PREFIX% Open a new terminal and rerun this script.
  goto :fail
)

where npm >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% npm is not available even though Node.js is installed.
  goto :fail
)

echo %LOG_PREFIX% Installing or updating OpenCode with npm...
call npm install -g opencode-ai
if errorlevel 1 (
  echo %LOG_PREFIX% Failed to install opencode-ai.
  goto :fail
)

for /f "usebackq delims=" %%I in (`npm prefix -g`) do set "GLOBAL_NPM_PREFIX=%%I"
if defined GLOBAL_NPM_PREFIX (
  set "PATH=%GLOBAL_NPM_PREFIX%;%PATH%"
  powershell -NoProfile -ExecutionPolicy Bypass -Command "$candidate = '%GLOBAL_NPM_PREFIX%'; if (Test-Path $candidate) { $full = [System.IO.Path]::GetFullPath($candidate); $userPath = [Environment]::GetEnvironmentVariable('Path','User'); $parts = @(); if ($userPath) { $parts = $userPath -split ';' | Where-Object { $_ } }; if ($parts -notcontains $full) { $parts += $full; [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User') } }" >nul
)

where opencode >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX% OpenCode was installed but is not available in PATH yet.
  echo %LOG_PREFIX% Open a new terminal and rerun this script.
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
if errorlevel 8 (
  echo %LOG_PREFIX% Failed to copy .opencode assets.
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
echo %LOG_PREFIX% Verifying copied config files...
if not exist "%TARGET_DIR%\opencode.json" (
  echo %LOG_PREFIX% Missing copied file: %TARGET_DIR%\opencode.json
  goto :fail
)

if not exist "%TARGET_DIR%\opencode.jsonc" (
  echo %LOG_PREFIX% Missing copied file: %TARGET_DIR%\opencode.jsonc
  goto :fail
)

if not exist "%TARGET_DIR%\plugins\agent-validator.ts" (
  echo %LOG_PREFIX% Missing copied plugin file: %TARGET_DIR%\plugins\agent-validator.ts
  goto :fail
)

if not exist "%TARGET_DIR%\skills\brainstorming\SKILL.md" (
  echo %LOG_PREFIX% Missing copied skill file: %TARGET_DIR%\skills\brainstorming\SKILL.md
  goto :fail
)

echo.
echo %LOG_PREFIX% Setup complete.
echo %LOG_PREFIX% Global config directory: %TARGET_DIR%
echo %LOG_PREFIX% Next steps:
echo   1. Run: opencode
echo   2. In the TUI, run: /connect
echo   3. In a project, run: /init
goto :end

:fail
echo.
echo %LOG_PREFIX% Setup did not complete.

:end
echo.
pause
endlocal
