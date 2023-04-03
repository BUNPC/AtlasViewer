function optode_dummy_tbl_Update(handles)

data3D      = SDgui_3DViewSelected(handles);

OptPos       = sd_data_Get(['DummyPos', data3D]);
GrommetType  = sd_data_Get('DummyGrommetType');
GrommetRot   = sd_data_Get('DummyGrommetRot');
SrcPos       = sd_data_Get(['SrcPos', data3D]);
DetPos       = sd_data_Get(['DetPos', data3D]);
optid        = size([SrcPos; DetPos],1);

% Generate table data
A = get(handles.optode_dummy_tbl, 'data');
cnames      = get(handles.optode_dummy_tbl, 'ColumnName');
cwidth      = get(handles.optode_dummy_tbl, 'ColumnWidth');

A = optodes_tbl_copy_data(A, OptPos, GrommetType, GrommetRot, optid);

if get(handles.checkboxNinjaCap,'Value') == 0
    cwidth{5} = 0;
    cwidth{6} = 0;
else
    cnames{5} = 'Grommet Type';
    cnames{6} = 'Grommet Rot';
    cwidth{5} = 100;
    cwidth{6} = 100;
end

% Update uitable with table data
set(handles.optode_dummy_tbl, 'data', A, 'ColumnName',cnames, 'ColumnWidth',cwidth);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_dummy_tbl, 'userdata',userdata);
