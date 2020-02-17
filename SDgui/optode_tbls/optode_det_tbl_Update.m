function optode_det_tbl_Update(handles)

OptPos       = sd_data_Get('DetPos');
GrommetType  = sd_data_Get('GrommetType');

for i = 1:size(OptPos,1)
    A{i,1} = num2str(OptPos(i,1));
    A{i,2} = num2str(OptPos(i,2));
    A{i,3} = num2str(OptPos(i,3));
end

set(handles.optode_det_tbl, 'data', A);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_det_tbl, 'userdata',userdata);
