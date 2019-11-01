function sl=sd_data_GetSpringList()

global SD;

sl=[];
if(~isempty(SD.SpringList))
    sl = SD.SpringList;
end
