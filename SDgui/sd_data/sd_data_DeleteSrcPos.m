function sd_data_DeleteSrcPos(i)

global SD;

SD.SrcPos(i,:)=[];
SD.nSrcs=SD.nSrcs-1;

