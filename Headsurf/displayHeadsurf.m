function headsurf = displayHeadsurf(headsurf, hAxes, options)

if isempty(headsurf)
    return;
end
if headsurf.isempty(headsurf)
    return;
end
if ~exist('hAxes','var') | isempty(hAxes)
    hAxes = headsurf.handles.axes;
end
if ~exist('options','var') | isempty(options)
    options = 'patch';
end

if AVUtils.ishandles(headsurf.handles.surf)
    delete(headsurf.handles.surf);
end

if leftRightFlipped(headsurf)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

if isempty(headsurf.center)
    headsurf.center = findcenter(headsurf.mesh.vertices);
    headsurf.centerRotation = headsurf.center;
end
if isempty(headsurf.centerRotation)
    headsurf.centerRotation = headsurf.center;
end

h=[];
if isempty(headsurf.mesh)
    menu('head file does not exist in current directory','ok');
    return;
else
    viewAxesXYZ(hAxes, axes_order);
    if strcmpi(options,'surf')
        h = viewsurf3(headsurf.mesh, .7, [.6, .95, .5], 'off', axes_order);
    else
    	h = viewsurf(headsurf.mesh, .7, headsurf.color, 'off', axes_order);
    end
    hold off
end
headsurf.handles.surf = h;

if AVUtils.ishandles(headsurf.handles.surf)
    if AVUtils.ishandles(headsurf.handles.radiobuttonShowHead)
        set(headsurf.handles.radiobuttonShowHead,'value',1);
        set(headsurf.handles.radiobuttonShowHead,'enable','on');
        set(headsurf.handles.editTransparency,'enable','on');
        set(headsurf.handles.editTransparency,'string', num2str(get(headsurf.handles.surf,'facealpha')));
        set(headsurf.handles.menuItemMakeProbe,'enable','on');
        set(headsurf.handles.menuItemImportProbe,'enable','on');
    end
else
    if AVUtils.ishandles(headsurf.handles.radiobuttonShowHead)
        set(headsurf.handles.radiobuttonShowHead,'enable','off');
        set(headsurf.handles.menuItemMakeProbe,'enable','off');
        set(headsurf.handles.menuItemImportProbe,'enable','off');
    end
end


