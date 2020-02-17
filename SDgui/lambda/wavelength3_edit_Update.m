function wavelength3_edit_Update(handles, wl)

if isempty(wl)
    return
end
hObject = handles.wavelength3_edit;
set(hObject,'string',num2str(wl));
wavelength_edit_Callback(hObject, [wl,3], handles);


