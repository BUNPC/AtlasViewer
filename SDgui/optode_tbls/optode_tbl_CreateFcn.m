function optode_tbl_CreateFcn(hObject, nrows)

A = repmat({'','',''}, nrows,1);
cnames = {'x','y','z'};
cwidth = {40,40,40};
ceditable = logical([1,1,1]);
set(hObject, 'Data',A, 'ColumnName',cnames, 'ColumnWidth',cwidth, 'ColumnEditable',ceditable);

userdata.tbl_size = 0;
set(hObject, 'userdata',userdata);

