function [ostr, vox2ras] = getOrientationFromMriHdr(hdr)

ostr = '';
vox2ras = [];

if isempty(hdr)
    return;
end

% voxel-to-ras transform
vox2ras = [hdr.vox2ras(1:3,1:3), [hdr.vox2ras(1,4)-hdr.c_r; hdr.vox2ras(2,4)-hdr.c_a; hdr.vox2ras(3,4)-hdr.c_s]; 0,0,0,1];
ostr = getOrientation(vox2ras);

