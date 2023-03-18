function probe = convertSD2probe(SD)

probe = initProbe();
if nargin == 0
    return;
end
SD = sd_data_Init(SD, 'mm');

probe.lambda = SD.Lambda(:)';

% Determine units of src/det coordinates
if ~isempty(SD.SrcPos3D)
    probe.srcpos = SD.SrcPos3D;
else
    probe.srcpos = SD.SrcPos;
end
if ~isempty(SD.DetPos3D)
    probe.detpos = SD.DetPos3D;
else
    probe.detpos = SD.DetPos;
end
if ~isempty(SD.DummyPos3D)
    probe.registration.dummypos = SD.DummyPos3D;
else
    probe.registration.dummypos = SD.DummyPos;
end

if ~isempty(SD.MeasList) && size(SD.MeasList,2)==4
    k = find(SD.MeasList(:,4)==1);
    probe.ml = SD.MeasList(k,:);
elseif ~isempty(SD.MeasList) && size(SD.MeasList,2)<4
    probe.ml = SD.MeasList;
    probe.ml(:,3) = ones(size(SD.MeasList,1),1);
    probe.ml(:,4) = ones(size(SD.MeasList,1),1);
else
    probe.ml = [];
end

probe.registration.sl = SD.SpringList;
probe.registration.al = SD.AnchorList;
if ~isempty(SD.Landmarks3D)
    probe.registration.refpts.labels    = SD.Landmarks3D.labels;
    probe.registration.refpts.pos       = SD.Landmarks3D.pos;
end
probe.SrcGrommetType = SD.SrcGrommetType;
probe.DetGrommetType = SD.DetGrommetType;
probe.DummyGrommetType = SD.DummyGrommetType;

% get grommet rotation informationf from SD and add it to the probe. If not
% intialize the grommet rotations to zero.
if ~isempty(SD.SrcGrommetRot)
    probe.SrcGrommetRot = SD.SrcGrommetRot;
else
    probe.SrcGrommetRot = zeros(size(probe.SrcGrommetType));
end
if ~isempty(SD.DetGrommetRot)
    probe.DetGrommetRot = SD.DetGrommetRot;
else
    probe.DetGrommetRot = zeros(size(probe.DetGrommetType));
end
if ~isempty(SD.DummyGrommetRot)
    probe.DummyGrommetRot = SD.DummyGrommetRot;
else
    probe.DummyGrommetRot = zeros(size(probe.DummyGrommetType));
end

probe.optpos = [probe.srcpos; probe.detpos; probe.registration.dummypos];
probe = setNumberOfOptodeTypes(probe, SD);


