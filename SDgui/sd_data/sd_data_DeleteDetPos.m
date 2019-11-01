function sd_data_DeleteDetPos(i)

global SD;

SD.DetPos(i,:)=[];
SD.nDets=SD.nDets-1;
