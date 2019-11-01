function al=sd_data_SetAnchorList(al,al_sz)

global SD;

if ~exist('al_sz','var')
    al_sz = size(al,1);
end

SD.AnchorList={};
for ii=1:al_sz
    SD.AnchorList{ii,1}=str2num(al{ii,1});
    SD.AnchorList{ii,2}=al{ii,2};
end


% Update AtlasViewerGUI
SDgui_AtlasViewerGUI('update');
