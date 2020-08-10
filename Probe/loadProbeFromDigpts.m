function probe = loadProbeFromDigpts(probe, digpts)

probe.srcpos        = digpts.srcpos;
probe.nsrc          = size(digpts.srcpos,1);
probe.detpos        = digpts.detpos;
probe.ndet          = size(digpts.detpos,1);
probe.optpos        = [probe.srcpos; probe.detpos];
probe.noptorig      = size(probe.optpos,1);
probe.srcmap        = digpts.srcmap;
probe.detmap        = digpts.detmap;
probe.center        = digpts.center;
probe.orientation   = digpts.orientation;
