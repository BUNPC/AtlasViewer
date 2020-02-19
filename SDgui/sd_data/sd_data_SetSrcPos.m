function sd_data_SetSrcPos(tbl)
global SD

ncoord = sd_data_GetCoordNum();
for ir = 1:size(tbl,1)
    for ic = 1:ncoord
        SD.SrcPos(ir,ic) = str2double(tbl{ir,ic});
    end
end
SD.SrcPos(ir+1:end,:) = [];

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

