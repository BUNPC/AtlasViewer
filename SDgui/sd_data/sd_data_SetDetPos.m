function sd_data_SetDetPos(i,pos)

global SD;
SD.DetPos(i,:)=pos;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
