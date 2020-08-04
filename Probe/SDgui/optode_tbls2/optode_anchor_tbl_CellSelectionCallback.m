function optode_anchor_tbl_CellSelectionCallback(hObject, eventdata, handles)

    anchor_tbl_data = get(hObject,'data');
    userdata = get(hObject,'userdata');
    userdata.selection = eventdata.Indices;
    set(hObject,'userdata',userdata);

