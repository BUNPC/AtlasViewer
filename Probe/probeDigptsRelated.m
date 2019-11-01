function B = probeDigptsRelated(probe,digpts)

B = 0;

p = probe.optpos;
nopt = probe.noptorig;
nsrc = probe.nsrc;
ndet = nopt-nsrc;

d = [digpts.srcpos; digpts.detpos];
ndigsrc = size(digpts.srcpos,1);
ndigdet = size(digpts.detpos,1);
ndigpts = ndigsrc + ndigdet;

if ndigpts==0
    return;
end
if isempty(p)
    return;
end
if ndigsrc~=nsrc
    return;
end
if ndigdet~=ndet
    return;
end

B = 1;

