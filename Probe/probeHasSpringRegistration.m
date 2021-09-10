function b = probeHasSpringRegistration(probe)
b = false;
if isempty(probe)
    return;
end
if isempty(probe.optpos_reg) && isempty(probe.optpos)
    return;
end
if isfield(probe, 'registration')
    if size(probe.registration.al,1)>2 && ~isempty(probe.registration.sl)
        b = true;
    end
elseif isfield(SD, 'AnchorList')
    if isempty(SD.SpringList)
        return;
    end
    if length(SD.AnchorList) < 3
        return;
    end
    b = true; 
end


