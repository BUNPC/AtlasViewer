
set dirnameSrc=%cd%
set dirnameDst=c:\users\public

IF EXIST %userprofile%\desktop\brainScape.exe.lnk (del /Q /F %userprofile%\desktop\brainScape.exe.lnk)
IF EXIST %userprofile%\desktop\QuickStartGuide.pdf.lnk (del /Q /F %userprofile%\desktop\QuickStartGuide.pdf.lnk)

IF EXIST %dirnameDst%\brainScape (del /F /Q %dirnameDst%\brainScape\*)
IF EXIST %dirnameDst%\brainScape (rmdir /S /Q %dirnameDst%\brainScape)

IF EXIST %dirnameDst%\Colin\anatomical (del /F /Q %dirnameDst%\Colin\anatomical\*)
IF EXIST %dirnameDst%\Colin\fw (del /Q /F %dirnameDst%\Colin\fw\*)
IF EXIST %dirnameDst%\Colin (del /Q /F %dirnameDst%\Colin\*)

IF EXIST %dirnameDst%\Colin\anatomical (rmdir /S /Q %dirnameDst%\Colin\anatomical)
IF EXIST %dirnameDst%\Colin\fw (rmdir /S /Q %dirnameDst%\Colin\fw)
IF EXIST %dirnameDst%\Colin (rmdir /S /Q %dirnameDst%\Colin)



