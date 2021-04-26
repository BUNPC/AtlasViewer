function b = probeHasLandmarkRegistration(probe)

b = false;
if isempty(probe)
    return;
end
if isempty(probe.optpos_reg)
    return;
end
if isempty(probe.registration)
    return;
end
if isempty(probe.registration.refpts)
    return;
end
if size(probe.registration.refpts.pos,1)<5
    return;
end
b = true;

