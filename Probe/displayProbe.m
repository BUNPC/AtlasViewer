function probe = displayProbe(probe, headsurf, hAxes)

if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
if ~exist('hAxes','var')
    hAxes = probe.handles.axes;
end

if ishandles(probe.handles.labels)
    probe.handles.textSize = get(probe.handles.labels(1),'fontsize');
    delete(probe.handles.labels);
end
if ishandles(probe.handles.circles)
    probe.handles.circleSize = get(probe.handles.circles(1),'markersize');
    delete(probe.handles.circles);
end

if leftRightFlipped(headsurf)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

viewAxesXYZ(hAxes, axes_order);

probe = viewProbe(probe, 'registered');
probe = setProbeDisplay(probe, headsurf);
hold off;

