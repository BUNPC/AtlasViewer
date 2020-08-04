if not defined MSBUILD (set MSBUILD="C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe")
"%MSBUILD%" .\tMCimg.sln /t:rebuild /p:configuration=Debug
move .\Debug\tMCimg.exe ..\bin\Win
del /q .\Debug\*
rmdir .\Debug

