function save_bin(filename, vol)

% USAGE: 
%   
%    save_bin(filename, vol)
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
% Date:   07/30/2009



    % Create .bin file from segemented head
    fid = fopen(filename, 'wb');
    fwrite(fid, vol, 'uint8');
    fclose(fid);
    
    % Save text file with the dimensions
    i = strfind(filename, '.');
    filename_dims = [filename(1:i(end)-1) '_dims.txt'];
    dims = size(vol); 
    save(filename_dims, 'dims', '-ascii');
