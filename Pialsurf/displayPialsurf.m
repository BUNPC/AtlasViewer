function pialsurf = displayPialsurf(pialsurf, hAxes)

if isempty(pialsurf)
    return;
end
if pialsurf.isempty(pialsurf)
    return;
end
if ~exist('hAxes','var')
    hAxes = pialsurf.handles.axes;
end

if ishandles(pialsurf.handles.surf)
    delete(pialsurf.handles.surf);
end

if leftRightFlipped(pialsurf)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

h=[];
hLighting=[];
if isempty(pialsurf.mesh)
    menu('Warning: pialsurf file does not exist in current directory','ok');
    return;
else
    viewAxesXYZ(hAxes, axes_order);
    
    [h hLighting] = viewsurf(pialsurf.mesh, 1, pialsurf.color, 'off', axes_order);
    hold off
end

pialsurf.handles.surf = h;
pialsurf.handles.hLighting = hLighting;

if ishandles(pialsurf.handles.surf)
    set(pialsurf.handles.editTransparency,'string', num2str(get(pialsurf.handles.surf,'facealpha')));
    set(pialsurf.handles.editTransparency,'enable','on');
    set(pialsurf.handles.radiobuttonShowPial,'enable','on');
    set(pialsurf.handles.radiobuttonShowPial,'value',1);
else
    set(pialsurf.handles.radiobuttonShowPial,'enable','off');
    set(pialsurf.handles.radiobuttonShowPial,'value',1);
end
