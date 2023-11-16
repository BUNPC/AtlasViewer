function probe = pullProbeToHeadsurf(probe, head)
if isPreRegisteredProbe(probe)==2
    MenuBox('Probe already registered to head surface');
    return
end
if isempty(probe.optpos_reg)
    optpos = probe.optpos;
else
    optpos = probe.optpos_reg;
end
probe.optpos_reg = pullPtsToSurf(optpos, head, probe.pullToSurfAlgorithm);
