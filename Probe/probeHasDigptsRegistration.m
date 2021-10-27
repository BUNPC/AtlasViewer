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
b = true;

