function sd_data_SetSrcMapDefault(nwl)

global SD;

if(~exist('nwl') | isempty(nwl))
    nwl=sd_data_GetNwl();
end
if(nwl==0)
    return;
end
SD.SrcMap=[];
for i=1:SD.nSrcs
    k=nwl;
    for j=1:nwl
        SD.SrcMap(j,i)=i*nwl-k+1;
        k=k-1;
    end
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
