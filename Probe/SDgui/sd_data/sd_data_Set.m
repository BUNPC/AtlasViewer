function sd_data_Set(datatype, data)

switch lower(datatype)
    case {'lambda'}
        sd_data_SetLambda(data);
    case {'srcpos'}
        sd_data_SetSrcPos(data);
    case {'srcpos3d'}
        sd_data_SetSrcPos3D(data);
    case {'detpos'}
        sd_data_SetDetPos(data);
    case {'detpos3d'}
        sd_data_SetDetPos3D(data);
    case {'dummypos'}
        sd_data_SetDummyPos(data);
    case {'dummypos3d'}
        sd_data_SetDummyPos3D(data);
    case {'measlist'}
        sd_data_SetMeasList(data);
    case {'srcmap'}
        sd_data_SetSrcMap(data);
        
end

SDgui_AtlasViewerGUI('update');
