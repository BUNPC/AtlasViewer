function b = sd_data_IsEmpty()
global SD

b = false;

if ~isempty(SD.SrcPos)
    return;
end
if ~isempty(SD.DetPos)
    return;
end
if ~isempty(SD.SrcGrommetType)
    return;
end
if ~isempty(SD.DetGrommetType)
    return;
end
if ~isempty(SD.DummyGrommetType)
    return;
end
if ~isempty(SD.DummyPos)
    return;
end
if ~isempty(SD.MeasList)
    return;
end
if ~isempty(SD.SpringList)
    return;
end
if ~isempty(SD.AnchorList)
    return;
end
if ~isempty(SD.MeasListAct)
    return;
end
if ~isempty(SD.SrcMap)
    return;
end
if ~isempty(SD.SpatialUnit)
    return;
end
if ~isempty(SD.auxChannels)
    return;
end

b = true;

