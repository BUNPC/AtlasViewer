function v = load_bin(filename, dims)

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
% Date:   11/13/2008
%  
%

    fid = fopen(filename, 'rb');
    v = fread(fid, 'uint8');
    if(~exist('dims') | isempty(dims))
        i = strfind(filename, '.bin');
        filename_img_dims = [filename(1:i-1) '_dims.txt'];
        dims = load(filename_img_dims, '-ascii');
    end
    v = uint8(reshape(v, dims));
    fclose(fid);
