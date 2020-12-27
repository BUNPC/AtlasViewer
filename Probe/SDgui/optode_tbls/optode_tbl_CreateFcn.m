function optode_tbl_CreateFcn(hObject, nrows, cnames)

if length(cnames)==5
    A = repmat({'','','','',''}, nrows,1);
    cwidth = {50, 50, 50, 100,100};
    ceditable = logical([1,1,1,1,1]);
    cformat = {'char', 'char', 'char', sd_data_GetGrommetChoices(),'char'};
elseif length(cnames)==6
    A = repmat({'','','','','',''}, nrows,1);
    cwidth = {40, 50, 50, 50, 100,100};
    ceditable = logical([0,1,1,1,1,1]);
    cformat = {'char', 'char', 'char', 'char', sd_data_GetGrommetChoices(),'char'};
end

set(hObject, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth, 'ColumnEditable',ceditable, 'ColumnFormat',cformat);
userdata.tbl_size = 0;
set(hObject, 'userdata',userdata);

