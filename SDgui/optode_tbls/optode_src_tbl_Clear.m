function optode_src_tbl_Clear(handles)

hObject = handles.optode_src_tbl;
val=get(handles.optode_src_tbl_srcmap_show,'value');
if(val==1)
    optode_src_tbl_CreateFcn(hObject,val,handles);
else
    optode_src_tbl_CreateFcn(hObject,[],[]);
end
