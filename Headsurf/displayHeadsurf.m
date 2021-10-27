function headsurf = displayHeadsurf(headsurf, hAxes, options)
global cfg

cfg = InitConfig(cfg);

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

if ishandles(headsurf.handles.surf)
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
    head_opacity = str2num(cfg.GetValue('Head Opacity'));
    if ~exist('head_opacity','var')
        head_opacity = 0.7;
    end
    if strcmpi(options,'surf')
        h = viewsurf3(headsurf.mesh, head_opacity, [.6, .95, .5], 'off', axes_order);
    else
    	h = viewsurf(headsurf.mesh, head_opacity, headsurf.color, 'off', axes_order);
    end
    hold off
end
headsurf.handles.surf = h;

if ishandles(headsurf.handles.surf)
    if ishandles(headsurf.handles.radiobuttonShowHead)
        set(headsurf.handles.radiobuttonShowHead,'value',1);
        set(headsurf.handles.radiobuttonShowHead,'enable','on');
        set(headsurf.handles.editTransparency,'enable','on');
        set(headsurf.handles.editTransparency,'string', num2str(get(headsurf.handles.surf,'facealpha')));
        set(headsurf.handles.menuItemProbeCreate,'enable','on');
        set(headsurf.handles.menuItemProbeImport,'enable','on');
    end
else
    if ishandles(headsurf.handles.radiobuttonShowHead)
        set(headsurf.handles.radiobuttonShowHead,'enable','off');
        set(headsurf.handles.menuItemProbeCreate,'enable','off');
        set(headsurf.handles.menuItemProbeImport,'enable','off');
    end
end


