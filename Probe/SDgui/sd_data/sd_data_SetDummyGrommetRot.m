function sd_data_SetDummyGrommetRot(tbl)
global SD

SD.DummyGrommetRot = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
