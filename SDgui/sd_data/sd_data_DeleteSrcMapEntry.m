function sd_data_DeleteSrcMapEntry(i)

global SD;

if(~isempty(SD.SrcMap) & i<=size(SD.SrcMap,2))
    SD.SrcMap(:,i)=[];
end
