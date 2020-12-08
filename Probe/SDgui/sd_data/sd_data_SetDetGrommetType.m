function sd_data_SetDetGrommetType(tbl)
global SD

SD.DetGrommetType = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

