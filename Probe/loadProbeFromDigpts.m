function probe = loadProbeFromDigpts(digpts)
probe = initProbe();
if digpts.isempty(digpts)
    return;
end
probe.srcpos        = digpts.srcpos;
probe.nsrc          = size(digpts.srcpos,1);
probe.detpos        = digpts.detpos;
probe.ndet          = size(digpts.detpos,1);
probe.optpos        = [digpts.srcpos; digpts.detpos; digpts.dummypos];
probe.noptorig      = size(probe.optpos,1);
probe.center        = digpts.center;
probe.orientation   = digpts.orientation;
probe.registration.dummypos = digpts.dummypos;
probe.registration.refpts   = digpts.refpts;
