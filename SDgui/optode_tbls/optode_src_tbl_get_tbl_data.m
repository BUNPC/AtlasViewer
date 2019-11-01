function [tbl_data tbl_size] = optode_src_tbl_get_tbl_data(handles)

    hObject = handles.optode_src_tbl;
    tbl_data = get(hObject,'data') ;
    userdata = get(hObject,'userdata') ;
    tbl_size = userdata.tbl_size;

