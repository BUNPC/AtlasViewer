function optode_anchor_tbl_Init(handles,al)

hObject = handles.optode_anchor_tbl;

D=repmat({'' ''},100,1);
for i=1:size(al,1)
    D{i,1}=al{i,1};
    D{i,2}=al{i,2};
end
userdata.tbl_data = D;
userdata.tbl_size = size(al,1);
userdata.selection = [];
set(hObject,'Data',D,'userdata',userdata);
