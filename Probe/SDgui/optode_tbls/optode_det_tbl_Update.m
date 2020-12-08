function optode_det_tbl_Update(handles)

OptPos       = sd_data_Get('DetPos');
GrommetType  = sd_data_Get('DetGrommetType');

% Generate table data
A = get(handles.optode_det_tbl, 'data');
for ii = 1:size(OptPos,1)
    A{ii,1} = real2str(OptPos(ii,1));
    A{ii,2} = real2str(OptPos(ii,2));
    A{ii,3} = real2str(OptPos(ii,3));
    A{ii,4} = GrommetType{ii};
end
A(ii+1:end,:) = {''};     % Set the rest of the rows to empty string 

% Update uitable with table data
set(handles.optode_det_tbl, 'data', A);
userdata.tbl_size = size(OptPos,1);
set(handles.optode_det_tbl, 'userdata',userdata);
