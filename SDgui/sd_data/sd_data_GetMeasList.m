function ml=sd_data_GetMeasList()
global SD;

ml=[];
if size(SD.MeasList,2)<3
    return;
end
if(~isempty(SD.MeasList))
    nwl = length(unique(SD.MeasList(:,end)));
    nmeas = size(SD.MeasList,1)/nwl;
    ml = SD.MeasList(1:nmeas,1:2);
end
