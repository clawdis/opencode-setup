@echo off
:: test-repair-path.bat
:: Strips Node.js from PATH then calls setup-opencode.bat --test-repair
:: so that :check_node_runtime genuinely cannot find node.
::
:: Run from: C:\Users\TechnoStar\Desktop\opencode_settup\
:: Usage:    test-repair-path.bat
setlocal EnableExtensions EnableDelayedExpansion

set "SCRIPT_DIR=%~dp0"
if "%SCRIPT_DIR:~-1%"=="\" set "SCRIPT_DIR=%SCRIPT_DIR:~0,-1%"

:: Build a PATH that strips all entries containing "nodejs" or "npm"
set "CLEAN_PATH="
for %%P in ("%PATH:;=" "%") do (
  set "_ENTRY=%%~P"
  echo !_ENTRY! | findstr /i /c:"nodejs" /c:"\npm" >nul 2>nul
  if errorlevel 1 (
    if defined CLEAN_PATH (
      set "CLEAN_PATH=!CLEAN_PATH!;%%~P"
    ) else (
      set "CLEAN_PATH=%%~P"
    )
  ) else (
    echo [test-wrapper] Stripped from PATH: %%~P
  )
)
set "PATH=!CLEAN_PATH!"

echo [test-wrapper] Verifying node is gone from stripped PATH...
where node >nul 2>nul
if errorlevel 1 (
  echo [test-wrapper] GOOD: node not in stripped PATH. Proceeding with repair simulation.
) else (
  echo [test-wrapper] WARNING: node still found in PATH even after stripping. Test may not be meaningful.
  echo [test-wrapper] Found at:
  where node
)
echo.

:: Now call the real script WITHOUT --test-repair so :refresh_node_paths runs
:: but node directories are stripped from current PATH - this tests the genuine
:: "no node in PATH, but installed on disk" scenario.
echo [test-wrapper] Calling setup-opencode.bat (no flags - genuine flow)...
echo =========================================================================
call "%SCRIPT_DIR%\setup-opencode.bat"
