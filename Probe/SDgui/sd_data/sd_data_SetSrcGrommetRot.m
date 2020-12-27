function sd_data_SetSrcGrommetRot(tbl)
global SD

SD.SrcGrommetRot = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
