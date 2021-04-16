function sd_data_SetDetPos3D(tbl)
global SD

SD.DetPos3D = sd_data_AssignTbl(SD.DetPos3D, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
