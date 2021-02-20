function b = probeHasDigptsRegistrationInfo(probe)
b = false;
if isempty(probe.registration.refpts)
    return;
end
if length(probe.registration.refpts.pos)<5
    return;
end
b = true;

