function optode_dummy_tbl_Update(handles,noptreal)

hObject = handles.optode_dummy_tbl;

D=getget(hObject,'data');
userdata=get(hObject,'userdata');
tbl_size = userdata.tbl_size;
for i=1:tbl_size
    D{i,1}=str2num(D{i,1})+noptreal;
end
userdata.tbl_data = D;
userdata.tbl_size = size(al,1);
set(hObject,'data',D,'userdata',userdata);
