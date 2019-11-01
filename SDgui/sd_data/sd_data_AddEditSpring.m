function sd_data_AddEditSpring(r,s)
global SD;

SD.SpringList(r,:) = s;

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
