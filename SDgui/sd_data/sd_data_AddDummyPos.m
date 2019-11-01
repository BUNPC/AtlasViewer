function sd_data_AddDummyPos(i,pos)

    global SD;

    SD.DummyPos(i,:)=pos;
    SD.nDummys=SD.nDummys+1;
