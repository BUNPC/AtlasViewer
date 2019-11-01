function [vol] = vol2constvol(vol, mask)

%
% Usage:
%
%    [vol] = vol2constvol(vol, mask)
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%  
   
    i = find(vol ~= 0);
    vol(i) = 1;   

    if (exist('mask') == 1)
        mask_i = find(mask == 0);
        vol(mask_i) = 0;
    end 

