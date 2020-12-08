function sd_data_SetSrcMap()
global SD

SD.SrcMap = [];
for j = 1:size(SD.SrcPos,1)
    sd_data_SetSrcMapEntry(j);
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
