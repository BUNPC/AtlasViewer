function probe = loadSD(probe, SD)

probe0 = convertSD2probe(SD);
probe = probe.copy(probe, probe0);

