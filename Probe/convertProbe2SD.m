function SD = convertProbe2SD(probe)

global atlasViewer

SD = sd_data_Init(probe);
if isempty(probe)
    return;
end

SD.Lambda               = probe.lambda;
SD.SpatialUnit          = 'mm';
SD.SrcPos               = probe.srcpos;
SD.DetPos               = probe.detpos;
SD.DummyPos             = probe.registration.dummypos;
SD                      = convertProbe3D_2_SD(probe, SD);
SD.nSrcs                = probe.nsrc;
SD.nDets                = probe.ndet;
SD.MeasList             = [];
for ii = 1:length(SD.Lambda)
    SD.MeasList         = [SD.MeasList; [probe.ml(:,[1,2]), ones(size(probe.ml,1),1), ii*ones(size(probe.ml,1),1)]];
end
SD.SpringList           = probe.registration.sl;
SD.AnchorList           = probe.registration.al;

if ~isempty(probe.SrcGrommetType)
    SD.SrcGrommetType       = probe.SrcGrommetType;
end

if ~isempty(probe.DetGrommetType)
    SD.DetGrommetType       = probe.DetGrommetType;
end

if ~isempty(probe.DummyGrommetType)
    SD.DummyGrommetType     = probe.DummyGrommetType;
end

if ~isempty(probe.SrcGrommetType)
    SD.SrcGrommetRot        = probe.SrcGrommetRot;
end

if ~isempty(probe.DetGrommetRot)
    SD.DetGrommetRot        = probe.DetGrommetRot;
end

if ~isempty(probe.DummyGrommetRot)
    SD.DummyGrommetRot      = probe.DummyGrommetRot;
end

% add refpts and head mesh to SD file
refpts.pos = atlasViewer.refpts.pos;
refpts.labels = atlasViewer.refpts.labels;
SD.refpts = refpts;
SD.mesh = atlasViewer.headsurf.mesh;

