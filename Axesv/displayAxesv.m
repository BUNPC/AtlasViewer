function axesv = displayAxesv(axesv, headsurf, headvol, digpts)

if isempty(axesv)
    return;
end

% for displayAxesv whichever head object (headsurf or headvol) 
% is not empty will work. 
if ~headsurf.isempty(headsurf)
    headobj = headsurf;
else
    headobj = headvol;
end

%%%% Position axes 
axis(axesv(1).handles.axesSurfDisplay,'vis3d');
axis(axesv(1).handles.axesSurfDisplay,'equal');
set(axesv(1).handles.axesSurfDisplay,'units','normalized');
if strcmp(axesv(1).mode,'surface')
    pos = get(axesv(1).handles.axesSurfDisplay, 'position');
    set(axesv(1).handles.axesSurfDisplay, 'position', [pos(1) pos(2) .5 .4])
end

%%%% Set axes boundaries 
set(axesv(1).handles.axesSurfDisplay, {'xlimmode','ylimmode','zlimmode'}, {'manual','manual','manual'});
padding = 50;
xlim = get(axesv(1).handles.axesSurfDisplay, 'xlim');
ylim = get(axesv(1).handles.axesSurfDisplay, 'ylim');
zlim = get(axesv(1).handles.axesSurfDisplay, 'zlim');
set(axesv(1).handles.axesSurfDisplay, 'xlim',[xlim(1)-padding, xlim(2)+padding])
set(axesv(1).handles.axesSurfDisplay, 'ylim',[ylim(1)-padding, ylim(2)+padding])
set(axesv(1).handles.axesSurfDisplay, 'zlim',[zlim(1)-padding, zlim(2)+padding])
p = get(axesv(1).handles.axesSurfDisplay, 'position');
set(axesv(1).handles.axesSurfDisplay, 'position', [p(1), 1-p(4)-.13, p(3), p(4)]);

%%%% Set the lighting
axesv = setLighting(axesv, headobj);

%%%% Find center of all the objects on the canvas, and set camera target to it
c1 = [];
c2 = [];
if ~headobj.isempty(headobj)
    c1  = headobj.centerRotation;
end
if ~digpts.isempty(digpts)
    c2  = digpts.center;
end
if ~isempty(c1)
    c = c1;
elseif ~isempty(c2)
    c = c2;
else
    c = [0,0,0];
end
axesv(1).cameratarget = c;
if ~all(c==0)
    set(axesv(1).handles.axesSurfDisplay, 'cameratarget', axesv(1).cameratarget);
end


%%%% Set view angles 
setViewAngles(axesv(1).handles.axesSurfDisplay, headobj.orientation, axesv(1).azimuth, axesv(1).elevation);

%%%% Set azimuth and elevation edit boxes in GUI
[az_new, el_new] = getViewAngles(axesv(1).handles.axesSurfDisplay, headobj.orientation);
set(axesv(1).handles.editViewAnglesAzimuth, 'string', sprintf('%0.2f', az_new));
set(axesv(1).handles.editViewAnglesElevation, 'string', sprintf('%0.2f', el_new));


%%%% Find and set zoom by setting the camera position distance 
%%%% from camera target.
setZoom(axesv(1).handles.axesSurfDisplay, axesv(1).distCameraTarget);

drawnow;

