function wavelength1_edit_Update(handles, wl)

hObject = handles.wavelength1_edit;
set(hObject, 'string',num2str(wl));
wavelength_edit_Callback(hObject, [wl,1], handles);
