function [vol] = surf_file2vol(surfname, vol_dims, T)

% 
% Usage:
% 
%     [vol] = surf_file2vol(surfname, vol_dims, T)
% 
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%
    
    %%%% Get volume dimensions
    Dx = vol_dims(1);
    Dy = vol_dims(2);
    Dz = vol_dims(3);

    %%%% Get volumes from closed surfaces
    [v, f] = readsurf_trans(surfname, T);
    surf.faces = f;
    surf.vertices = v;

    %%%% Get the grid size. For now make it as big as neccessary to fully encompass
    %%%% the surface. Later we'll truncate to Dx, Dy, Dz dimensions.
    xmax = max(ceil(max(v(:,1))), Dx);
    ymax = max(ceil(max(v(:,2))), Dy);
    zmax = max(ceil(max(v(:,3))), Dz);
    [X, Y, Z] = meshgrid(1:1:xmax, 1:1:ymax, 1:1:zmax);
    vol = surface2volume(surf, {X, Y, Z});


    %%%% Make sure that if the surface goes beyond the volume bounding box,
    %%%% we truncate it to remain within the box
    dims = size(vol);
    Dx_new = dims(1);
    Dy_new = dims(2);
    Dz_new = dims(3);

    if Dx_new > Dx
        vol(Dx+1:Dx_new, :, :) = [];
    end

    if Dy_new > Dy
        vol(:, Dy+1:Dy_new, :) = [];
    end

    if Dz_new > Dz
        vol(:, :, Dz+1:Dz_new) = [];
    end
