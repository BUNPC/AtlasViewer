function vol = gen_blob(radii,centers,vol,roughness)

% Usage:
%
%     vol = gen_blob(radii,center,vol,roughness)
% 
% Description:
%     
%     Generates an irregularly shaped region (blob) based on the 
%     equation of an ellipsoid in the volume 'vol' with radii
%     a, b, and c of 'radii' and centered at 'center'. 
%
%     One of the uses might be to create a pertubed region in a 
%     volume containing a simple slab with homogeneous tissue 
%     properties. In optical imaging, this slab could be used to 
%     compare the diffusion of light in a control slab to one of the 
%     exact same tissue properties and dimensions except for the 
%     blob-shaped with slightly different tissue properties. The 
%     example below illutrates the creation of these two slabs.
%
% Example:
%
%     slab_seg = zeros(100,100,100);
%     slab_seg(:,:,10:end) = 1;
%     blob = gen_blob([5 5 5], [35 45 17], slab_seg, 1);
%     i = find(blob == 1);
%     slab_seg(i)=2;
%     figure(1); imagesc(squeeze(slab_seg(:,45,:)));
%     
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   06/25/2009
%
% Modified by Jay Dubb 
% Date:   07/11/2012
%

[Dx Dy Dz] = size(vol);
Cx=centers(:,1);
Cy=centers(:,2);
Cz=centers(:,3);
p = max(unique(vol))+1;
for k=1:Dz
    for j=1:Dy
        for i=1:Dx
            for m=1:size(centers,1)
                a=radii(1) + round(roughness * rand(1));
                b=radii(2) + round(roughness * rand(1));
                c=radii(3) + round(roughness * rand(1));
                if (((i-Cx(m))^2)/a^2 + ((j-Cy(m))^2)/b^2 + ((k-Cz(m))^2)/c^2) <= 1;
                    vol(i,j,k) = p;
                end
            end
        end
    end
end
