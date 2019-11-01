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


%%%% Before updating axesv(1).cameraposition and axesv(1).cameratarget 
%%%% get old distance between them. 
d0 = [];
if ~isempty(axesv(1).cameraposition) & ~isempty(axesv(1).cameratarget)
    v0 = axesv(1).cameraposition - axesv(1).cameratarget;
    d0 = sqrt( v0(1)^2 + v0(2)^2 + v0(3)^2 );
end

%%%% Find center of all the objects on the canvas, and set caera target to it
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

cp0 = get(axesv(1).handles.axesSurfDisplay, 'cameraposition');


%%%% Find and set zoom by setting the camera position distance 
%%%% from camera target.
cp0 = get(axesv(1).handles.axesSurfDisplay, 'cameraposition');
ct0 = get(axesv(1).handles.axesSurfDisplay, 'cameratarget');
va = cp0-ct0;
d1 = sqrt( va(1)^2 + va(2)^2 + va(3)^2 );
if ~isempty(d0)
    cp_new = ct0 + (va * (d0/d1));
else
    cp_new = ct0 + (va * .7);
end
axesv(1).cameraposition = cp_new;
v_up = get(axesv(1).handles.axesSurfDisplay, 'cameraupvector');
if angleBetweenVectors(abs(va), abs(v_up))==0
    v_up = [va(2), va(1), va(3)];
end
set(axesv(1).handles.axesSurfDisplay, 'cameraupvector', v_up);
set(axesv(1).handles.axesSurfDisplay, 'cameraposition', axesv(1).cameraposition);

drawnow;

