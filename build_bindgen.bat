@echo off
setlocal

rem --- Repo root
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "SUBMOD=%ROOT%\odin-c-bindgen"
set "SRC_DIR=%SUBMOD%\src"

rem --- libclang layout (as required)
set "CLANG_LIB=%SUBMOD%\libclang\libclang.lib"
set "CLANG_DLL=%SUBMOD%\libclang.dll"

rem --- Build output (keep exe + dll together)
set "OUT_EXE=%SUBMOD%\bindgen.exe"

if not exist "%SRC_DIR%" (
  echo ERROR: Not found: %SRC_DIR%
  exit /b 1
)

where odin >nul 2>&1
if errorlevel 1 (
  echo ERROR: odin.exe not found in PATH
  exit /b 2
)

if not exist "%CLANG_LIB%" (
  echo ERROR: Missing libclang.lib
  echo Expected at: %CLANG_LIB%
  exit /b 3
)

if not exist "%CLANG_DLL%" (
  echo ERROR: Missing libclang.dll
  echo Expected at: %CLANG_DLL%
  exit /b 4
)

pushd "%SUBMOD%" || exit /b 5
odin build "%SRC_DIR%" -out:"%OUT_EXE%"
set "RC=%errorlevel%"
popd

if not "%RC%"=="0" (
  echo ERROR: Odin build failed
  exit /b %RC%
)

echo Success: %OUT_EXE%
exit /b 0
