function probe = loadSD(probe, SD)
if ischar(SD)
    filedata = load(SD, '-mat');
    SD = filedata.SD;
end
probe0 = convertSD2probe(SD);
probe = probe.copy(probe, probe0);



