function optode_tbl_Update(hObject, tbl_data, tbl_size, r, c)


set(hObject, 'data',tbl_data);
userdata = get(hObject, 'userdata');
userdata.tbl_size = tbl_size;
set(hObject, 'userdata',userdata);

findNextTableFocus(hObject, tbl_data, r, c)


% -------------------------------------------------
function findNextTableFocus(hObject, tbl_data, r, c)

try
    [r, c] = getNextCell(tbl_data, r, c);
    jUIScrollPane = findjobj_fast(hObject);
    jUITable = jUIScrollPane.getViewport.getView;
    jUITable.changeSelection(r, c, false, false);
catch
    
end



% -------------------------------------------------
function [r, c] = getNextCell(tbl_data, r, c)

if c < size(tbl_data,1)
    c = c+1;
    return
end
c = 1;
r = r+1;
