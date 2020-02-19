function wavelength2_edit_Update(handles, wl)

set(handles.wavelength2_edit,'string',num2str(wl));
wavelength_edit_Callback(handles.wavelength2_edit, [wl,2], handles);

