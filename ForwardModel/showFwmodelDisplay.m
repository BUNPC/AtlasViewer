function fwmodel = showFwmodelDisplay(fwmodel, hAxes, val)

if ~ishandles(fwmodel.handles.surf)
    return;
end
if isempty(hAxes)
    hAxes = gca;
end

if val==0
    val='off';
elseif val==1
    val='on';
end

if strcmp(val,'off')
    fwmodel = setSensitivityColormap(fwmodel, []);
elseif strcmp(val,'on')
    fwmodel = setSensitivityColormap(fwmodel, hAxes);
end
set(fwmodel.handles.surf, 'visible',val);
setImageDisplay_EmptyImage(fwmodel.handles.surf, val)

