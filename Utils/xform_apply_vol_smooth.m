function [v2, T_vert2vox] = xform_apply_vol_smooth(v1, T1, mode)

% USAGE:
%
%     v2 = xform_apply_vol_smooth(v1, T1)
% 
% DESCRIPTION: 
% 
%     Creates empty volume v2 and scans through every voxel in v1. It 
%     inversely applies the 3D transformation matrix T to every voxel 
%     in volume v1 with a non-zero value and returns the transformed 
%     volume.
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   11/13/2008
%
% CHANGED: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   04/02/2014
%
% Changes:
%
%    10/16/2012 - Jay Dubb
%     

% Set default output
v2 = v1;
T_vert2vox = eye(4);

if ~exist('mode','var')
    mode='slow';
end

if all(T1==eye(4))
    return;
end

[Dx_v1, Dy_v1, Dz_v1] = size(v1);

% Get bounding boxes for original volume's grid and nonzero voxels and 
% transformed volume's grid and nonzero voxels 
bbox_v1 = gen_bbox(v1);
bbox_v1_grid = [...
                1     1     1; ...
                1     1 Dz_v1; ...
                1 Dy_v1     1; ...
                1 Dy_v1 Dz_v1; ...
                Dx_v1     1     1; ...
                Dx_v1     1 Dz_v1; ...
                Dx_v1 Dy_v1     1; ...
                Dx_v1 Dy_v1 Dz_v1; ...
               ];
bbox_v2 = round(xform_apply(bbox_v1, T1));
bbox_v2_grid0 = round(xform_apply(bbox_v1_grid, T1));

% If transfomed volume's nonzero voxels bounding box is within the bounding
% box of the original volume's grid then keep same grid for the tranformed
% volume. Otherwise resize the transformed volume's grid to fit all transformed
% non-zero voxels.
maxx = max(bbox_v2(:,1));
minx = min(bbox_v2(:,1));
maxy = max(bbox_v2(:,2));
miny = min(bbox_v2(:,2));
maxz = max(bbox_v2(:,2));
minz = min(bbox_v2(:,3));

if ( (maxx-minx)<Dx_v1 && minx>1 && ...
     (maxy-miny)<Dy_v1 && miny>1 && ...
     (maxz-minz)<Dz_v1 && minz>1 ) || ...
     strcmp(mode, 'gridsamesize')
    Dx_v2 = Dx_v1;
    Dy_v2 = Dy_v1;
    Dz_v2 = Dz_v1;
else
    tx = 1 - min(bbox_v2_grid0(:,1));
    ty = 1 - min(bbox_v2_grid0(:,2));
    tz = 1 - min(bbox_v2_grid0(:,3));
    T_vert2vox = [1 0 0 tx;  0 1 0 ty; 0 0 1 tz; 0 0 0 1];
    if strcmpi(mode,'fast')
        return;
    end
    bbox_v2_grid = xform_apply(bbox_v2_grid0, T_vert2vox);
    v2_gridsize = max(bbox_v2_grid)-1;
    Dx_v2 = v2_gridsize(1);
    Dy_v2 = v2_gridsize(2);
    Dz_v2 = v2_gridsize(3);
end
v2 = zeros(Dx_v2, Dy_v2, Dz_v2);
T1 = inv(T_vert2vox*T1);


% PERFORMANCE NOTE: Bizzarly the 32-bit version of xform_apply_vol_smooth runs 
% MUCH faster on a 32-bit matlab platform but MUCH slower on a 64-bit.
% Which is why we have 2 versions. The difference between them is that one
% vectorizes the most performance critical and time consuming operation and the
% other doesn't. It's a 3 line difference.
switch(computer('arch'))
    case 'win64'
        v2 = xform_apply_vol_smooth_64bit(v1, v2, T1);
    case 'win32'
        v2 = xform_apply_vol_smooth_32bit(v1, v2, T1);
    case 'glnxa64'
        v2 = xform_apply_vol_smooth_64bit(v1, v2, T1);
    otherwise
        v2 = xform_apply_vol_smooth_64bit(v1, v2, T1);
