function probe = registerProbe2Head(probe, headvol, refpts)
if ~probeHasSpringRegistration(probe) && ~isempty(probe.registration.refpts)
    kk = 1;
    probe_refps_pos = [];
    AV_refpts_pos = [];
    for ii = 1:length(probe.registration.refpts.labels)
        label = probe.registration.refpts.labels{ii};
        idx1 = ismember(lower(probe.registration.refpts.labels), lower(label));
        idx2 = ismember(lower(refpts.labels), lower(label));
        if sum(idx1)>0 && sum(idx2)>0
            probe_refps_pos(kk,:) = probe.registration.refpts.pos(idx1,:);
            AV_refpts_pos(kk,:) = refpts.pos(idx2,:);
            kk = kk+1;
        end
    end
    
    probe_refps_pos = [probe_refps_pos, ones(size(probe_refps_pos,1),1)];
    T = probe_refps_pos \ AV_refpts_pos;
    optpos = [probe.srcpos; probe.detpos];
    optpos = [optpos, ones(size(optpos,1),1)];
    probe.optpos_reg = optpos*T;
    probe = pullProbeToHeadsurf(probe, headvol);
else
    [optconn, anchor_pts] = spring2posprobe(probe, refpts, headvol);
    if ~isempty(probe.optpos_reg)
        posprobe_data = gen_positionprobe_dat(probe.optpos_reg, optconn, anchor_pts);
    else
        posprobe_data = gen_positionprobe_dat(probe.optpos, optconn, anchor_pts);
    end
    if isempty(posprobe_data)
        return;
    end
    probe.optpos_reg = positionprobe(posprobe_data, ...
        [1 2 3], ...
        1, ...
        [0 0 0], ...
        headvol.img, ...
        headvol.center, ...
        400);
end

% Shed dummy points
probe.orientation = headvol.orientation;
