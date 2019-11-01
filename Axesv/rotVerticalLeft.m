function axesv = rotVerticalLeft(axesv, deg)

if ~exist('deg','var')
    deg = axesv.rotation.degrees;
end
camroll(axesv.handles.axesSurfDisplay, deg);
