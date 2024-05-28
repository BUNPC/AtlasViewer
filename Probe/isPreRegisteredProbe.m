function [b, stats] = isPreRegisteredProbe(probe, obj)
global MEAN_DIST_THRESH;
global MAX_DIST_THRESH;
global STD_DIST_THRESH;
global ALL_DIST_THRESH;

MEAN_DIST_THRESH = 20;
MAX_DIST_THRESH = 31;
STD_DIST_THRESH = 10;
ALL_DIST_THRESH = 5;

b = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Eliminate simple cases of probe not being registered
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~exist('probe','var') || isempty(probe) || probe.isempty(probe)
    return
end
if ~exist('obj','var') || isempty(obj) || obj.isempty(obj)
    if ~probeHasSpringRegistration(probe)
        return
    end
    obj = probe.registration.refpts;
end
if ~strcmp(probe.orientation, obj.orientation)
    return
end
if isempty(probe.orientation) || isempty(obj.orientation)
    return
end

headsurf = [];
refpts = [];

if strcmp(obj.name, 'headsurf')
    headsurf = obj;
else
    refpts = obj;
end

if ~isempty(headsurf)
    [b, stats] = isPreRegisteredToHeadsurf(probe, headsurf);
else
    [b, stats] = isPreRegisteredToRefpts(probe, refpts);
end

if ~b
    global cfg %#ok<TLEV>
    val = cfg.GetValue('Force Pulling Optodes To Head');
    if ~stats.std.pass
        return
    end
    if strcmp(val, 'on')
        b = true;
    end
end



% -------------------------------------------------------------------
function [b, stats] = isPreRegisteredToHeadsurf(probe, headsurf)
b = 0;
stats = initStats();

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
[b, stats] = analyseStats(d);



% -------------------------------------------------------------------
function [b, stats] = isPreRegisteredToRefpts(probe, refpts)
b = 0;
stats = initStats();

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
if probeHasSpringRegistration(probe)
    refpts1.labels  = probe.registration.al(:,2);
    refpts1.pos     = probe.optpos_reg(cell2array(probe.registration.al(:,1)), :);
else
    refpts1         = probe.registration.refpts;
end
refpts2 = refpts;
[rp1, rp2] = findCorrespondingRefpts(refpts1, refpts2);
d = dist3(rp1,rp2);
[b, stats] = analyseStats(d);




% ------------------------------------------------------------------
function [b, stats] = analyseStats(d)
global ALL_DIST_THRESH;

b = 0;
stats = initStats(d);

if stats.mean.pass  &&  stats.max.pass  &&  stats.std.pass
    b = 1;
    if all(d<ALL_DIST_THRESH)
        b = 2;
    end
end



