function b = isPreRegisteredProbe(probe, headsurf)
b = 0;

MEAN_DIST_THRESH = 20;
MAX_DIST_THRESH = 31;
STD_DIST_THRESH = 10;
ALL_DIST_THRESH = 5;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Eliminate simple cases of probe not being registered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('probe','var') || isempty(probe) || probe.isempty(probe)
    return
end
if ~exist('headsurf','var') || isempty(headsurf) || headsurf.isempty(headsurf)
    return;
end

% It is very unlikely probe is registered to a curved head if all the
% optiodes are in a flat plane
if isProbeFlat(probe)
    return;
end

if ~isempty(probe.optpos_reg)
    p = probe.optpos_reg;
else
    p = probe.optpos;
end
[~, ~, d] = nearest_point(headsurf.mesh.vertices, p);

if mean(d)<MEAN_DIST_THRESH & max(d)<MAX_DIST_THRESH & std(d,1,1)<STD_DIST_THRESH
    b = 1;
    if all(d<ALL_DIST_THRESH)
        b = 2;
    end
end

