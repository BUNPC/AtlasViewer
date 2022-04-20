function b = SDgui_EditsMade()
global filedata
global SD

b = true;
if ~sd_data_IsEmpty()
    if ~isempty(filedata.SD)
        if ~sd_data_Equal(SD, filedata.SD)
            return
        end
    end
end
b = false;
