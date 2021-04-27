function probe = registerProbe2Head(probe, headvol, refpts)

[optconn, anchor_pts] = spring2posprobe(probe, refpts, headvol);
if ~isempty(probe.optpos_reg)
    posprobe_data = gen_positionprobe_dat(probe.optpos_reg, optconn, anchor_pts);
else
    posprobe_data = gen_positionprobe_dat(probe.optpos, optconn, anchor_pts);
end
if isempty(posprobe_data)
    return;
end
optpos_reg = positionprobe(posprobe_data, ...
                           [1 2 3], ...
                           1, ...
                           [0 0 0], ...
                           headvol.img, ...
                           headvol.center, ...
                           400);
% Shed dummy points                      
probe.optpos_reg  = optpos_reg;
probe.orientation = headvol.orientation;