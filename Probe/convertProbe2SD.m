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
SD.nDummys               = probe.registration.ndummy;
SD.MeasList             = [];
[unique_probe_ml, ia, ic] = unique(probe.ml(:,[1,2]),'rows', 'stable'); 
for ii = 1:length(SD.Lambda)
    SD.MeasList         = [SD.MeasList; [unique_probe_ml, ones(size(unique_probe_ml,1),1), ii*ones(size(unique_probe_ml,1),1)]];
end
if size(probe.ml,2) > 2
    for ii = 1:length(SD.Lambda)
        SD.MeasListAct = [SD.MeasListAct; probe.ml(:,3)];
    end
end

SD.SpringList           = probe.registration.sl;
SD.AnchorList           = probe.registration.al;

if isfield(probe,'SrcGrommetType')
    SD.SrcGrommetType       = probe.SrcGrommetType;
end

if isfield(probe,'DetGrommetType')
    SD.DetGrommetType       = probe.DetGrommetType;
end

if isfield(probe,'DummyGrommetType')
    SD.DummyGrommetType     = probe.DummyGrommetType;
end

if isfield(probe,'SrcGrommetType')
    SD.SrcGrommetRot        = probe.SrcGrommetRot;
end

if isfield(probe,'DetGrommetRot')
    SD.DetGrommetRot        = probe.DetGrommetRot;
end

if isfield(probe,'DummyGrommetRot')
    SD.DummyGrommetRot      = probe.DummyGrommetRot;
end

% get orientation info
if isfield(probe,'orientation')
    SD.orientation      = probe.orientation;
end

% add refpts and head mesh to SD file
if ~isempty(atlasViewer)
    % ninjaCap requires 10-5 eeg reference points to generate STL files
    % correctly. So while saving SD file, here we always save 10-5 reference
    % points
    refpts = atlasViewer.refpts;
    refpts.eeg_system.selected = '10-5';
    set_eeg_curve_select(refpts);
    refpts = setRefptsMenuItemSelection(refpts);
    refpts = set_eeg_active_pts(refpts,'warning',false);
    if isfield(refpts,'eeg_system')
        SD.Landmarks.eeg_system =refpts.eeg_system;
    end
    if isfield(refpts,'scaling')
        SD.Landmarks.scaling = refpts.scaling;
    end
    SD.Landmarks.pos = refpts.pos;
    SD.Landmarks.labels = refpts.labels;
    SD.mesh = atlasViewer.headsurf.mesh;
end

SD = updateProbe2DcircularPts(probe, SD);


