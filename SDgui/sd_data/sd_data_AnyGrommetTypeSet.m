function b = sd_data_AnyGrommetTypeSet()
global SD

b = false;
if isfield(SD,'SrcGrommetType')
    if ~all(strcmpi(SD.SrcGrommetType, 'none'))
        b = true;
    end
end
if isfield(SD,'DetGrommetType')
    if ~all(strcmpi(SD.DetGrommetType, 'none'))
        b = true;
    end
end


