function probe = pullProbeToHeadsurf(probe, head)

if isempty(probe.optpos_reg)
    optpos = probe.optpos;
else
    optpos = probe.optpos_reg;
end
probe.optpos_reg = pullPtsToSurf(optpos, head, probe.pullToSurfAlgorithm);
