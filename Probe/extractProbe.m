function probe = extractProbe(probe0)
probe = initProbe();

if isa(probe0, 'DataTreeClass')
    probe0 = extractSDFromDataTree(probe0.currElem);
end
    
if isfield(probe0, 'SrcPos') && isfield(probe0, 'DetPos') && isfield(probe0, 'MeasList')
    probe = loadSD(probe, probe0);
    return;
end

if isfield(probe0, 'srcpos')
    probe.srcpos = probe0.srcpos;
end
if isfield(probe0, 'detpos')
    probe.detpos = probe0.detpos;
end
if isfield(probe0, 'optpos')
    probe.optpos = probe0.optpos;
else
    probe.optpos = [probe0.srcpos; probe.detpos];    
end
if isfield(probe0, 'ml')
    probe.ml = probe0.ml;
end
