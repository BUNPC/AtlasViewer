function b = SDgui_EditsMade()
global filedata
global SD

b = true;
if ~sd_data_IsEmpty()
    if ~sd_data_Equal(SD, filedata.SD)
        return
    end
end
b = false;
