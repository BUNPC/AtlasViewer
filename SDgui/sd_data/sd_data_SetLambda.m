function sd_data_SetLambda(lambda)

global SD;

SD.Lambda = lambda;
if(length(lambda) > length(unique(SD.MeasList(:,4))))
    ml = sd_data_GetMeasList();
    sd_data_SetMeasList(ml);
end       

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
