@echo off
if "%VS110COMNTOOLS%" == "" (
  msg "%username%" "Visual Studio 11 not detected"
  exit 1
)

call "%VS110COMNTOOLS%\..\..\VC\vcvarsall.bat"

@mkdir 12bit
@mkdir 10bit
@mkdir 8bit

@cd 12bit
cmake -G "Visual Studio 11 Win64" ../../../source -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF -DMAIN12=ON
if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
  copy/y Release\x265-static.lib ..\8bit\x265-static-main12.lib
)

@cd ..\10bit
cmake -G "Visual Studio 11 Win64" ../../../source -DHIGH_BIT_DEPTH=ON -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=OFF
if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
  copy/y Release\x265-static.lib ..\8bit\x265-static-main10.lib
)

@cd ..\8bit
if not exist x265-static-main10.lib (
  msg "%username%" "10bit build failed"
  exit 1
)
if not exist x265-static-main12.lib (
  msg "%username%" "12bit build failed"
  exit 1
)
cmake -G "Visual Studio 11 Win64" ../../../source -DHIGH_BIT_DEPTH=OFF -DEXPORT_C_API=OFF -DENABLE_SHARED=OFF -DENABLE_CLI=ON -DEXTRA_LIB="x265-static-main10.lib;x265-static-main12.lib"
if exist x265.sln (
  MSBuild /property:Configuration="Release" x265.sln
)

pause
