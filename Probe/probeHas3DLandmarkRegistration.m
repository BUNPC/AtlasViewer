function b = probeHas3DLandmarkRegistration(probe)
b = false;
if isempty(probe.registration.refpts)
    return;
end
if isempty(probe.registration.refpts.pos)
    return;
end
if isempty(probe.registration.refpts.labels)
    return;
end
if strcmpi(probe.registration.direction, 'atlas2probe')
    return
end
if size(probe.registration.refpts.pos,1) ~= length(probe.registration.refpts.labels)
    return;
end
b = true;

