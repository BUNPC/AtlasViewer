function sd_data_AddDetPos(i,pos)

    global SD;

    SD.DetPos(i,:)=pos;
    SD.nDets=SD.nDets+1;
