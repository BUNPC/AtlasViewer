function idx = getCurrElemIdx(hGroupList)
idx = [];
if ~ishandles(hGroupList)
    return;
end

idx = 0;
idx0 = get(hGroupList, 'value');
if idx0==1
    idx = 0;
elseif idx0 > 1
    idx = idx0-1;
end
