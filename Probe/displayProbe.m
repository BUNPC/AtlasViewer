function probe = displayProbe(probe, headobj, hAxes)

if isempty(probe)
    return;
end
if probe.isempty(probe)
    return;
end
if ~exist('hAxes','var')
    hAxes = probe.handles.axes;
end
if ~exist('headobj','var')
    headobj = [];
end

    
if ishandles(probe.handles.labels)
    probe.handles.textSize = get(probe.handles.labels(1),'fontsize');
    delete(probe.handles.labels);
end
if ishandles(probe.handles.circles)
    probe.handles.circleSize = get(probe.handles.circles(1),'markersize');
    delete(probe.handles.circles);
end

if leftRightFlipped(headobj)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

viewAxesXYZ(hAxes, axes_order);

probe = viewProbe(probe, 'registered');
% probe = viewProbeLandmarks(probe);

probe = setProbeDisplay(probe, headobj);
hold off;




% ----------------------------------------------------------
function probe = viewProbeLandmarks(probe)
if leftRightFlipped(probe)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end
if ~isempty(probe.registration.refpts.pos)
    pts = prepPtsStructForViewing(probe.registration.refpts.pos, size(probe.registration.refpts.pos,1), ...
        'refptslabels', [0.25,0.50,0.00], [11,22], probe.registration.refpts.labels);
    probe.handles.hRefpts = viewPts(pts, [], 0, axes_order);
end

