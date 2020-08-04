function wavelength2_edit_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to wavelength2_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

    set(hObject,'string',[]);
