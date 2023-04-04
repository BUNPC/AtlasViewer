function optode_src_tbl_Update(handles)

data3D      = SDgui_3DViewSelected(handles);

OptPos       = sd_data_Get(['SrcPos', data3D]);
GrommetType  = sd_data_Get('SrcGrommetType');
GrommetRot  = sd_data_Get('SrcGrommetRot');
SrcMap       = sd_data_Get('SrcMap');
srcmap_show  = optode_src_tbl_srcmap_show_GetVal(handles);

% Generate table data
A           = get(handles.optode_src_tbl, 'data');
cnames      = get(handles.optode_src_tbl, 'ColumnName');
cwidth      = get(handles.optode_src_tbl, 'ColumnWidth');
ceditable   = get(handles.optode_src_tbl, 'ColumnEditable');

A           = optodes_tbl_copy_data(A, OptPos, GrommetType, GrommetRot);

% If source map enabled add to table data the source map data
if srcmap_show
    nwl = sd_data_GetNwl();
    offset = size(OptPos, 2)+1;
    A(:, offset+1:end) = {''};
    for iWl = 1:nwl
        for iSrc = 1:size(SrcMap,2)
            A{iSrc, iWl+offset} = num2str(SrcMap(iWl, iSrc));
        end
        cnames{iWl+offset}    = ['l', num2str(iWl)];
        cwidth{iWl+offset} = 20;
        ceditable(iWl+offset) = logical(1);
    end
end

if get(handles.checkboxNinjaCap,'Value') == 0
    cwidth{4} = 0;
    cwidth{5} = 0;
else
    cnames{4} = 'Grommet Type';
    cnames{5} = 'Grommet Rot';
    cwidth{4} = 100;
    cwidth{5} = 100;
end
% Update uitable with table data
set(handles.optode_src_tbl, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_src_tbl, 'userdata',userdata);
