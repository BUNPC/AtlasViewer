function probe = checkRegistrationData(dirname, probe, headsurf, refpts)
global SD
if probe.isempty(probe)
    return;
end
if ~isPreRegisteredProbe(probe, headsurf)
    if ~probeHasSpringRegistration(probe)
        if ~probeHasDigptsRegistration(probe)
            q = MenuBox('Warning: loaded probe has no registration data. Do you want to add registration data to the probe using SDgui?', {'YES','NO'});
            if q==1
                probe.save(probe);
                waitForGui(SDgui([dirname, 'probe.SD'], 'userargs'));
                probe = loadSD(probe, SD);
            end
        end
    end
else
    probe.orientation = refpts.orientation;
end

