function [title, verstr, vernum] = banner()
[verstr, vernum] = version2string();
platform = ['R', version('-release')];
title = sprintf('AtlasViewerGUI  (v%s, %s) - %s', verstr, platform, pwd);
