function vol = load_vox(filename,vol)

%
% Usage:
% 
%    v = load_bin(filename, dims)
% 
% Description:
%    
%    Loads a binary file as 8 bit unsigned integers. 
%
% Example:
%
%    hseg = load_bin('./mri/hseg.bin', [256 256 256]);
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2012
%  
%

fid = fopen(filename, 'rb');
vol.img = fread(fid, 'uint8');
i = strfind(filename, '.vox');
if ~exist('dims') | isempty(dims)
    filename_img_dims = [filename(1:i-1), '_dims.txt'];
    dims = load(filename_img_dims, '-ascii');
end
vol.img = uint8(reshape(vol.img, dims));
fclose(fid);

% Get tissue types
filename_img_tiss = [filename(1:i-1), '_tiss_type.txt'];
if exist(filename_img_tiss,'file')
    vol.tiss_prop = get_tiss_prop(filename_img_tiss);
end

% Load transformations
filename_2digpts = [filename(1:i(end)-1), '2digpts.txt'];
if exist(filename_2digpts,'file')
    vol.T_2digpts = load(filename_2digpts,'-ascii');
end

filename_2mc = [filename(1:i(end)-1), '2mc.txt'];
if exist(filename_2mc,'file')
    vol.T_2mc = load(filename_2mc,'-ascii');
end

filename_2ras = [filename(1:i(end)-1), '2ras.txt'];
if exist(filename_2ras,'file')
    vol.T_2ras = load(filename_2ras,'-ascii');
end

filename_2ref = [filename(1:i(end)-1), '2ref.txt'];
if exist(filename_2ref,'file')
    vol.T_2ref = load(filename_2ref,'-ascii');
end


filename_orientation = [filename(1:i(end)-1), '_orientation.txt'];
if exist(filename_orientation,'file')
    fd = fopen(filename_orientation, 'r');
    orientation = fgetl(fd);
    if orientation>0
        vol.orientation = orientation;
        vol.orientationOrig = orientation;
    end
    fclose(fd);
end
