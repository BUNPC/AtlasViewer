function tbl_size=optode_anchor_tbl_GetSize(handles)

    hObject = handles.optode_anchor_tbl;
    userdata = get(hObject,'userdata');
    tbl_size = userdata.tbl_size;
