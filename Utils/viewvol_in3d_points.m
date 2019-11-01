function [hvol, haxes] = viewvol_in3d_points(vol, surf_color, backgnd_color, axes_order, newfig, densemesh)

%
% Usage:
%
%    h = viewvol_in3d_points(vol, surf_color, backgnd_color, axes_order, margin)
%
% Inputs:
% 
%    vol:        Volume to be converted to a surface and displayed in 3D
%                This is the only required argument. 
%
%    surf_color: Optional argument specifying color of the surface. The color 
%                options are
%
%                'colorcube', 'copper', 'gray',   'hsv', 'lines', 
%                'prism',     'summer', 'winter', 'pink'
%
%    backgnd_color:  Optional argument specifies the color of the grid.
%
%
%    axes_order: If the axes order of the volume is consistent matlab's 3D 
%                display of the volume then use [1 2 3].  Otherwise, specify 
%                a mapping. For instance, if the volume x and y should be  
%                permuted then use [2 1 3].  The 1, 2, and 3 refer to the 
%                x, y, and z axes. 
%
%    margin:     Optional argument specifies how much space you want between 
%                the object and the grid boundaries. By default the grid   
%                will be only big enough to fully contain the object and no 
%                bigger. This option allows you to view the object in the context
%                of a larger grid by specifying the size of the margins between
%                grid borders and the edges of the object. 
%
% Example 1:
%    
%    hseg = load_image('./examples/4005/hseg.bin');
%    viewvol_in3d_points(hseg);
%
% Example 2:
%
%    hseg = load_image('./examples/4005/hseg.bin');
%    viewvol_in3d_points(hseg, 'winter','white');
%
% Example 3:
%    
%    hseg = load_image('./examples/4005/hseg.bin');
%    viewvol_in3d_points(hseg, 'copper','white', [2 1 3], 30);
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2009
%

    if(~exist('surf_color','var'))
        surf_color = 'pink';
    end
    if(~exist('backgnd_color','var'))
        backgnd_color='black';
    end
    if(~exist('newfig','var'))
        newfig=1;
    end
    if(~exist('densemesh','var'))
        densemesh=0;
    end
    
    surf = img2mesh(vol, 0);
    if densemesh
        fv = isosurface(vol, .9);
        surf = [surf; [fv.vertices(:,2), fv.vertices(:,1), fv.vertices(:,3)]];
    end
    
    
    if(exist('axes_order') & ~isempty(axes_order))
        surf0(:,1)=surf(:,axes_order(1));
        surf0(:,2)=surf(:,axes_order(2));
        surf0(:,3)=surf(:,axes_order(3));
        surf=surf0;
        clear surf0;
    end

    [hvol haxes] = MakePlot3D(surf, 8, surf_color, 'FlipCM', backgnd_color, newfig); 

    axis off;
    axis equal;
    axis vis3d
    daspect([1 1 1]);
    rotate3d on
