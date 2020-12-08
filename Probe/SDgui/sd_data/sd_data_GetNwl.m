function nwl = sd_data_GetNwl()
global SD

nwl = 0;
if ~isempty(SD.Lambda)
    nwl = length(SD.Lambda);
end

