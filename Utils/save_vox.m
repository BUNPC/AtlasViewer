function save_vox(filename, vol)

% USAGE:
%
%    save_vox(filename, vol)
%
% DESCRIPTION:
%
%    Writes data to a file in binary format which means that the way the
%    data appears in memory as a sequnece of bytes is the way it is saved
%    on disk. The dimensions of the data are saved in a text file of the
%    same name as the argument filename except the extension '_dims.txt'
%    is appended. This is the only header information that is saved.
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/22/2012

img       = vol.img;
tiss_type = {};
for ii=1:length(vol.tiss_prop)
    tiss_type{ii} = vol.tiss_prop(ii).name;
end
T_2digpts = vol.T_2digpts;
T_2mc = vol.T_2mc;
T_2ras = vol.T_2ras;
T_2ref = vol.T_2ref;

% Create .bin file from segemented head
fid = fopen(filename, 'wb');
fwrite(fid, img, 'uint8');

fclose(fid);

% Save text file with the dimensions
k = strfind(filename, '.');
filename_dims = [filename(1:k(end)-1), '_dims.txt'];
dims = size(img);
save(filename_dims, 'dims', '-ascii');

% Generate a tissue file.
filename_tiss_type = [filename(1:k(end)-1), '_tiss_type.txt'];
save_tiss_type(filename_tiss_type, tiss_type);

% Generate transformation files.
if ~isempty(T_2digpts) && ~isidentity(T_2digpts)
    filename_2digpts = [filename(1:k(end)-1), '2digpts.txt'];
    save(filename_2digpts,'T_2digpts','-ascii');
end

if ~isempty(T_2ras) && ~isidentity(T_2ras)
    filename_2ras = [filename(1:k(end)-1), '2ras.txt'];
    save(filename_2ras,'T_2ras','-ascii');
end

if ~isempty(T_2mc) && ~isidentity(T_2mc)
    filename_2mc = [filename(1:k(end)-1), '2mc.txt'];
    save(filename_2mc,'T_2mc','-ascii');
end

if ~isempty(T_2ref) && ~isidentity(T_2ref)
    filename_2ref = [filename(1:k(end)-1), '2ref.txt'];
    save(filename_2ref,'T_2ref','-ascii');
end

if ~isempty(vol.orientation)
    filename_orientation = [filename(1:k(end)-1), '_orientation.txt'];
    fd = fopen(filename_orientation, 'w');
    fprintf(fd, '%s', vol.orientationOrig);
    fclose(fd);
end