end
    


% ---------------------------------------------------------------
function v2 = xform_apply_vol_smooth_64bit(v1, v2, T)

if all(T==eye(4))
    return;
end

[Dx_v1, Dy_v1, Dz_v1] = size(v1);
[Dx_v2, Dy_v2, Dz_v2] = size(v2);

int = round((Dx_v2*Dy_v2*Dz_v2)/50);
hwait = waitbar(0,'Transforming head volume to subject space. Please wait...');
N = (Dx_v2*Dy_v2*Dz_v2);
for kk=1:Dz_v2
    for jj=1:Dy_v2
        for ii=1:Dx_v2

            % Display # of voxels completed
            if mod( (((kk-1)*Dx_v2*Dy_v2) + ((jj-1)*Dx_v2) + (ii-1)), int)==0
                waitbar( (((kk-1)*Dx_v2*Dy_v2) + ((jj-1)*Dx_v2) + (ii-1)) / N, hwait);
            end
            
            % Look up the voxel value (i,j,k) in the destination volume (v2) by
            % inversely transforming it to the source volume (v1) equivalent and 
            % assigning the value to v2(i,j,k).
            
            % The next line is performance critical where the most of the time
            % is spent in this function. It's faster on a 64-bit system than  
            % explicitly assigning i(1), i(2) and i(3). But much slower on a 32-bit 
            % system. 
            i = round(T(:,1)*ii + T(:,2)*jj + T(:,3)*kk + T(:,4));
            
            if (i(1) >= 1 && i(1) <= Dx_v1) && (i(2) >= 1 && i(2) <= Dy_v1) && (i(3) >= 1 && i(3) <= Dz_v1)
                if v1(i(1),i(2),i(3)) == 0
                    continue;
                end
                v2(ii,jj,kk) = v1(i(1),i(2),i(3));
            end

        end
    end
end
close(hwait);




% ---------------------------------------------------------------
function v2 = xform_apply_vol_smooth_32bit(v1, v2, T)

if all(T1==eye(4))
    return;
end

[Dx_v1, Dy_v1, Dz_v1] = size(v1);
[Dx_v2, Dy_v2, Dz_v2] = size(v2);

int = round((Dx_v2*Dy_v2*Dz_v2)/50);
hwait = waitbar(0,'Transforming head volume to subject space. Please wait...');
N = (Dx_v2*Dy_v2*Dz_v2);
for kk=1:Dz_v2
    for jj=1:Dy_v2
        for ii=1:Dx_v2
            
            % Display # of voxels completed
            if mod( (((kk-1)*Dx_v2*Dy_v2) + ((jj-1)*Dx_v2) + (ii-1)), int)==0
                waitbar( (((kk-1)*Dx_v2*Dy_v2) + ((jj-1)*Dx_v2) + (ii-1)) / N, hwait);
            end
            
            % Look up the voxel value (i,j,k) in the destination volume (v2) by
            % inversely transforming it to the source volume (v1) equivalent and 
            % assigning the value to v2(i,j,k).            

            % Next 3 lines are performance critical where the most time
            % is spent in this function. It's very fast on a 32-bit system,
            % much faster than vectorization. But slow on a 64-bit system. 
            i(1) = round(T(1,1)*ii + T(1,2)*jj + T(1,3)*kk + T(1,4));    
            i(2) = round(T(2,1)*ii + T(2,2)*jj + T(2,3)*kk + T(2,4));
            i(3) = round(T(3,1)*ii + T(3,2)*jj + T(3,3)*kk + T(3,4));    
            
            if (i(1) >= 1 && i(1) <= Dx_v1) && (i(2) >= 1 && i(2) <= Dy_v1) && (i(3) >= 1 && i(3) <= Dz_v1)
                if v1(i(1),i(2),i(3)) == 0
                    continue;
                end
                v2(ii,jj,kk) = v1(i(1),i(2),i(3));
            end

        end
    end
end
close(hwait);


