function sd_data_SetSrcMapDefault(nwl)
global SD

if isempty(SD)
    return
end
if ~exist('nwl','var') || isempty(nwl)
    nwl = sd_data_GetNwl();
end
if nwl==0
    return;
end
SD.SrcMap = [];
for i = 1:size(SD.SrcPos,1)
    k = nwl;
    for j = 1:nwl
        SD.SrcMap(j,i) = i*nwl-k+1;
        k=k-1;
    end
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
