function sd_data_SetLambda(lambda)
global SD

if isempty(SD)
    return
end
SD.Lambda = lambda;
if ~isempty(SD.MeasList)
    if length(lambda) > length(unique(SD.MeasList(:,4)))
        ml = sd_data_GetMeasList();
        sd_data_SetMeasList(ml);
    end
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
