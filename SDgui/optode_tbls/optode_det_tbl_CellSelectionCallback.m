function optode_det_tbl_CellSelectionCallback(hObject, eventdata, handles)

userdata = get(hObject,'userdata');
userdata.selection = eventdata.Indices;
set(hObject,'userdata',userdata);
