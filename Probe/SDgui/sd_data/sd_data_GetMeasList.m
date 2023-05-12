function ml = sd_data_GetMeasList()
global SD

ml = [];
if isempty(SD)
    return
end
if size(SD.MeasList,2)<3
    return;
end
if ~isempty(SD.MeasList)
    k = find(SD.MeasList(:,4)==1);
    ml = SD.MeasList(k,1:2);
end
