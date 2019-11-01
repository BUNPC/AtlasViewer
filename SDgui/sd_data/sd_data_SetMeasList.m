function i=sd_data_SetMeasList(ml)

global SD;

i=[];
if(isempty(ml))
    SD.MeasList=[];
    return;
end
[ml i] = sort_ml(ml);
nwl=sd_data_GetNwl();
nmeas=size(ml,1);
if(nwl>0)
    % Update SD data
    SD.MeasList=[];
    for j=1:nwl
        SD.MeasList=[SD.MeasList; ml ones(nmeas,1) ones(nmeas,1)*j];
    end
else
    SD.MeasList=[ml ones(nmeas,1) ones(nmeas,1)];
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
