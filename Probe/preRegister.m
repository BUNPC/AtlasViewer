function probe = preRegister(probe, headsurf, refpts)

if ~isProbeFlat(probe)
    return
end
if isempty(headsurf) || headsurf.isempty(headsurf)
    return
end
if isempty(refpts) || refpts.isempty(refpts)
    return
end

% Check if the probe is already registered. If not then pre register it. 
if ~isPreRegisteredProbe(probe, headsurf)
    % We are loading a flat probe that needs to be anchored to the
    % head. Bring flat probe to some point on head surface to make the
    % imported probe at least somewhat visible. To do this find
    % a reference point on the head surface (e.g. Cz) to anchor (ap)
    % the center of the probe to and translate the probe to that
    % anchor point.
    k = find(strcmpi(refpts.labels,'Cz'));
    if isempty(k)
        ap = refpts.pos(1,:);
    else
        ap = refpts.pos(k,:);
    end
    c   = findcenter(probe.optpos);
    tx  = ap(1)-c(1);
    ty  = ap(2)-c(2);
    tz  = ap(3)-c(3);
    T   = [1 0 0 tx; 0 1 0 ty; 0 0 1 tz; 0 0 0 1];
    probe.optpos = xform_apply(probe.optpos, T);
end
probe.center        = headsurf.center;
probe.orientation   = headsurf.orientation;


