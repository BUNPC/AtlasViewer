function sd_data_SetDetPos(tbl)
global SD

ncoord = sd_data_GetCoordNum();
for ir = 1:size(tbl,1)
    for ic = 1:ncoord
        SD.DetPos(ir,ic) = str2double(tbl{ir,ic});
    end
end
SD.DetPos(ir+1:end,:) = [];

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
