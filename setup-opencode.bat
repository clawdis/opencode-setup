@echo off
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"
set "TARGET_DIR=%USERPROFILE%\.config\opencode"
set "LOG_PREFIX=[OpenCode Setup]"
set "GLOBAL_NPM_PREFIX="
set "NODE_RUNTIME_READY=0"
set "TEST_REPAIR_MODE=0"

:: == Parse flags ==============================================================
:parse_args
if /i "%~1"=="--test-repair" (
  set "TEST_REPAIR_MODE=1"
  echo %LOG_PREFIX% [TEST-MODE] --test-repair: skipping path refresh to simulate missing Node.js.
  shift
  goto :parse_args
)
if not "%~1"=="" shift & goto :parse_args

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

:: == Node.js readiness check ==================================================
::
:: Design intent:
::   1. refresh_node_paths adds standard Node.js install dirs to PATH so that
::      "node installed but not in user PATH" does NOT trigger a winget repair.
::   2. Only a genuine missing installation (not found even after refresh)
::      triggers the winget repair branch.
::   3. --test-repair skips step 1 so QA can force the repair path without
::      uninstalling Node.js.
::
if "!TEST_REPAIR_MODE!"=="1" (
  echo %LOG_PREFIX% [TEST-MODE] Skipping initial path refresh.
) else (
  call :refresh_node_paths
)
call :check_node_runtime
echo %LOG_PREFIX% Node runtime check result: NODE_RUNTIME_READY=!NODE_RUNTIME_READY!

if not "!NODE_RUNTIME_READY!"=="1" (
  echo %LOG_PREFIX% Node.js or npm is not ready. Repairing or installing Node.js LTS via winget...

  where winget >nul 2>nul
  if errorlevel 1 (
    echo %LOG_PREFIX% ERROR: winget is not available on this system.
    echo %LOG_PREFIX% Install Node.js LTS manually from https://nodejs.org then rerun this script.
    goto :fail
  )

  winget install --id OpenJS.NodeJS.LTS -e --accept-package-agreements --accept-source-agreements --scope user --force
  if errorlevel 1 (
    echo %LOG_PREFIX% ERROR: winget failed to repair or install Node.js LTS.
    goto :fail
  )

  call :refresh_node_paths
  call :check_node_runtime
  echo %LOG_PREFIX% Post-repair check result: NODE_RUNTIME_READY=!NODE_RUNTIME_READY!
  if not "!NODE_RUNTIME_READY!"=="1" (
    echo %LOG_PREFIX% ERROR: Node.js and npm are still unavailable after repair.
    echo %LOG_PREFIX% Open a new terminal and rerun this script so PATH changes take effect.
    goto :fail
  )
  echo %LOG_PREFIX% Node.js repair succeeded.
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
  echo %LOG_PREFIX% OpenCode was installed but is not in PATH yet.
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

:: == :refresh_node_paths ======================================================
::
:: Adds well-known Node.js install directories to the current-process PATH.
:: This ensures node/npm are findable even when the user never added them
:: to their system PATH manually.
::
:: NOTE: Intentionally called BEFORE :check_node_runtime so that
::       "node installed but not in PATH" does NOT trigger a winget repair.
::       Only a genuine missing installation triggers repair.
::
:refresh_node_paths
set "_ADDED_PATHS="
for %%D in ("%ProgramFiles%\nodejs" "%LOCALAPPDATA%\Programs\nodejs") do (
  if exist "%%~D" (
    set "PATH=%%~D;!PATH!"
    set "_ADDED_PATHS=!_ADDED_PATHS! %%~D"
  )
)
if defined _ADDED_PATHS (
  echo %LOG_PREFIX% Path refresh: added!_ADDED_PATHS!
) else (
  echo %LOG_PREFIX% Path refresh: no standard Node.js install dirs found on disk.
)
:: Persist to user PATH via PowerShell (best-effort, silent)
powershell -NoProfile -ExecutionPolicy Bypass -Command "$paths = @('%ProgramFiles%\nodejs','%LOCALAPPDATA%\Programs\nodejs'); $userPath = [Environment]::GetEnvironmentVariable('Path','User'); $parts = @(); if ($userPath) { $parts = $userPath -split ';' | Where-Object { $_ } }; foreach ($candidate in $paths) { if (Test-Path $candidate) { $full = [System.IO.Path]::GetFullPath($candidate); if ($parts -notcontains $full) { $parts += $full } } }; [Environment]::SetEnvironmentVariable('Path', ($parts -join ';'), 'User')" >nul
exit /b 0

:: == :check_node_runtime ======================================================
::
:: Sets NODE_RUNTIME_READY=1 only when BOTH node AND npm respond.
:: Sets NODE_RUNTIME_READY=0 (and returns early) if either is missing.
::
:check_node_runtime
set "NODE_RUNTIME_READY=0"
call node -v >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX%   [check] node: NOT FOUND
  exit /b 0
)
echo %LOG_PREFIX%   [check] node: OK
call npm -v >nul 2>nul
if errorlevel 1 (
  echo %LOG_PREFIX%   [check] npm:  NOT FOUND
  exit /b 0
)
echo %LOG_PREFIX%   [check] npm:  OK
set "NODE_RUNTIME_READY=1"
exit /b 0

:fail
echo.
echo %LOG_PREFIX% Setup did not complete.

:end
echo.
pause
endlocal
