function SD = convertProbe3D_2_SD(probe, SD)

if isempty(probe.optpos_reg)
    return
end
nsrc = size(probe.srcpos,1);
ndet = size(probe.detpos,1);
SD.SrcPos3D    = probe.optpos_reg(1 : nsrc, :);
SD.DetPos3D    = probe.optpos_reg(nsrc+1 : nsrc+ndet, :);
SD.DummyPos3D  = probe.optpos_reg(nsrc+ndet+1 : end, :);


SD.Landmarks.labels = probe.registration.refpts.labels;
SD.Landmarks.pos    = probe.registration.refpts.pos;

