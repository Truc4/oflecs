@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem build_flecs.bat
rem Builds flecs as a STATIC lib and copies:
rem   - flecs.lib  -> root\flecs-bindgen\flecs\flecs.lib
rem   - flecs.h    -> root\flecs-bindgen\flecs.h   (from flecs\distr\flecs.h)
rem ============================================================

rem --- Repo root (folder this script lives in)
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "FLECS_DIR=%ROOT%\flecs"

rem --- Output layout
set "OUT_ROOT=%ROOT%\flecs-bindgen"
set "OUT_LIB_DIR=%OUT_ROOT%\flecs"
set "OUT_LIB=%OUT_LIB_DIR%\flecs.lib"
set "OUT_HDR=%OUT_ROOT%\flecs.h"

if not exist "%FLECS_DIR%\CMakeLists.txt" (
  echo ERROR: "%FLECS_DIR%\CMakeLists.txt" not found.
  exit /b 2
)

rem --- Ensure output dirs exist
if not exist "%OUT_ROOT%" md "%OUT_ROOT%" || exit /b 3
if not exist "%OUT_LIB_DIR%" md "%OUT_LIB_DIR%" || exit /b 3

rem --- Defaults
set "GEN=Visual Studio 17 2022"
set "ARCH=x64"
set "CONFIG=Release"

rem --- Temp build dir
set "BUILD_DIR=%TEMP%\flecs_build_%RANDOM%_%RANDOM%"
echo Using temporary build dir: %BUILD_DIR%
md "%BUILD_DIR%" || exit /b 4

rem --- Configure
cmake -S "%FLECS_DIR%" -B "%BUILD_DIR%" -G "%GEN%" -A %ARCH% ^
  -DFLECS_STATIC=ON -DFLECS_SHARED=OFF -DFLECS_PIC=OFF ^
  -DCMAKE_POLICY_DEFAULT_CMP0091=NEW ^
  -DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded
if errorlevel 1 (
  rd /s /q "%BUILD_DIR%" 2>nul
  exit /b 5
)

rem --- Build
set "BUILT=0"
cmake --build "%BUILD_DIR%" --config %CONFIG% --target flecs_static >nul 2>&1
if not errorlevel 1 set "BUILT=1"

if "!BUILT!"=="0" (
  cmake --build "%BUILD_DIR%" --config %CONFIG% --target flecs >nul 2>&1
  if not errorlevel 1 set "BUILT=1"
)

if "!BUILT!"=="0" (
  cmake --build "%BUILD_DIR%" --config %CONFIG%
  if not errorlevel 1 set "BUILT=1"
)

if "!BUILT!"=="0" exit /b 6

rem --- Locate flecs.lib
set "LIB_PATH="
if exist "%BUILD_DIR%\%CONFIG%\flecs_static.lib" set "LIB_PATH=%BUILD_DIR%\%CONFIG%\flecs_static.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\%CONFIG%\flecs.lib" set "LIB_PATH=%BUILD_DIR%\%CONFIG%\flecs.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\Release\flecs_static.lib" set "LIB_PATH=%BUILD_DIR%\Release\flecs_static.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\Release\flecs.lib" set "LIB_PATH=%BUILD_DIR%\Release\flecs.lib"

if "%LIB_PATH%"=="" (
  for /f "delims=" %%F in ('dir /b /s "%BUILD_DIR%\flecs_static.lib" 2^>nul') do (set "LIB_PATH=%%F" & goto :found)
  for /f "delims=" %%F in ('dir /b /s "%BUILD_DIR%\flecs.lib" 2^>nul') do (set "LIB_PATH=%%F" & goto :found)
)

:found
if "%LIB_PATH%"=="" exit /b 7

rem --- flecs.h from distr\
set "HDR_PATH=%FLECS_DIR%\distr\flecs.h"
if not exist "%HDR_PATH%" (
  echo ERROR: Missing "%HDR_PATH%"
  exit /b 8
)

rem --- Copy outputs
echo LIB_PATH=%LIB_PATH%
dir "%LIB_PATH%"
copy /y "%LIB_PATH%" "%OUT_LIB%" >nul || exit /b 9
copy /y "%HDR_PATH%" "%OUT_HDR%" >nul || exit /b 10

rd /s /q "%BUILD_DIR%" 2>nul

echo Success:
echo   %OUT_LIB%
echo   %OUT_HDR%

endlocal
exit /b 0
