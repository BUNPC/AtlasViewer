function data=sd_data_Get(datatype)

    data = [];

    global SD;

    if isempty(SD)
        datatype='all';
    end 

    switch lower(datatype)
    case {'lambda'}
        data=SD.Lambda;
    case {'srcpos'}
        data=SD.SrcPos;
    case {'detpos'}
        data=SD.DetPos;
    case {'dummypos'}
        data=SD.DummyPos;
    case {'nsrcs'}
        data=SD.nSrcs;
    case {'ndets'}
        data=SD.nDets;
    case {'measlist'}
        data=SD.MeasList;
    case {'springlist'}
        data=SD.SpringList;
    case {'anchorlist'}
        data=SD.AnchorList;
    case {'srcmap'}
        data=SD.SrcMap;
    case {'SpatialUnit'}
        data=SD.SpatialUnit;
    case {'all'}
        data=SD;
    end     

    
