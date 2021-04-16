function SD2 = sd_data_Copy(SD2, SD1)
if nargin==0
    SD2 = sd_data_Init();    
end
if nargin==1
    SD1 = sd_data_Init();
end

if isfield(SD1,'Lambda')
    SD2.Lambda = SD1.Lambda;
elseif isfield(SD1,'lambda')
    SD2.Lambda = SD1.lambda;
end

if isfield(SD1,'SrcPos')
    SD2.SrcPos = SD1.SrcPos;
elseif isfield(SD1,'srcpos')
    SD2.SrcPos = SD1.srcpos;
end

if isfield(SD1,'DetPos')
    SD2.DetPos = SD1.DetPos;
elseif isfield(SD1,'detpos')
    SD2.DetPos = SD1.detpos;
end

if isfield(SD1,'DummyPos')
    SD2.DummyPos = SD1.DummyPos;
elseif isfield(SD1,'registration')
    if isfield(SD1.registration,'DummyPos')
        SD2.DummyPos = SD1.registration.dummypos;
    end
end

if isfield(SD1,'SrcPos3D') && isfield(SD1,'DetPos3D') && isfield(SD1,'DummyPos3D')
    SD2.SrcPos3D = SD1.SrcPos3D;
    SD2.DetPos3D = SD1.DetPos3D;
    SD2.DummyPos3D = SD1.DummyPos3D;
elseif isfield(SD1,'optpos_reg')
    SD2 = convertProbe3D2SD(SD1, SD2);
else
    if isfield(SD1,'SrcPos3D')
        SD2.SrcPos3D = SD1.SrcPos3D;
    end
    if isfield(SD1,'DetPos3D')
        SD2.DetPos3D = SD1.DetPos3D;
    end    
    if isfield(SD1,'DummyPos3D')
        SD2.DummyPos3D = SD1.DummyPos3D;
    end
end



if isfield(SD1,'SrcGrommetType')
    if isempty(SD1.SrcGrommetType)
        for ii = 1:size(SD2.SrcPos,1)
            SD2.SrcGrommetType{ii} = 'none';
        end
    else
        SD2.SrcGrommetType = SD1.SrcGrommetType;
    end
elseif isempty(SD2.SrcGrommetType)
    for ii = 1:size(SD2.SrcPos,1)
        SD2.SrcGrommetType{ii} = 'none';
    end
end

if isfield(SD1,'DetGrommetType')
    if isempty(SD1.DetGrommetType)
        for ii = 1:size(SD2.DetPos,1)
            SD2.DetGrommetType{ii} = 'none';
        end
    else
        SD2.DetGrommetType = SD1.DetGrommetType;
    end
elseif isempty(SD2.DetGrommetType)
    for ii = 1:size(SD2.DetPos,1)
        SD2.DetGrommetType{ii} = 'none';
    end
end

if isfield(SD1,'DummyGrommetType')
    if isempty(SD1.DummyGrommetType)
        for ii = 1:size(SD2.DummyPos,1)
            SD2.DummyGrommetType{ii} = 'none';
        end
    else
        SD2.DummyGrommetType = SD1.DummyGrommetType;
    end
elseif isempty(SD2.DummyGrommetType)
    for ii = 1:size(SD2.DummyPos,1)
        SD2.DummyGrommetType{ii} = 'none';
    end
end

if isfield(SD1,'SrcGrommetRot')
    if isempty(SD1.SrcGrommetRot)
        for ii = 1:size(SD2.SrcPos,1)
            SD2.SrcGrommetRot{ii} = 0;
        end
    else
        SD2.SrcGrommetRot = SD1.SrcGrommetRot;
    end
elseif isempty(SD2.SrcGrommetRot)
    for ii = 1:size(SD2.SrcPos,1)
        SD2.SrcGrommetRot{ii} = 0;
    end
end

if isfield(SD1,'DetGrommetRot')
    if isempty(SD1.DetGrommetRot)
        for ii = 1:size(SD2.DetPos,1)
            SD2.DetGrommetRot{ii} = 0;
        end
    else
        SD2.DetGrommetRot = SD1.DetGrommetRot;
    end
elseif isempty(SD2.DetGrommetRot)
    for ii = 1:size(SD2.DetPos,1)
        SD2.DetGrommetRot{ii} = 0;
    end
end

if isfield(SD1,'DummyGrommetRot')
    if isempty(SD1.DummyGrommetRot)
        for ii = 1:size(SD2.DummyPos,1)
            SD2.DummyGrommetRot{ii} = 0;
        end
    else
        SD2.DummyGrommetRot = SD1.DummyGrommetRot;
    end
elseif isempty(SD2.DummyGrommetRot)
    for ii = 1:size(SD2.DummyPos,1)
        SD2.DummyGrommetRot{ii} = 0;
    end
end

if isfield(SD1,'nSrcs')
    SD2.nSrcs = SD1.nSrcs;
end

if isfield(SD1,'nDets')
    SD2.nDets = SD1.nDets;
end

if isfield(SD1,'nDummys')
    SD2.nDummys = SD1.nDummys;
end

if isfield(SD1,'MeasList')
    SD2.MeasList = SD1.MeasList;
elseif isfield(SD1,'ml')
    for ii = 1:length(SD2.Lambda)
        SD2.MeasList = [SD2.MeasList; [SD1.ml(:,[1,2]), ones(size(SD1.ml,1),1), ii*ones(size(SD1.ml,1),1)]];
    end
end

if isfield(SD1,'SpringList')
    SD2.SpringList = SD1.SpringList;
elseif isfield(SD1,'registration')
    if isfield(SD1.registration,'sl')
        SD2.SpringList = SD1.registration.sl;
    end
end
    
if isfield(SD1,'AnchorList')
    SD2.AnchorList = SD1.AnchorList;
elseif isfield(SD1,'registration')
    if isfield(SD1.registration,'al')
        SD2.AnchorList = SD1.registration.al;
    end
end

if isfield(SD1,'MeasListAct')
    SD2.MeasListAct = SD1.MeasListAct;
end

if isfield(SD1,'SrcMap')
    SD2.SrcMap = SD1.SrcMap;
end

if isfield(SD1,'SpatialUnit')
    SD2.SpatialUnit = SD1.SpatialUnit;
end

if isfield(SD1,'xmin')
    SD2.xmin = SD1.xmin;
end

if isfield(SD1,'xmax')
    SD2.xmax = SD1.xmax;
end

if isfield(SD1,'ymin')
    SD2.ymin = SD1.ymin;
end

if isfield(SD1,'ymax')
    SD2.ymax = SD1.ymax;
end

if isfield(SD1,'auxChannels')
    SD2.auxChannels = SD1.auxChannels;
end
