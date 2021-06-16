function b = isPreRegisteredProbe(probe, obj)
b = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Eliminate simple cases of probe not being registered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('probe','var') || isempty(probe) || probe.isempty(probe)
    return
end
if ~exist('obj','var') || isempty(obj) || obj.isempty(obj)
    return;
end

headsurf = [];
refpts = [];


if strcmp(obj.name, 'headsurf')
    headsurf = obj;
else
    refpts = obj;
end

if ~isempty(headsurf)
    b = isPreRegisteredToHeadsurf(probe, headsurf);
else
    b = isPreRegisteredToRefpts(probe, refpts);    
end



% -------------------------------------------------------------------
function b = isPreRegisteredToHeadsurf(probe, headsurf)
b = 0;

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
b = analyseStats(d);


% -------------------------------------------------------------------
function b = isPreRegisteredToRefpts(probe, refpts)
b = 0;
if ~exist('refpts','var') || isempty(refpts) || refpts.isempty(refpts)
    return;
end

% It is very unlikely probe is registered to a curved head if all the
% optiodes are in a flat plane
if isProbeFlat(probe)
    return;
end
if isempty(probe.registration.refpts)
    return
end
if probe.registration.refpts.isempty(probe.registration.refpts)
    return
end
[rp1, rp2] = findCorrespondingRefpts(probe.registration.refpts, refpts);

d = dist3(rp1,rp2);
b = analyseStats(d);



% ------------------------------------------------------------------
function b = analyseStats(d)
global MEAN_DIST_THRESH;
global MAX_DIST_THRESH;
global STD_DIST_THRESH;
global ALL_DIST_THRESH;

MEAN_DIST_THRESH = 20;
MAX_DIST_THRESH = 31;
STD_DIST_THRESH = 10;
ALL_DIST_THRESH = 5;

b = 0;
if mean(d)<MEAN_DIST_THRESH && max(d)<MAX_DIST_THRESH && std(d(:),1,1)<STD_DIST_THRESH
    b = 1;
    if all(d<ALL_DIST_THRESH)
        b = 2;
    end
end

