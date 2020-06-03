function digpts = displayDigpts(digpts, hAxes)

if isempty(digpts)
    return;
end
if digpts.isempty(digpts)
    return;
end
if ~exist('hAxes','var')
    hAxes = digpts.handles.axes;
end

if AVUtils.ishandles(digpts.handles.hPcpos)
    delete(digpts.handles.hPcpos);
end
if AVUtils.ishandles(digpts.handles.hRefpts)
    delete(digpts.handles.hRefpts);
end
if AVUtils.ishandles(digpts.handles.hSrcpos)
    delete(digpts.handles.hSrcpos);
end 
if AVUtils.ishandles(digpts.handles.hDetpos)
    delete(digpts.handles.hDetpos);
end 
if AVUtils.ishandles(digpts.handles.hOptodes)
    delete(digpts.handles.hOptodes);
end

if isempty(digpts.orientation)
    [nz,iz,rpa,lpa,cz] = getLandmarks(digpts.refpts);
    [digpts.refpts.orientation, digpts.refpts.center] = getOrientation(nz, iz, rpa, lpa, cz);
    digpts.orientation = digpts.refpts.orientation;
    digpts.center      = digpts.refpts.center;    
end

if leftRightFlipped(digpts)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

% Display if axes handle exists
viewAxesXYZ(hAxes, axes_order);
pc = digpts.pcpos;
rp = digpts.refpts.pos;
if ~isempty(pc)
    pts = prepPtsStructForViewing(pc, size(pc,1), 'probenum', 'g');
    digpts.handles.hPcpos = viewPts(pts, [], 0, axes_order);
end
if ~isempty(rp)
    pts = prepPtsStructForViewing(rp,size(rp,1), 'refptslabels', [0.25,0.50,0.00], 11, digpts.refpts.labels);
    digpts.handles.hRefpts = viewPts(pts, [], 0, axes_order);
end
digpts.handles.hOptodes = [digpts.handles.hSrcpos; digpts.handles.hDetpos];
hold off;

if ~isempty(digpts.refpts.pos)
    set(digpts.handles.radiobuttonShowDigpts,'enable','on');
else
    set(digpts.handles.radiobuttonShowDigpts,'enable','off');
end

if get(digpts.handles.radiobuttonShowDigpts,'value')==0
    set(digpts.handles.hPcpos,'visible','off');
    set(digpts.handles.hRefpts,'visible','off');
else
    set(digpts.handles.hPcpos,'visible','on');
    set(digpts.handles.hRefpts,'visible','on');
end
