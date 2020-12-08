function sd_data_SetSrcPos(tbl)
global SD

SD.SrcPos = sd_data_AssignTbl(SD.SrcPos, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

