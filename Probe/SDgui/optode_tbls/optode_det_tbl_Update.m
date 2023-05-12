function optode_det_tbl_Update(handles)

data3D = SDgui_3DViewSelected(handles);

OptPos       = sd_data_Get(['DetPos', data3D]);
GrommetType  = sd_data_Get('DetGrommetType');
GrommetRot   = sd_data_Get('DetGrommetRot');

% Generate table data
A = get(handles.optode_det_tbl, 'data');
cnames      = get(handles.optode_det_tbl, 'ColumnName');
cwidth      = get(handles.optode_det_tbl, 'ColumnWidth');

A           = optodes_tbl_copy_data(A, OptPos, GrommetType, GrommetRot);

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
set(handles.optode_det_tbl, 'data', A, 'ColumnName',cnames, 'ColumnWidth',cwidth);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_det_tbl, 'userdata',userdata);
