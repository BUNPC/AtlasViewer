function probe = checkRegistrationData(dirname, probe, headsurf)
global SD
if probe.isempty(probe)
    return;
end
if ~isPreRegisteredProbe(probe, headsurf)
    if ~probeHasSpringRegistrationInfo(probe)
        if ~probeHasDigptsRegistrationInfo(probe)
            q = MenuBox('Warning: loaded probe has no registration data. Do you want to add registration data to the probe using SDgui?', {'YES','NO'});
            if q==1
                probe.save(probe);
                waitForGUI(SDgui([dirname, 'probe.SD'], 'userargs'));
                probe = loadSD(probe, SD);
            end
        end
    end
end


% --------------------------------------------------------
function waitForGUI(h)
timer = tic;
fprintf('GUI is busy...\n');
while ishandle(h)
    if mod(toc(timer), 5)>4.5
        fprintf('GUI is busy...\n');
        timer = tic;
    end
    pause(.1);
end


