function wavelength1_edit_Update(handles, wl)

set(handles.wavelength1_edit, 'string',num2str(wl));
wavelength_edit_Callback(handles.wavelength1_edit, [wl,1], handles);
