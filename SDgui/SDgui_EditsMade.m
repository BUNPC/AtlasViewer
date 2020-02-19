function b = SDgui_EditsMade()
global filedata
global SD

b = false;
if isempty(comp_struct(SD, filedata.SD))
    return
end
if isempty(SD)
    return
end
if isempty(SD.SrcPos) && isempty(SD.DetPos) && isempty(SD.MeasList)
    return
end
b = true;
