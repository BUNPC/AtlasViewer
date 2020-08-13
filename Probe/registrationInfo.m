function b = registrationInfo(SD)

b = false;
if isempty(SD.SpringList)
    return;
end
if length(SD.AnchorList) < 3
    return;
end
b = true;
    