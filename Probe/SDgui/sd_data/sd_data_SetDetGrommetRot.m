function sd_data_SetDetGrommetRot(tbl)
global SD

SD.DetGrommetRot = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');