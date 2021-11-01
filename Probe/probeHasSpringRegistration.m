function [b, msg] = probeHasSpringRegistration(probe)
b = false;
msg = '';
if isempty(probe)
    msg{1} = sprintf('\nWARNING: Probe is empty\n');
    return;
end
if isempty(probe.optpos_reg) && isempty(probe.optpos)
    msg{1} = sprintf('\nWARNING: Probe does not have any optodes. In order to register');
    msg{2} = sprintf('please add optodes and register probe to the Surface.\n\n');
    return;
end
if isfield(probe, 'registration')
    if ~isempty(probe.optpos_reg)
        if size(probe.registration.al,1)<2
            msg{1} = sprintf('\nWARNING: Probe has less than two anchor points. In order to register');
            msg{2} = sprintf('correctly it needs atleast two anchor points. Please add atelast two anchor points');
            msg{3} = sprintf('and register probe to the Surface.\n\n');
            return;
        elseif isempty(probe.registration.sl)
            msg{1} = sprintf('\nWARNING: Probe does not have any springs. In order to register');
            msg{2} = sprintf('please add springs and register probe to the Surface.\n\n');
            return;
        else
            b = true;
        end
    else
        if size(probe.registration.al,1)>2 && ~isempty(probe.registration.sl)
            b = true;
        end
    end
elseif isfield(SD, 'AnchorList')
    if isempty(SD.SpringList)
        msg{1} = sprintf('\nWARNING: Probe does not have any springs. In order to register');
        msg{2} = sprintf('please add springs and register probe to the Surface.\n\n');
        return;
    end
    if length(SD.AnchorList) < 3
        return;
    end
    b = true; 
end


