@echo off
setlocal

rem --- Repo root
set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

rem --- Source files (your layout)
set "SRC_DIR=%ROOT%\llvm"
set "SRC_LIB=%SRC_DIR%\libclang.lib"
set "SRC_DLL=%SRC_DIR%\libclang.dll"

rem --- Submodule layout (what odin-c-bindgen expects)
set "SUBMOD=%ROOT%\odin-c-bindgen"
set "DEST_LIB_DIR=%SUBMOD%\libclang"
set "DEST_LIB=%DEST_LIB_DIR%\libclang.lib"

rem DLL must be next to bindgen.exe (root of generator = submodule root)
set "DEST_DLL=%SUBMOD%\libclang.dll"

if not exist "%SRC_LIB%" (
  echo ERROR: Missing "%SRC_LIB%"
  echo Put libclang.lib in: %SRC_DIR%
  exit /b 1
)

if not exist "%SRC_DLL%" (
  echo ERROR: Missing "%SRC_DLL%"
  echo Put libclang.dll in: %SRC_DIR%
  exit /b 2
)

if not exist "%DEST_LIB_DIR%" (
  md "%DEST_LIB_DIR%" || (
    echo ERROR: Failed to create "%DEST_LIB_DIR%"
    exit /b 3
  )
)

copy /y "%SRC_LIB%" "%DEST_LIB%" >nul || (
  echo ERROR: Failed to copy libclang.lib to "%DEST_LIB%"
  exit /b 4
)

copy /y "%SRC_DLL%" "%DEST_DLL%" >nul || (
  echo ERROR: Failed to copy libclang.dll to "%DEST_DLL%"
  exit /b 5
)

echo libclang installed in submodule:
echo   %DEST_LIB%
echo   %DEST_DLL%
exit /b 0

