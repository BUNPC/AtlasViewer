
Set objArgs = WScript.Arguments
application = objArgs(0)

Set sh = CreateObject("WScript.Shell")
Set shortcut = sh.CreateShortcut(application + ".lnk")


shortcut.TargetPath = application
shortcut.WorkingDirectory = "C:\Users\Public\atlasviewer\Test"
shortcut.Save
