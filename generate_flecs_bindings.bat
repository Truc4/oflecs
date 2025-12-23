@echo off
setlocal enabledelayedexpansion

rem ============================================================
rem generate_flecs_bindings.bat
rem 1) Run: odin-c-bindgen\bindgen.exe flecs-bindgen
rem 2) Move generated flecs.odin -> root\oflecs\flecs.odin
rem 3) Copy flecs.lib -> root\oflecs\flecs.lib
rem ============================================================

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "BINDGEN_EXE=%ROOT%\odin-c-bindgen\bindgen.exe"
set "BINDGEN_DIR=%ROOT%\odin-c-bindgen"
set "FLECS_BINDGEN_DIR=%ROOT%\flecs-bindgen"

set "OUT_DIR=%ROOT%\oflecs"
set "OUT_ODIN=%OUT_DIR%\flecs.odin"
set "OUT_LIB=%OUT_DIR%\flecs.lib"

set "SRC_LIB=%FLECS_BINDGEN_DIR%\flecs\flecs.lib"

if not exist "%BINDGEN_EXE%" (
  echo ERROR: bindgen.exe not found at:
  echo   %BINDGEN_EXE%
  exit /b 1
)

if not exist "%FLECS_BINDGEN_DIR%\." (
  echo ERROR: flecs-bindgen folder not found at:
  echo   %FLECS_BINDGEN_DIR%
  exit /b 2
)

if not exist "%OUT_DIR%\." (
  md "%OUT_DIR%" || (
    echo ERROR: Failed to create output folder:
    echo   %OUT_DIR%
    exit /b 3
  )
)

echo Running bindgen...
pushd "%BINDGEN_DIR%" >nul
"%BINDGEN_EXE%" "%FLECS_BINDGEN_DIR%"
set "RC=%errorlevel%"
popd >nul

if not "%RC%"=="0" (
  echo ERROR: bindgen failed with exit code %RC%.
  exit /b %RC%
)

rem --- Find flecs.odin under flecs-bindgen (common locations vary)
set "GEN_ODIN="

if exist "%FLECS_BINDGEN_DIR%\flecs.odin" set "GEN_ODIN=%FLECS_BINDGEN_DIR%\flecs.odin"
if "%GEN_ODIN%"=="" if exist "%FLECS_BINDGEN_DIR%\flecs\flecs.odin" set "GEN_ODIN=%FLECS_BINDGEN_DIR%\flecs\flecs.odin"

if "%GEN_ODIN%"=="" (
  for /f "delims=" %%F in ('dir /b /s "%FLECS_BINDGEN_DIR%\flecs.odin" 2^>nul') do (
    set "GEN_ODIN=%%F"
    goto :found_odin
  )
)

:found_odin
if "%GEN_ODIN%"=="" (
  echo ERROR: Could not find generated flecs.odin under:
  echo   %FLECS_BINDGEN_DIR%
  exit /b 4
)

echo Found generated Odin file:
echo   %GEN_ODIN%

rem --- Move flecs.odin to oflecs\
if exist "%OUT_ODIN%" del /f /q "%OUT_ODIN%" >nul 2>&1
move /y "%GEN_ODIN%" "%OUT_ODIN%" >nul
if errorlevel 1 (
  echo ERROR: Failed to move flecs.odin to:
  echo   %OUT_ODIN%
  exit /b 5
)

rem --- Copy flecs.lib to oflecs\
if not exist "%SRC_LIB%" (
  echo ERROR: flecs.lib not found at:
  echo   %SRC_LIB%
  echo Expected from build_flecs.bat output.
  exit /b 6
)

copy /y "%SRC_LIB%" "%OUT_LIB%" >nul
if errorlevel 1 (
  echo ERROR: Failed to copy flecs.lib to:
  echo   %OUT_LIB%
  exit /b 7
)

echo.
echo Success:
echo   %OUT_ODIN%
echo   %OUT_LIB%
echo.
exit /b 0

