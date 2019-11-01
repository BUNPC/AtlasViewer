function optode_dummy_tbl_CreateFcn(hObject, eventdata, handles)

for ii=1:100
   D{ii,1}='';
   D{ii,2}='';
   D{ii,3}='';
   D{ii,4}='';
end
userdata.tbl_size = 0;
userdata.selection = [];
set(hObject,'Data',D,'userdata',userdata);

