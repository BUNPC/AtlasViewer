function [bbox_vert, bbox_mp, bbox_vol] = gen_bbox(obj, paddingsize)

% Usage:
%
%    [bbox_vert bbox_vol] = gen_bbox(obj, paddingsize)
%
% Example 1:
%
%    Get bounding box, bounding box in volume coordinates (positive integers) 
%    and bounding box volume in the context of the larger volume which was
%    passed as an argument, or given a vector of x coord, y coord, delta x 
%    and delta y return bounding box in 2D. This is useful for determing bounding 
%    boxes of matlab gui graphics objects. 
%
%    hseg = create_hseg('/autofs/space/monte_013/users/jdubb/workspaces/subjects/4004');
%    [bbox_vert bbox_vol] = gen_bbox(hseg);
%
% Example 2:
%
%    Get bounding box, bounding box in volume coordinates and bounding box volume 
%    without the context of the larger volume because none was passed in. 
%    
%    [bbox_vert bbox_vol] = gen_bbox(vert, 0); 
%
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   01/27/2012

bbox_vert = [];
bbox_mp = [];
bbox_vol = [];

if ndims(obj)==3
    vol = obj;
    i = find(vol ~= 0);
    [x, y, z] = ind2sub(size(vol), i);
    vert = [];
elseif ndims(obj)==2
    vert = obj;
    x = vert(:,1);
    y = vert(:,2);
    z = vert(:,3);
    vol = [];
elseif ndims(obj)==1
    x       = obj(1);
    y       = obj(2);
    x_delta = obj(3);
    y_delta = obj(4);
    bbox_vert = [x,y; x+x_delta,y; x,y+y_delta; x+x_delta,y+y_delta];
    bbox_vol=[];
    return;  
end

if isempty(x) | isempty(y) | isempty(z)
    bbox_vert = []; 
    bbox_vol = []; 
    vol = [];
    return;
end

maxx = max(x);
maxy = max(y);
maxz = max(z);
minx = min(x);
miny = min(y);
minz = min(z);

if(exist('paddingsize'))
    padding_x = paddingsize;
    padding_y = paddingsize;
    padding_z = paddingsize;
else
    padding_x = 0;
    padding_y = 0;
    padding_z = 0;
end

maxx = max(x);
maxy = max(y);
maxz = max(z);
minx = min(x);
miny = min(y);
minz = min(z);

minx_p = minx - padding_x; 
maxx_p = maxx + padding_x;
miny_p = miny - padding_y; 
maxy_p = maxy + padding_y;
minz_p = minz - padding_z; 
maxz_p = maxz + padding_z;

bbox_vert = [...
            minx_p miny_p minz_p;...
            minx_p miny_p maxz_p;...
            minx_p maxy_p minz_p;...
            minx_p maxy_p maxz_p;...
            maxx_p miny_p minz_p;...
            maxx_p miny_p maxz_p;...
            maxx_p maxy_p minz_p;...
            maxx_p maxy_p maxz_p;...          
            ];

% Get midpoints for all 6 cube faces        
bbox_mp = [...
           minx_p, miny_p+(maxy_p-miny_p)/2, minz_p+(maxz_p-minz_p)/2;...
           maxx_p, miny_p+(maxy_p-miny_p)/2, minz_p+(maxz_p-minz_p)/2;...
           minx_p+(maxx_p-minx_p)/2, miny_p, minz_p+(maxz_p-minz_p)/2;...
           minx_p+(maxx_p-minx_p)/2, maxy_p, minz_p+(maxz_p-minz_p)/2;...
           minx_p+(maxx_p-minx_p)/2, miny_p+(maxy_p-miny_p)/2, minz_p;...
           minx_p+(maxx_p-minx_p)/2, miny_p+(maxy_p-miny_p)/2, maxz_p;...
          ];
        
        
% Translate bounding box coordinates to positive integer space
T = [1 0 0 -minx_p+1; 0 1 0 -miny_p+1; 0 0 1 -minz_p+1; 0 0 0 1];
bbox_vol = round(xform_apply(bbox_vert, T));

if(~isempty(vol))
    vol = uint8(zeros(size(vol)));
    vol(bbox_vol(1,1):bbox_vol(end,1), ...
        bbox_vol(1,2):bbox_vol(end,2), ...
        bbox_vol(1,3):bbox_vol(end,3)) = 1;
end
