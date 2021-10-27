
@echo off

@SET DESKTOP_REG_ENTRY="HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders"
@SET DESKTOP_REG_KEY="Desktop"
@SET DESKTOP_DIR=
@FOR /F "tokens=1,2*" %%a IN ('REG QUERY %DESKTOP_REG_ENTRY% /v %DESKTOP_REG_KEY% ^| FINDSTR "REG_SZ"') DO (
    @set DESKTOP_DIR="%%c"
)

set dirnameSrc=%cd%
set dirnameDst=c:\users\public

IF EXIST %DESKTOP_DIR%\AtlasViewerGUI.exe.lnk (del /Q /F %DESKTOP_DIR%\AtlasViewerGUI.exe.lnk)
IF EXIST %dirnameDst%\atlasviewer (rmdir /S /Q %dirnameDst%\atlasviewer)

