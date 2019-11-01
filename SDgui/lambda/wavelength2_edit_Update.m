function wavelength2_edit_Update(handles,wl)
% hObject    handle to wavelength3_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    hObject = handles.wavelength2_edit;
    set(hObject,'string',num2str(wl));
    % wavelength_edit_Callback(hObject, [], handles);

