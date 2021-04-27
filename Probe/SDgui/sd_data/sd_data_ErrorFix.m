function err = sd_data_ErrorFix()
global SD

err = false;

if sd_data_IsEmpty()
    return
end

% SrcPos
if(~isfield(SD,'SrcPos'))
    SD.SrcPos = [];
end

% DetPos
if(~isfield(SD,'DetPos'))
    SD.DetPos = [];
end

if(~isfield(SD,'DummyPos'))
    SD.DummyPos = [];
end

% SrcPos
SD.nSrcs = size(SD.SrcPos,1);

% DetPos
SD.nDets = size(SD.DetPos,1);

% Lambda
nwl = sd_data_GetNwl();
if ~isfield(SD,'Lambda') || isempty(SD.Lambda)
    SD.Lambda = [];
end

% MeasList
if ~isfield(SD,'MeasList')
    SD.MeasList = [];
elseif ~isempty(SD.MeasList)
    measListErrorFix();
end

% MesListAct
if isfield(SD,'MeasListAct') && isempty(SD.MeasListAct)
    SD.MeasListAct = ones(size(SD.MeasList,1),1);
end


% SpringList
if(~isfield(SD,'SpringList'))
    SD.SpringList = [];
end
ii = 1;
while ii<=size(SD.SpringList,1)
    k = find(SD.SpringList(:,1)==SD.SpringList(ii,1) & SD.SpringList(:,2)==SD.SpringList(ii,2));
    if length(k)>1 && err==false
        q = menu(sprintf('Corruption error: More than one spring for optode pair (%d,%d). Do you want to fix it by removing one spring?', ...
            SD.SpringList(ii,1), SD.SpringList(ii,2)), 'YES','NO');
        if q==1
            SD.SpringList(k(2:end),:) = [];
        else
            err = true;
        end
    end
    ii = ii+1;
end

% AnchorList
if ~isfield(SD,'AnchorList')
    SD.AnchorList = [];
end

% SpatialUnit
if isfield(SD,'SpatialUnit') && strcmpi(SD.SpatialUnit,'cm')
    ch = MenuBox('We recommend using spatial units of mm to be consistent with Homer. Convert cm to mm?', {'Okay','Cancel'}, 'upperleft');
    if ch==1
        SD.SpatialUnit = 'mm';
        SD.SrcPos = SD.SrcPos * 10;
        SD.DetPos = SD.DetPos * 10;
        SD.DummyPos = SD.DummyPos * 10;
        if isfield(SD,'SpringList')
            if size(SD.SpringList,2)==3
                lst = find(SD.SpringList(:,3)~=-1);
                SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
            end
        end
    end
elseif ~isfield(SD,'SpatialUnit') || isempty(SD.SpatialUnit)
    ch = MenuBox('Spatial units not provided in SD file. Please specify spatial units used for the optode positions in this file?',{'cm','mm','Do not know'}, 'upperleft');
    if ch==1
        ch = MenuBox('We recommend using spatial units of mm to be consistent with Homer. Convert cm to mm?', {'Okay','Cancel'}, 'upperleft');
        if ch==1
            SD.SpatialUnit = 'mm';
            SD.SrcPos = SD.SrcPos * 10;
            SD.DetPos = SD.DetPos * 10;
            SD.DummyPos = SD.DummyPos * 10;
            if isfield(SD,'SpringList')
                if size(SD.SpringList,2)==3
                    lst = find(SD.SpringList(:,3)~=-1);
                    SD.SpringList(lst,3) = SD.SpringList(lst,3) * 10;
                end
            end
        else
            SD.SpatialUnit = 'cm';
        end
    elseif ch==2
        SD.SpatialUnit = 'mm';
    elseif ch==3
        MessageBox('Assuming spatial mm spatial units.');
        SD.SpatialUnit = 'mm';
    end
end

% SrcMap
if ~isfield(SD,'SrcMap')
    SD.SrcMap = [];
elseif nwl>0 && SD.nSrcs>0 && isempty(SD.SrcMap)
    sd_data_SetSrcMapDefault();
elseif nwl>0 && SD.nSrcs>0 && (size(SD.SrcMap,1) ~= nwl)
    SD.SrcMap = reshape(SD.SrcMap(:),nwl,SD.nSrcs);
end







% -----------------------------------------------------------
function status = measListErrorFix()
global SD

status = 0;

% Get error status
if ~all(iswholenum(SD.MeasList(:)))
    status = 1;
else
    if size(SD.MeasList,2)<4
        status = 2;
    end
    
    ml_actual = sd_data_GetMeasList();
    ml_true = unique(SD.MeasList(:,[1,2]), 'rows','stable');
    ml = ml_actual;
    
    if length(ml_actual(:)) ~= length(ml_true(:))
        status = 3;
    elseif ~all(ml_actual == ml_true)
        status = 4;
    end
    
    nwl = sd_data_GetNwl();
    if (nwl ~= length(unique(SD.MeasList(:,end)))) && (SD.nSrcs>0)
        status = 5;
    end
end

% Try to fix based on determined error status
if status == 1
    MessageBox('Warning: Error in measurement list that cannot be fixed.');
elseif status > 1
    MessageBox('Warning: Error in measurement list. SDgui will attempt to fix it.');
    if status == 2
        SD.MeasList(:,[3,4]) = [1,1];
    end
    if status == 3 || status == 4
        ml = ml_true;
    end    
end

if status > 2
    sd_data_SetMeasList(ml);
end

