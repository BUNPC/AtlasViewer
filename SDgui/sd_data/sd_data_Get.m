function data = sd_data_Get(datatype)
global SD

data = [];

if isempty(SD)
    datatype = 'all';
end

switch lower(datatype)
    case {'lambda'}
        data = SD.Lambda;
    case {'srcpos'}
        data = SD.SrcPos;
    case {'detpos'}
        data = SD.DetPos;
	case {'srcgrommettype'}
        if isempty(SD.SrcGrommetType)
            c = sd_data_GetGrommetChoices();
            SD.SrcGrommetType = repmat(c(1), size(SD.SrcPos,1), 1);
        end
	    data = SD.SrcGrommetType;
	case {'detgrommettype'}
        if isempty(SD.DetGrommetType)
            c = sd_data_GetGrommetChoices();
            SD.DetGrommetType = repmat(c(1), size(SD.DetPos,1), 1);
        end
	    data = SD.DetGrommetType;
	case {'dummygrommettype'}
        if isempty(SD.DummyGrommetType)
            c = sd_data_GetGrommetChoices();
            SD.DummyGrommetType = repmat(c(end), size(SD.DummyPos,1), 1);
        end
	    data = SD.DummyGrommetType;
    case {'dummypos'}
        data = SD.DummyPos;
    case {'nsrcs'}
        data = size(SD.SrcPos,1);
    case {'ndets'}
        data = size(SD.DetPos,1);
    case {'measlist'}
        data = SD.MeasList;
    case {'springlist'}
        data = SD.SpringList;
    case {'anchorlist'}
        data = SD.AnchorList;
    case {'srcmap'}
        data = SD.SrcMap;
	case {'spatialunit'}
        data = SD.SpatialUnit;
    case {'all'}
        data = SD;
end


