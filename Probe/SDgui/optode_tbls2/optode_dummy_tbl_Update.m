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
ceditable   = get(handles.optode_dummy_tbl, 'ColumnEditable');
for ii = 1:size(OptPos,1)
    A{ii,1} = num2str(optid+ii);
    A{ii,2} = real2str(OptPos(ii,1));
    A{ii,3} = real2str(OptPos(ii,2));
    A{ii,4} = real2str(OptPos(ii,3));
    A{ii,5} = GrommetType{ii};
    A{ii,6} = GrommetRot{ii};
end
A(ii+1:end,:) = {''};     % Set the rest of the rows to empty string 

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
