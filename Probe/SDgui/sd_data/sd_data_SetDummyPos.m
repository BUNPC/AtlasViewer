function sd_data_SetDummyPos(tbl)
global SD

SD.DummyPos = sd_data_AssignTbl(SD.DummyPos, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
