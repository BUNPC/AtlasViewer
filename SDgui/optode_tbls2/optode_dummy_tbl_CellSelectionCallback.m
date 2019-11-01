function optode_dummy_tbl_CellSelectionCallback(hObject, eventdata, handles)

    tbl_data = get(hObject,'data');
    ncols=size(tbl_data,2);
    userdata = get(hObject, 'userdata');
    tbl_size = userdata.tbl_size;
    if ~isempty(eventdata.Indices)
         r=eventdata.Indices(1);
         c=eventdata.Indices(2);
    end

