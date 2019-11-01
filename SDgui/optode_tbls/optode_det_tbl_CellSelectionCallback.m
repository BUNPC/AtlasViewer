% --- Executes when selected cell(s) is changed in optode_det_tbl.
function optode_det_tbl_CellSelectionCallback(hObject, eventdata, handles)
% hObject    handle to optode_det_tbl (see GCBO)
% eventdata  structure with the following fields (see UITABLE)
%	Indices: row and column indices of the cell(s) currently selecteds
% handles    structure with handles and user data (see GUIDATA)

    src_tbl_data = get(hObject,'data');
    userdata = get(hObject,'userdata');
    userdata.selection = eventdata.Indices;
    set(hObject,'userdata',userdata);
