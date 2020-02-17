function wavelength2_edit_Update(handles, wl)

hObject = handles.wavelength2_edit;
set(hObject,'string',num2str(wl));
wavelength_edit_Callback(hObject, [wl,2], handles);

