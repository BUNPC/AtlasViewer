function [verstr, vernum] = SDgui_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end
[verstr, vernum] = version2string();
title = sprintf('SDgui  (%s) - %s', verstr, pwd);
if ishandle(hObject)
    set(hObject,'name', title);
end
