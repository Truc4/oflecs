@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem build_flecs.bat
rem Builds flecs as a STATIC lib and copies:
rem   - flecs.lib  -> root\flecs-bindgen\flecs\flecs.lib
rem   - flecs.h    -> root\flecs-bindgen\flecs.h
rem   - headers    -> root\flecs-bindgen\flecs\*  (for #include <flecs/...>)
rem ============================================================

rem --- Repo root (folder this script lives in)
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "FLECS_DIR=%ROOT%\flecs"

rem --- Output layout (requested)
set "OUT_ROOT=%ROOT%\flecs-bindgen"
set "OUT_LIB_DIR=%OUT_ROOT%\flecs"
set "OUT_LIB=%OUT_LIB_DIR%\flecs.lib"
set "OUT_HDR=%OUT_ROOT%\flecs.h"

if not exist "%FLECS_DIR%\CMakeLists.txt" (
  echo ERROR: "%FLECS_DIR%\CMakeLists.txt" not found.
  exit /b 2
)

rem --- Ensure output dirs exist (both levels)
if not exist "%OUT_ROOT%" (
  md "%OUT_ROOT%" || (
    echo ERROR: Failed to create "%OUT_ROOT%".
    exit /b 3
  )
)
if not exist "%OUT_LIB_DIR%" (
  md "%OUT_LIB_DIR%" || (
    echo ERROR: Failed to create "%OUT_LIB_DIR%".
    exit /b 3
  )
)

rem --- Defaults
set "GEN=Visual Studio 17 2022"
set "ARCH=x64"
set "CONFIG=Release"

rem --- Temp build dir
set "BUILD_DIR=%TEMP%\flecs_build_%RANDOM%_%RANDOM%"
echo Using temporary build dir: %BUILD_DIR%
md "%BUILD_DIR%" || (
  echo ERROR: Failed to create build directory "%BUILD_DIR%".
  exit /b 4
)

rem --- Configure
cmake -S "%FLECS_DIR%" -B "%BUILD_DIR%" -G "%GEN%" -A %ARCH% ^
  -DFLECS_STATIC=ON -DFLECS_SHARED=OFF -DFLECS_PIC=OFF
if errorlevel 1 (
  echo ERROR: CMake configuration failed.
  rd /s /q "%BUILD_DIR%" 2>nul
  exit /b 5
)

rem --- Build (try targets)
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

if "!BUILT!"=="0" (
  echo ERROR: Build failed. Build dir retained at: %BUILD_DIR%
  exit /b 6
)

rem --- Find built .lib
set "LIB_PATH="

if exist "%BUILD_DIR%\%CONFIG%\flecs_static.lib" set "LIB_PATH=%BUILD_DIR%\%CONFIG%\flecs_static.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\%CONFIG%\flecs.lib" set "LIB_PATH=%BUILD_DIR%\%CONFIG%\flecs.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\Release\flecs_static.lib" set "LIB_PATH=%BUILD_DIR%\Release\flecs_static.lib"
if "%LIB_PATH%"=="" if exist "%BUILD_DIR%\Release\flecs.lib" set "LIB_PATH=%BUILD_DIR%\Release\flecs.lib"

if "%LIB_PATH%"=="" (
  for /f "delims=" %%F in ('dir /b /s "%BUILD_DIR%\flecs_static.lib" 2^>nul') do (
    set "LIB_PATH=%%F"
    goto :found_lib
  )
  for /f "delims=" %%F in ('dir /b /s "%BUILD_DIR%\flecs.lib" 2^>nul') do (
    set "LIB_PATH=%%F"
    goto :found_lib
  )
)

:found_lib
if "%LIB_PATH%"=="" (
  echo ERROR: Could not find a built flecs .lib in build output.
  echo Build dir retained at: %BUILD_DIR%
  exit /b 7
)

rem --- Find flecs.h
set "HDR_PATH=%FLECS_DIR%\include\flecs.h"
if not exist "%HDR_PATH%" (
  set "HDR_PATH="
  for /f "delims=" %%H in ('dir /b /s "%FLECS_DIR%\flecs.h" 2^>nul') do (
    set "HDR_PATH=%%H"
    goto :found_hdr
  )
)

:found_hdr
if "%HDR_PATH%"=="" (
  echo ERROR: Could not find flecs.h under: %FLECS_DIR%
  echo Build dir retained at: %BUILD_DIR%
  exit /b 8
)

rem --- Copy to EXACT requested paths
copy /y "%LIB_PATH%" "%OUT_LIB%" >nul || (
  echo ERROR: Failed to copy library to "%OUT_LIB%".
  echo Build dir retained at: %BUILD_DIR%
  exit /b 9
)

copy /y "%HDR_PATH%" "%OUT_HDR%" >nul || (
  echo ERROR: Failed to copy header to "%OUT_HDR%".
  echo Build dir retained at: %BUILD_DIR%
  exit /b 10
)

rem --- Copy header tree so clang can resolve #include <flecs/...>
rem Copies: flecs\include\flecs\* -> flecs-bindgen\flecs\*
if not exist "%FLECS_DIR%\include\flecs\." (
  echo ERROR: Missing include tree at "%FLECS_DIR%\include\flecs\"
  echo Build dir retained at: %BUILD_DIR%
  exit /b 11
)

xcopy "%FLECS_DIR%\include\flecs" "%OUT_LIB_DIR%\" /E /I /Y >nul
if errorlevel 1 (
  echo ERROR: Failed to copy flecs include tree to "%OUT_LIB_DIR%".
  echo Build dir retained at: %BUILD_DIR%
  exit /b 12
)

rem --- Cleanup
rd /s /q "%BUILD_DIR%" 2>nul

echo Success:
echo   %OUT_LIB%
echo   %OUT_HDR%
echo   (and copied headers to %OUT_LIB_DIR%\...)

endlocal
exit /b 0
