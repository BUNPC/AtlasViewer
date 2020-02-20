function sd_data_SetSrcGrommetType(tbl)
global SD

SD.SrcGrommetType = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

