function fwmodel = showFwmodelDisplay(fwmodel, hAxes, val)

if isempty(fwmodel.handles.surf)
    return;
end
if isempty(hAxes)
    hAxes=gca;
end

if val==0
    val='off';
elseif val==1
    val='on';
end

if strcmp(get(fwmodel.handles.surf,'visible'), val)
    return
end

if strcmp(val,'off')
    fwmodel = setSensitivityColormap(fwmodel, []);
elseif strcmp(val,'on')
    fwmodel = setSensitivityColormap(fwmodel, hAxes);
end

% set(fwmodel.handles.editSelectChannel,'visible',val);
% set(fwmodel.handles.textSelectChannel,'visible',val);
% set(fwmodel.handles.editColormapThreshold,'visible',val);
% set(fwmodel.handles.textColormapThreshold,'visible',val);
set(fwmodel.handles.surf,'visible',val);

