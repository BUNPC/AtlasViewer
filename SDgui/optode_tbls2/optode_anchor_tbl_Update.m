function optode_anchor_tbl_Update(handles,al)

hObject = handles.optode_anchor_tbl;

D=repmat({'',''},100,1);
for i=1:size(al,1)
    D{i,1}=al{i,1};
    D{i,2}=al{i,2};
end
userdata.tbl_data = D;
userdata.tbl_size = size(al,1);
set(hObject,'data',D,'userdata',userdata);
