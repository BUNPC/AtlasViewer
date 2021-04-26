function sd_data_SetDummyPos3D(tbl)
global SD

SD.DummyPos3D = sd_data_AssignTbl(SD.DummyPos3D, tbl);

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
