@ECHO OFF
CD /D "%~dp0"

:: Run as SYSTEM
"%SOFT_AHK%\Scripts\AdvancedRun.exe" ^
    /Clear ^
    /ParseVarCommandLine 1 ^
    /UseSearchPath 1 ^
    /EXEFilename "Services.exe" ^
    /CommandLine ""^
    /RunAs 4 /Run
