function probe = viewProbe(probe, mode)

if isempty(mode)
    mode = 'registered';
end

if strcmp(mode,'registered') && ~isempty(probe.optpos_reg)
    optpos = probe.optpos_reg;
    lift = 0;
elseif strcmp(mode,'registered') && isempty(probe.optpos_reg)
    optpos = probe.optpos;
    lift = 0;
elseif strcmp(mode,'unregistered') && ~isempty(probe.optpos)
    optpos = probe.optpos;
    lift = 0;
else
    return;
end

hold on;

pts = prepPtsStructForViewing(optpos, probe.nsrc, 'probenum',[], 12);

% Not sure we should do this for probe
if leftRightFlipped(probe)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end
[probe.handles.hOptodes probe.handles.hOptodesCircles] = viewPts(pts, probe.center, lift, axes_order);
probe = setOptodeNumbering(probe);
probe = drawMeasChannels(probe);
probe = displaySprings(probe);

hold off

