function [verstr, vernum] = AtlasViewerGUI_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end
[verstr, vernum] = version2string();
title = sprintf('AtlasViewerGUI  (%s) - %s', verstr, pwd);
if ishandle(hObject)
    set(hObject,'name', title);
end
