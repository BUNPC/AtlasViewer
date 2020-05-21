function sd_data_SetDummyGrommetType(tbl)
global SD

SD.DummyGrommetType = tbl;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');

