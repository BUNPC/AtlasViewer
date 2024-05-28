function b = probeHasDigptsRegistration(probe)
b = false;
if isProbeFlat(probe)
    return;
end
if isempty(probe.registration.refpts)
    return;
end
if length(probe.registration.refpts.pos)<5
    return;
end
if ~strcmp(probe.registration.direction, 'atlas2probe')
    return
end
b = true;

