function sd_data_Init(SDo)
global SD

SD = struct(...
    'Lambda',[], ...
    'SrcPos',[], ...
    'DetPos',[], ...
    'SrcGrommetType',{{}}, ...
    'DetGrommetType',{{}}, ...
    'DummyPos',[], ...
    'nSrcs',0, ...
    'nDets',0, ...
    'nDummys',0, ...
    'MeasList',[], ...
    'SpringList',[], ...
    'AnchorList',[], ...
    'MeasListAct',[], ...
    'SrcMap',[], ...
    'SpatialUnit','', ...
    'xmin',0, ...
    'xmax',0, ...
    'ymin',0, ...
    'ymax',0, ...
    'auxChannels',[] ...
    );

if nargin==0
    return
end

if isfield(SDo,'Lambda')
    SD.Lambda = SDo.Lambda;
end
if isfield(SDo,'SrcPos')
    SD.SrcPos = SDo.SrcPos;
end
if isfield(SDo,'DetPos')
    SD.DetPos = SDo.DetPos;
end
if isfield(SDo,'SrcGrommetType')
    SD.SrcGrommetType = SDo.SrcGrommetType;
end
if isfield(SDo,'DetGrommetType')
    SD.DetGrommetType = SDo.DetGrommetType;
end
if isfield(SDo,'DummyPos')
    SD.DummyPos = SDo.DummyPos;
end
if isfield(SDo,'nSrcs')
    SD.nSrcs = SDo.nSrcs;
end
if isfield(SDo,'nDets')
    SD.nDets = SDo.nDets;
end
if isfield(SDo,'nDummys')
    SD.nDummys = SDo.nDummys;
end
if isfield(SDo,'MeasList')
    SD.MeasList = SDo.MeasList;
end
if isfield(SDo,'SpringList')
    SD.SpringList = SDo.SpringList;
end
if isfield(SDo,'AnchorList')
    SD.AnchorList = SDo.AnchorList;
end
if isfield(SDo,'MeasListAct')
    SD.MeasListAct = SDo.MeasListAct;
end
if isfield(SDo,'SrcMap')
    SD.SrcMap = SDo.SrcMap;
end
if isfield(SDo,'SpatialUnit')
    SD.SpatialUnit = SDo.SpatialUnit;
end
if isfield(SDo,'xmin')
    SD.xmin = SDo.xmin;
end
if isfield(SDo,'xmax')
    SD.xmax = SDo.xmax;
end
if isfield(SDo,'ymin')
    SD.ymin = SDo.ymin;
end
if isfield(SDo,'ymax')
    SD.ymax = SDo.ymax;
end
if isfield(SDo,'auxChannels')
    SD.auxChannels = SDo.auxChannels;
end

SDgui_AtlasViewerGUI('update');

