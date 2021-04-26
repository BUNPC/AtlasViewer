function s = SDgui_3DViewSelected(handles)
global SD

s = '';
if get(handles.radiobuttonView3D, 'value')
    if isempty(SD.SrcPos3D) && isempty(SD.DetPos3D)
        return
    end
    s = '3D';
end

