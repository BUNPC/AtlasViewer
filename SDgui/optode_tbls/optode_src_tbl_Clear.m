function optode_src_tbl_Clear(handles)

optode_tbl_CreateFcn(handles.optode_src_tbl, 100);
if get(handles.optode_src_tbl_srcmap_show, 'value')
    init_srcmap_tbl(handles.optode_src_tbl)
end


% ------------------------------------------------------------
function init_srcmap_tbl(hObject)

A = get(hObject, 'Data');
cnames = get(hObject, 'ColumnName');
cwidth = get(hObject, 'ColumnWidth');
ceditable = get(hObject, 'ColumnEditable');

srcmap = sd_data_Get('SrcMap');
nwl = 1;
nSrcs = 0;
for j=1:nwl
    A(:,4+j) = {''};
    for i=1:nSrcs
        A{i,4+j} = num2str(srcmap(j,i));
    end
    cnames{end+1} = ['l' num2str(j)];
    cwidth{end+1} = 20;
    ceditable(end+1) = logical(1);
end

set(hObject, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth, 'ColumnEditable',ceditable);
userdata.tbl_size = 0;
userdata.selection = [];
set(hObject, 'userdata',userdata);


