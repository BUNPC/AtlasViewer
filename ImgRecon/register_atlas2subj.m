function [atlas_vol atlas_pts T_voxa2voxs] = ...
    register_atlas2subj(atlas_vol, atlas_pts, subj_pts)

%
% USAGE:
%
% [atlas_vol_voxs atlas_pts_voxs T_voxa2voxs] = ...
%     register_atlas2subj(atlas_vol_fn, atlas_pts_fn, subj_pts_fn, axes_order)
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/10/2008
%  


    if(~exist('axes_order') | isempty(axes_order))
        axes_order=[1 2 3];
    end    

DISPLAY=0;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Get tranformation matrix from atlas voxel space to 
    % subject space.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    T_voxa2voxs = gen_xform_from_pts(atlas_pts.pos, subj_pts.pos);


    % Transform atlas volume to subject volume.
    [Dx Dy Dz] = size(atlas_vol.img);
    [atlas_vol.img T_vert2voxs] = xform_apply_vol_smooth(atlas_vol.img, T_voxa2voxs, [Dx Dy Dz]);
    T_voxa2voxs = T_vert2voxs*T_voxa2voxs;

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Translate atlas_vol ref points to voxel space. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    atlas_pts.pos = xform_apply(atlas_pts.pos, T_voxa2voxs);


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Once atlas is in subject space, bring ref points to atlas surface. 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % atlas_pts_voxs = bring_pts_to_surf(atlas_vol_voxs, atlas_pts_voxs);
    atlas_pts.pos = pullPtsToSurf(atlas_pts.pos, atlas_vol.img, 'center');


