function [curve_seg, len, gap] = curve_gen(p1, p2, p3, surf, neighb_dist_mean)

%
% USAGE:
%
%    [curve_seg len] = curve_gen(p1, p2, p3, plane, surf)
%
% DESCRIPTION:
%    
%    Find the set of points in surf which lie approximately on the 
%    line of intersection formed by the aurgumant plane and surf. The 
%    output paramter curve_seg is a subset of this set of points 
%    limited to the point lying on the curve segment [p1,p3,p2].
%
% EXAMPLE:
%
%    [curve_pts_NzIz len_NzIz] = curve_gen(Nz, Iz, Cz, surf, .3);
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   2/9/2010
%

global DEBUG

if ~exist('neighb_dist_mean', 'var') | isempty(neighb_dist_mean)
    neighb_dist_mean = meshdensity(surf);
    MIN_NEIGHBOR_DIST = 4*neighb_dist_mean;
else
    MIN_NEIGHBOR_DIST = neighb_dist_mean;
end

% Distance threshold for the curve_gen to determine
% the surface points on the head which intersect with a plane.
% Start with default distance threshold of 1/2 mm. Then keep
% incrementing by 1/2 mm until dt exceeds mean mesh density
dt = .5;
while dt < neighb_dist_mean
    dt = dt+1;
end

% Generate curve using optimul distance threshhold (dt) from plane of 
% intersection to points on the surface. Optimal distance threshhold
% is one that produces a set of curve points with the smallest gaps 
% in between points.

plane = plane_equation(p1, p2, p3);
curve_pts = plane_surf_intersect(plane, surf, dt);
curve_seg0 = find_curve_path(p1, p2, p3, curve_pts);

% Throw away points which are too close and fill in points on
% lines segments connecting the included points. 
[curve_seg, len, gap] = gen_sparcer_curve(curve_seg0, MIN_NEIGHBOR_DIST, surf);
curve_seg(end,:) = p2;

if DEBUG
    if exist('refpts','var')
        hc = displayCurve([], curve_seg);
    end
end
