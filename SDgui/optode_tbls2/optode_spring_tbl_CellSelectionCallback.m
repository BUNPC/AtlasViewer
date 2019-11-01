function optode_spring_tbl_CellSelectionCallback(hObject, eventdata, handles)

    spring_tbl_data = get(hObject,'data');
    userdata = get(hObject,'userdata');
    userdata.selection = eventdata.Indices;
    set(hObject,'userdata',userdata);

