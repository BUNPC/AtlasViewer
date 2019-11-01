function sd_data_Set(datatype,data)

    global SD;
 
    switch lower(datatype)
    case {'lambda'}
        SD.Lambda=data;
    case {'srcpos'}
        SD.SrcPos=data;
    case {'detpos'}
        SD.DetPos=data;
    case {'measlist'}
        SD.MeasList=data;
    case {'srcmap'}
        if(exist('data','var'))
            SD.SrcMap=data;
        else
            sd_data_SetSrcMap();
        end
    end


    SDgui_AtlasViewerGUI('update');
