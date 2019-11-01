function probe = pullProbeToHeadsurf(probe,head, mode)

if ~exist('mode','var')
    mode='center';
end

if 1
    probe.optpos_reg = pullPtsToSurf(probe.optpos, head, probe.pullToSurfAlgorithm);
else
    probe.optpos_reg = pullPtsToSurf(probe.optpos, head, 'normal');
end
