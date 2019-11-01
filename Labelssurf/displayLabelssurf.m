function labelssurf = displayLabelssurf(labelssurf, hAxes)

if isempty(labelssurf)
    return;
end
if labelssurf.isempty(labelssurf)
    return;
end
if ~exist('hAxes','var')
    hAxes = labelssurf.handles.axes;
end

if ishandles(labelssurf.handles.surf)
    delete(labelssurf.handles.surf);
end

if leftRightFlipped(labelssurf)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

h = [];
hLighting = [];
if isempty(labelssurf.mesh)
    menu('Warning: labels file does not exist in current directory','ok');
    return;
else
    viewAxesXYZ(hAxes, axes_order);
    if ~isempty(labelssurf.colormaps)
        [h hLighting] = viewsurf2(labelssurf.mesh, ...
                                  ones(length(labelssurf.idxL),1), ...
                                  labelssurf.colormaps(4).col(labelssurf.idxL,:), ...
                                  'off', ...
                                  axes_order);
    end
    hold off
end
labelssurf.handles.surf = h;
labelssurf.handles.hLighting = hLighting;

if ishandles(labelssurf.handles.surf)
    a = get(labelssurf.handles.surf,'facevertexalphadata');
    set(labelssurf.handles.editTransparency,'string', num2str(a(1)));
    set(labelssurf.handles.editTransparency,'enable','on');
    set(labelssurf.handles.radiobuttonShowLabels,'enable','on');
    set(labelssurf.handles.radiobuttonShowLabels,'value',0);
    set(labelssurf.handles.menuItemSelectLabelsColormap,'enable','on');
    set(labelssurf.handles.surf,'visible','off');
else
    set(labelssurf.handles.radiobuttonShowLabels,'enable','off');
    set(labelssurf.handles.radiobuttonShowLabels,'value',0);
    set(labelssurf.handles.menuItemSelectLabelsColormap,'enable','off');
end

