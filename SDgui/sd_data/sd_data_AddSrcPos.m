function sd_data_AddSrcPos(i,pos,lasers)

    global SD;

    SD.SrcPos(i,:)=pos;

    % Add entry to SrcMap
    if(exist('lasers','var') & ~isempty(lasers))
        sd_data_SetSrcMapEntry(i,lasers);
    end

    SD.nSrcs=SD.nSrcs+1;
