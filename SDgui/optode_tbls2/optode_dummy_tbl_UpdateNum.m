function optode_dummy_tbl_UpdateNum(handles,noptreal)

hObject = handles.optode_dummy_tbl;

D=get(hObject,'data');
userdata=get(hObject,'userdata');
tbl_size = userdata.tbl_size;

for i=1:tbl_size
    D{i,1}=num2str(i+noptreal);
end

userdata.tbl_data = D;
set(hObject,'data',D,'userdata',userdata);

