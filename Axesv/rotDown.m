function axesv = rotDown(axesv, deg)

if ~exist('deg','var')
    deg = axesv.rotation.degrees;
end
camorbit(axesv.handles.axesSurfDisplay, 0, deg, 'camera');
