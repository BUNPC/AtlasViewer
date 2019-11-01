function headvol = displayHeadvol(headvol, hAxes, newfig)

if isempty(headvol)  || isempty(headvol)
    return;
end
if ~exist('hAxes','var') || isempty(hAxes)
    hAxes = headvol.handles.axes;
end
if ~exist('newfig','var')  || isempty(newfig)
    newfig = 0;
end

if leftRightFlipped(headvol)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end    


% This function is mostly for debug purposes. Headvol is typically 
% not displayed in the AtlasViewGUI

[headvol.handles.hSurf, headvol.handles.hAxes] = ...
    viewvol_in3d_points(headvol.img, 'winter', 'white', axes_order, newfig, 1);


