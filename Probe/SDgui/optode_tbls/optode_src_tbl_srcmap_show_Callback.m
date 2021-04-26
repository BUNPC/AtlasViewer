function optode_src_tbl_srcmap_show_Callback(hObject, ~, handles)

val = get(hObject,'value');
data3D = SDgui_3DViewSelected(handles);

tbl_data    = get(handles.optode_src_tbl, 'data');
cnames      = get(handles.optode_src_tbl, 'ColumnName');
cwidth      = get(handles.optode_src_tbl, 'ColumnWidth');
ceditable   = get(handles.optode_src_tbl, 'ColumnEditable');
ncoord      = size(sd_data_Get(['SrcPos', data3D]), 2);

if(val==0)
    tbl_data    = tbl_data(:,1:ncoord+1);
    cnames      = cnames(1:ncoord+1);
    cwidth      = cwidth(1:ncoord+1);
    ceditable   = ceditable(1:ncoord+1);
else
    srcmap = sd_data_Get('SrcMap');
    nwl = sd_data_GetNwl();
    offset = ncoord+1;
    nSrcs = size(sd_data_Get(['SrcPos', data3D]), 1);
    tbl_data(:, offset+1:end) = {''};
    for j = 1:nwl
        for i = 1:nSrcs
            tbl_data{i, offset+j} = num2str(srcmap(j,i));
        end
        cnames{offset+j} = ['l', num2str(j)];
        cwidth{offset+j} = 20;
        ceditable(offset+j) = logical(1);
    end    
end

set(handles.optode_src_tbl, 'Data',tbl_data, 'ColumnName',cnames, 'ColumnWidth',cwidth, 'ColumnEditable',ceditable);
