function sd_data_SetDetPos(tbl)
global SD

SD.DetPos = sd_data_AssignTbl(SD.DetPos, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
