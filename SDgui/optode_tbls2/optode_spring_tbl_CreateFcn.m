function optode_spring_tbl_CreateFcn(hObject, eventdata, handles)

A=repmat({'' '' ''},100,1);
userdata.tbl_size = 0;
userdata.selection = [];
set(hObject,'Data',A,'userdata',userdata);
