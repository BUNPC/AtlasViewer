function SDgui_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end
title = sprintf('SDgui  (v%s) - %s', getVernum('SDgui'), filesepStandard(pwd));
if ishandle(hObject)
    set(hObject,'name', title);
end
