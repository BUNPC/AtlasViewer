function optode_det_tbl_CreateFcn(hObject, eventdata, handles)
% --- Executes during object creation, after setting all properties.
% hObject    handle to optode_det_tbl (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

    A=repmat({'' '' ''},200,1);
    cnames={'x','y','z'};
    cwidth={40,40,40};
    ceditable=logical([1 1 1]);
    set(hObject,'Data',A,'ColumnName',cnames,'ColumnWidth',cwidth,'ColumnEditable',ceditable);

    userdata.tbl_size = 0;
    userdata.selection = [];
    set(hObject,'userdata',userdata);

