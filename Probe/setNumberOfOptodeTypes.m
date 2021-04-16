function probe = setNumberOfOptodeTypes(probe, probe2)

if ~exist('probe2','var')
    return;
end

if isempty(probe.optpos_reg)
    if isfield(probe2, 'SrcPos')
        probe.nsrc = size(probe2.SrcPos,1);
        probe.ndet = size(probe2.DetPos,1);
        probe.registration.ndummy = size(probe2.DummyPos,1);
    else
        probe.nsrc          = size(probe.srcpos,1);
        probe.ndet          = size(probe.detpos,1);
        probe.registration.ndummy = size(probe.registration.dummypos,1);
    end
else
    if isfield(probe2, 'SrcPos3D')
        probe.nsrc = size(probe2.SrcPos3D,1);
        probe.ndet = size(probe2.DetPos3D,1);
        probe.registration.ndummy = size(probe2.DummyPos3D,1);
    else
        probe.nsrc = probe2.nsrc;
        probe.ndet = probe2.ndet;
        probe.registration.ndummy = probe2.registration.ndummy;
    end
end

probe.noptorig      = probe.nsrc + probe.ndet;
probe.nopt          = probe.nsrc + probe.ndet + probe.registration.ndummy;



