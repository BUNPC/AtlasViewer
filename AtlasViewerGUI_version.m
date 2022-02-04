function verstr = AtlasViewerGUI_version(hObject)

if ~exist('hObject','var')
    hObject = -1;
end

verstr = getVernum('AtlasViewerGUI');
if ishandle(hObject)
    set(hObject,'name', banner());
end
