function nwl=sd_data_GetNwl()

    global SD;

    nwl=1;
    if(~isempty(SD.Lambda))
        nwl = length(SD.Lambda);
    elseif(~isempty(SD.MeasList))
        nwl = length(unique(SD.MeasList(:,end)));
    elseif(~isempty(SD.SrcMap))
        nwl = size(SD.SrcMap,1);
    end
