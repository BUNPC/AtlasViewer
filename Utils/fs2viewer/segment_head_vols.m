function [hseg, tiss_type] = segment_head_vols(layers, mode)

%
% USAGE:
%
%    [hseg tiss_type] = segment_head_vols(layers, mode)
% 
%
% DESCRIPTION: 
% 
%    head:     head volume 
%    skin:     skin volume 
%    skull:    skull volume 
%    dura:     dura volume 
%    csf:      csf volume 
%    gm:       gray matter volume 
%    wm:       white matter volume 
% 
%    mode: Optional - {'fill','nofill'}. 'nofill' option will run much 
%          faster because the head volume is assumed to have no gaps and  
%          therefore no gap filling is perfomed.
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%  

hseg = [];
tiss_type = {};

head = layers.head.volume;
skull = layers.skull.volume;
dura = layers.dura.volume;
csf = layers.csf.volume;
gm = layers.gm.volume;
wm = layers.wm.volume;

head.vol = uint8(head.vol);
skull.vol = uint8(skull.vol);
dura.vol = uint8(dura.vol);
csf.vol = uint8(csf.vol);
gm.vol = uint8(gm.vol);
wm.vol = uint8(wm.vol);

if ~exist('mode','var')
    mode='fill';
end
s = 1;

xoffset = 1;
yoffset = 1;
zoffset = 1;

dims0 = size(head.vol);
hseg0 = head.vol;

% Put all volumes together to make a segmented head

% head volume
if(~isempty(head.vol))
    i = find(hseg0 > 0);
    hseg0(i) = 1;
    [hseg, xoffset, yoffset, zoffset] = resizeVolume(hseg0);
    
    if strcmp(mode,'fill')
        h = waitbar_msg_print('Filling gaps in segmented head volume. This will take a few minutes...');
        se = strel('ball',20, 10);

        waitbar_msg_print(sprintf('Filling gaps in segmented head volume...%d%% completed',uint8(100*(1/3))), h, 1, 3);
        hseg = imclose(hseg, se);
        
        waitbar_msg_print(sprintf('Filling gaps in segmented head volume...%d%% completed',uint8(100*(2/3))), h, 2, 3);
        hseg = imfill(hseg, 'holes');
        
        waitbar_msg_print(sprintf('Filling gaps in segmented head volume...%d%% completed',uint8(100*(3/3))), h, 3, 3);
        close(h);
    end
    i = find(hseg < .7 & hseg > 0);
    hseg(i) = 0;

    i = find(hseg > 0);
    hseg(i) = s;

    tiss_type{s}='skin';
    s=s+1;
    
    hseg  = hseg(xoffset:xoffset+dims0(1)-1, yoffset:yoffset+dims0(2)-1, zoffset:zoffset+dims0(3)-1);

end

[hseg, tiss_type] = addhseglayer(hseg, head, skull, 'skull', tiss_type);
[hseg, tiss_type] = addhseglayer(hseg, head, dura, 'dura', tiss_type);
[hseg, tiss_type] = addhseglayer(hseg, head, csf, 'csf', tiss_type);
[hseg, tiss_type] = addhseglayer(hseg, head, gm, 'gm', tiss_type);
[hseg, tiss_type] = addhseglayer(hseg, head, wm, 'wm', tiss_type);

% Make sure head isn't touching the volume boundaries
% This causes all kinds of problems in image processing 
[nx,ny,nz]=size(hseg);
hseg(1:5,:,:)=0;
hseg(nx-5:nx,:,:)=0;
hseg(:,1:5,:)=0;
hseg(:,ny-5:ny,:)=0;
hseg(:,:,1:5)=0;
hseg(:,:,nz-5:nz)=0;



% -------------------------------------------------------------
function [hseg, tiss_type] = addhseglayer(hseg, head, layer, name, tiss_type)

if isempty(layer.vol)
    return;
end
if isempty(hseg)
    hseg = layer.vol;
end

% Align layer volume with head volume
X = inv(layer.vox2ras) * head.vox2ras;
layer.vol = xform_apply_vol_smooth(layer.vol, X);

% Assign layer segmentation number
s = max(hseg(:))+1;
layer_i = find(layer.vol ~= 0);
hseg(layer_i) = s;
tiss_type{s}=name;


