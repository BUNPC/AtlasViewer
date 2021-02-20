function b = isPreRegisteredProbe(probe, headsurf)
b = false;

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
if mean(d)<20 & max(d)<31 & std(d,1,1)<10
    b = true;
end

