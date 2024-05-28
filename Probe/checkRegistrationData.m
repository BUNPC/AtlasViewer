function probe = checkRegistrationData(dirname, probe, headsurf, refpts)
global SD
if probe.isempty(probe)
    return;
end
if ~isPreRegisteredProbe(probe, headsurf)
    if ~probeHasSpringRegistration(probe)
        if ~probeHasDigptsRegistration(probe)
            if ~probeHas3DLandmarkRegistration(probe)
                q = MenuBox('Warning: loaded probe has no registration data. Do you want to add registration data to the probe using SDgui?', {'YES','NO'});
                if q==1
                    probe.save(probe);
                    waitForGui(SDgui([dirname, 'probe.SD'], 'userargs'));
                    probe = loadSD(probe, SD);
                end
            end
        end
    end
else
    probe.optpos_reg = [probe.srcpos; probe.detpos; probe.registration.dummypos];
    probe.orientation = refpts.orientation;
end

