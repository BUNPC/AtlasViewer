function sd_data_SetSrcMapEntry(i,lasers)

global SD;

if(~exist('lasers') | isempty(lasers))
    nwl=sd_data_GetNwl();
    if(nwl>0 & SD.nSrcs>0)
        if(nwl<size(SD.SrcMap,1))
            SD.SrcMap(nwl+1:end,:)=[];
        end
        k=nwl;
        for j=1:nwl
            SD.SrcMap(j,i)=i*nwl-k+1;
            k=k-1;
        end
    end
else
    SD.SrcMap(:,i)=lasers;
end

% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
