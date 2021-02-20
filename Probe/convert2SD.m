function SD = convert2SD(probe)

SD = [];
if isempty(probe)
    return;
end
SD.Lambda               = probe.lambda;
SD.SpatialUnit          = '';
SD.SrcPos               = probe.srcpos;
SD.DetPos               = probe.detpos;
SD.DummyPos             = probe.registration.dummypos;
SD.nSrcs                = probe.nsrc;
SD.nDets                = probe.ndet;
SD.MeasList             = [];
for ii = 1:length(SD.Lambda)
    SD.MeasList         = [SD.MeasList; [probe.ml(:,[1,2]), ones(size(probe.ml,1),1), ii*ones(size(probe.ml,1),1)]];
end
SD.SpringList           = probe.registration.sl;
SD.AnchorList           = probe.registration.al;
SD.SrcGrommetType       = probe.SrcGrommetType;
SD.DetGrommetType       = probe.DetGrommetType;
SD.DummyGrommetType     = probe.DummyGrommetType;
SD.SrcGrommetRot        = probe.SrcGrommetRot;
SD.DetGrommetRot        = probe.DetGrommetRot;
SD.DummyGrommetRot      = probe.DummyGrommetRot;

