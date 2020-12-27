function optode_src_tbl_Clear(handles)

optode_tbl_CreateFcn(handles.optode_src_tbl, 100, {'x','y','z','Grommet Type','Grommet Rot'});
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
srcpos = sd_data_Get('SrcPos');
nwl = sd_data_GetNwl();
offset = size(sd_data_Get('SrcPos'), 2)+1;
A(:,offset+1:end) = {''};
for j=1:nwl
    for i=1:size(srcpos,1)
        A{i,offset+j} = real2str(srcmap(j,i));
    end
    cnames{offset+j} = ['l' num2str(j)];
    cwidth{offset+j} = 20;
    ceditable(offset+j) = logical(1);
end

set(hObject, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth, 'ColumnEditable',ceditable);
userdata.tbl_size = 0;
set(hObject, 'userdata',userdata);


