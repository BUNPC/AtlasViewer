function sd_data_Clear()

    global SD;

    SD.Lambda      = [];
    SD.SrcPos      = [];
    SD.DetPos      = [];
    SD.DummyPos    = [];
    SD.nSrcs       = 0;
    SD.nDets       = 0;
    SD.nDummys     = 0;
    SD.MeasList    = [];
    SD.SpringList  = [];
    SD.AnchorList  = [];
    SD.SrcMap      = [];
    SD.xmin        = 0.0;
    SD.xmax        = 0.0;
    SD.ymin        = 0.0;
    SD.ymax        = 0.0;


