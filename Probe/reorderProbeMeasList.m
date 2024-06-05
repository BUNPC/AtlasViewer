function probe1 = reorderProbeMeasList(probe1, probe2)
if isempty(probe1) || probe1.isempty(probe1)
    return;
end
if isempty(probe2) || probe2.isempty(probe2)
    return;
end
SD1 = convertProbe2SD(probe1);
SD2 = convertProbe2SD(probe2);
n1 = NirsClass(SD1);
n2 = NirsClass(SD2);
if ~n1.MeasListEqual(n2)
    return
end
probe1.ml = probe2.ml;

