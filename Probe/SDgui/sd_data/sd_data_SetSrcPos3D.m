function sd_data_SetSrcPos3D(tbl)
global SD

SD.SrcPos3D = sd_data_AssignTbl(SD.SrcPos3D, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

