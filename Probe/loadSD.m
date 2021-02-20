function probe = loadSD(probe,SD)

if isempty(SD)
    return;
end

if isfield(SD,'Lambda')
    probe.lambda = SD.Lambda(:)';
else
    probe.lambda = [];
end

% Determine units of src/det coordinates
if isfield(SD,'SpatialUnit')
    unitsStr = SD.SpatialUnit;
else
    unitsStr = 'mm';
end
scaleFactor = 1;
if ischar(unitsStr) && strcmp(unitsStr,'cm')
    scaleFactor = 10;   % convert to mm if SD units are cm
end

if isfield(SD,'SrcPos')
    probe.srcpos = scaleFactor*SD.SrcPos;
else
    probe.srcpos = [];
end
if isfield(SD,'DetPos')
    probe.detpos = scaleFactor*SD.DetPos;
else
    probe.detpos = [];
end
if isfield(SD,'DummyPos')
    probe.registration.dummypos = SD.DummyPos;
else
    probe.registration.dummypos = [];
end
if isfield(SD,'nSrcs')
    probe.nsrc = SD.nSrcs;
else
    probe.nsrc = size(probe.srcpos,1);
end
if isfield(SD,'nDets')
    probe.ndet = SD.nDets;
else
    probe.ndet = size(probe.detpos,1);
end

if isfield(SD,'MeasList') && ~isempty(SD.MeasList) && size(SD.MeasList,2)>=4
    k = find(SD.MeasList(:,4)==1);
    probe.ml = SD.MeasList(k,:);
    if isfield(SD,'MeasListAct') && (size(SD.MeasListAct,1)==size(probe.ml,1))
        probe.ml(:,3) = SD.MeasListAct(k);
    else
        probe.ml(:,3) = ones(length(k),1);
    end
elseif isfield(SD,'MeasList') && ~isempty(SD.MeasList) && size(SD.MeasList,2)<4
    probe.ml = SD.MeasList;
    probe.ml(:,3) = ones(size(SD.MeasList,1),1);
else
    probe.ml=[];
end

if isfield(SD,'SpringList')
    probe.registration.sl = SD.SpringList;
else
    probe.registration.sl = [];
end
if isfield(SD,'AnchorList')
    probe.registration.al = SD.AnchorList;
else
    probe.registration.al = [];
end

if isfield(SD,'SrcGrommetType')
    probe.SrcGrommetType = SD.SrcGrommetType;
else
    probe.SrcGrommetType = {};
end
if isfield(SD,'DetGrommetType')
    probe.DetGrommetType = SD.DetGrommetType;
else
    probe.DetGrommetType = {};
end
if isfield(SD,'DummyGrommetType')
    probe.DummyGrommetType = SD.DummyGrommetType;
else
    probe.DummyGrommetType = {};
end

% get grommet rotation informationf from SD and add it to the probe. If not
% intialize the grommet rotations to zero.
if isfield(SD,'SrcGrommetRot')
    probe.SrcGrommetRot = SD.SrcGrommetRot;
else
    probe.SrcGrommetRot = zeros(size(probe.SrcGrommetType));
end
if isfield(SD,'DetGrommetRot')
    probe.DetGrommetRot = SD.DetGrommetRot;
else
    probe.DetGrommetRot = zeros(size(probe.DetGrommetType));
end
if isfield(SD,'DummyGrommetRot')
    probe.DummyGrommetRot = SD.DummyGrommetRot;
else
    probe.DummyGrommetRot = zeros(size(probe.DummyGrommetType));
end

probe.optpos = [probe.srcpos; probe.detpos; probe.registration.dummypos];
probe.nopt = size(probe.optpos, 1);
probe.noptorig = size([probe.srcpos; probe.detpos],1);

