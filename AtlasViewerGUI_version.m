function [verstr, vernum] = AtlasViewerGUI_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end

[title, verstr, vernum] = banner();

if ishandle(hObject)
    set(hObject,'name', title);
end
