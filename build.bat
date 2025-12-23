@echo off
setlocal

set "ROOT=%~dp0"
if "%ROOT:~-1%"=="\" set "ROOT=%ROOT:~0,-1%"

set "LLVM_DIR=%ROOT%\llvm"
set "LLVM_LIB=%LLVM_DIR%\libclang.lib"
set "LLVM_DLL=%LLVM_DIR%\libclang.dll"

if not exist "%LLVM_LIB%" goto :missing
if not exist "%LLVM_DLL%" goto :missing
goto :run

:missing
echo C:/Users/curtr/Documents/GitHub/oflecs/odin-c-bindgen/libclang/CXFile.odin(23:3^) Error: Compile time panic: Download libclang 20.1.8 from here: https://github.com/llvm/llvm-project/release
echo s/download/llvmorg-20.1.8/clang+llvm-20.1.8-x86_64-pc-windows-msvc.tar.xz -- Copy the following from that archive:
echo - `lib/libclang.lib` into llvm/
echo - `bin/libclang.dll` into llvm/
echo.
echo %ROOT%
exit /b 1

:run
call "%ROOT%\build_flecs.bat"
if errorlevel 1 exit /b %errorlevel%

call "%ROOT%\ensure_libclang.bat"
if errorlevel 1 exit /b %errorlevel%

call "%ROOT%\build_bindgen.bat"
if errorlevel 1 exit /b %errorlevel%

call "%ROOT%\generate_flecs_bindings.bat"
if errorlevel 1 exit /b %errorlevel%

echo.
echo All steps completed successfully.
exit /b 0

