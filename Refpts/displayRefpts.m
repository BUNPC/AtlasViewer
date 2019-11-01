function refpts = displayRefpts(refpts, hAxes)

if ~exist('hAxes','var')
    hAxes = refpts.handles.axes;
end
if ishandles(refpts.handles.labels)
    delete(refpts.handles.labels);
end
if ishandles(refpts.handles.circles)
    delete(refpts.handles.circles);
end

if isempty(refpts)
    return;
end
if refpts.isempty(refpts)
    return;
end

if isempty(refpts.orientation)
    [nz,iz,rpa,lpa,cz] = getLandmarks(refpts);
    [refpts.orientation, refpts.center] = getOrientation(nz, iz, rpa, lpa, cz);
end

if leftRightFlipped(refpts)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

% View ref points on surface
viewAxesXYZ(hAxes, axes_order, [0,0,0]);
viewAxesRAS(hAxes, axes_order, refpts);

pts=[];
for ii=1:length(refpts.labels)
    pts(ii).pos        = refpts.pos(ii,:);
    pts(ii).str        = refpts.labels{ii};
    pts(ii).col        = refpts.handles.color;
    pts(ii).textsize   = refpts.handles.textSize;
    pts(ii).circlesize = refpts.handles.circleSize;
end
[hLabels, hCircles]  = viewPts(pts, refpts.center, 0, axes_order);
hold off

refpts.handles.labels = hLabels;
refpts.handles.circles = hCircles;
refpts.handles.selected = zeros(size(hLabels,1),1)-1;

if ishandles(refpts.handles.labels)
    set(refpts.handles.radiobuttonShowRefptsLabels,'enable','on');
    set(refpts.handles.radiobuttonShowRefptsCircles,'enable','on');
    set(refpts.handles.radiobuttonHeadDimensions, 'enable','on');
else
    set(refpts.handles.radiobuttonShowRefptsLabels,'enable','off');
    set(refpts.handles.radiobuttonShowRefptsCircles,'enable','off');
    set(refpts.handles.radiobuttonHeadDimensions, 'enable','off');
end
if length(refpts.labels)>=5
    set(refpts.handles.menuItemShowRefpts,'enable','on');
else
    set(refpts.handles.menuItemShowRefpts,'enable','off');
end

radiobuttonShowRefpts(refpts.handles.radiobuttonShowRefptsLabels, refpts, []);
