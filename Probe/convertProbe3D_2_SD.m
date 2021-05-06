function SD = convertProbe3D_2_SD(probe, SD)

if isempty(probe.optpos_reg)
    return
end
if isfield(probe,'nsrc')
    nsrc = probe.nsrc;
else
    nsrc = size(probe.srcpos,1);
end
if isfield(probe,'ndet')
    ndet = probe.ndet;
else
    ndet = size(probe.detpos,1);
end
SD.SrcPos3D    = probe.optpos_reg(1 : nsrc, :);
SD.DetPos3D    = probe.optpos_reg(nsrc+1 : nsrc+ndet, :);
SD.DummyPos3D  = probe.optpos_reg(nsrc+ndet+1 : end, :);
SD.optpos_reg = probe.optpos_reg;

SD.Landmarks.labels = probe.registration.refpts.labels;
SD.Landmarks.pos    = probe.registration.refpts.pos;

