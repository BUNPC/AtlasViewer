function al=sd_data_GetAnchorList()

global SD;

al={};

if iscell(SD.AnchorList)
    for ii=1:size(SD.AnchorList,1)
        al{ii,1} = num2str(SD.AnchorList{ii,1});
        al{ii,2} = SD.AnchorList{ii,2};
    end
else
    for ii=1:size(SD.AnchorList,1)
        al{ii,1} = num2str(SD.AnchorList(ii,1));
        al{ii,2} = num2str(SD.AnchorList(ii,2:end));
    end    
end