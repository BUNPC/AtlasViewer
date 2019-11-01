function sd_data_SetDummyPos(i,pos)

global SD;
SD.DummyPos(i,:)=pos;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
