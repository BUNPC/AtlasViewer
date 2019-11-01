function sd_file_panel_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to sd_file_panel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    userdata=struct('h',[],'pathname',[]);
    set(hObject,'userdata',userdata);

