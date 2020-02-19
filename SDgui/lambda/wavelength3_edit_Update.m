function wavelength3_edit_Update(handles, wl)

set(handles.wavelength3_edit,'string',num2str(wl));
wavelength_edit_Callback(handles.wavelength3_edit, [wl,3], handles);


