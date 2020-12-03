function b = probeHasRegistrationInfo(probe)
if length(probe.al)>2 && ~isempty(probe.sl)
    b = true;
else
    b = false;
    fprintf('\n');
    fprintf('WARNING: Loaded probe containing flat SD geometry lacks registration data. In order to register it \n');
    fprintf('to head surface you need to add registration data. You can manually add registration data using \n');
    fprintf('SDgui application.\n');
    fprintf('\n');
end
