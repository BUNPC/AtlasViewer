function optode_anchor_tbl_CreateFcn(hObject, eventdata, handles)

A=repmat({'',''},10,1);
userdata.tbl_data = A;
userdata.tbl_size = 0;
userdata.selection = [];
set(hObject,'Data',A,'userdata',userdata);
