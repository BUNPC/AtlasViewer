function b = SDgui_EditsMade()
global filedata
global SD

b = true;
status = data_diff(SD, filedata.SD);
if status == 3
    return    
end
b = false;
