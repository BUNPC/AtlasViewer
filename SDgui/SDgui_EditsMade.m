function b = SDgui_EditsMade()
global filedata
global SD

b = true;
if ~sd_data_IsEmpty()
    status = AVUtils.data_diff(SD, filedata.SD);
    if status == 3
        return
    end
end
b = false;
