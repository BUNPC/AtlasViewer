% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over wavelength1_edit.
function wavelength1_edit_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to wavelength1_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    set(hObject,'enable','on');

