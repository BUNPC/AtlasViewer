function pialvol = displayPialvol(pialvol, hAxes, newfig)

if isempty(pialvol)  || isempty(pialvol)
    return;
end
if ~exist('hAxes','var') || isempty(hAxes)
    hAxes = pialvol.handles.axes;
end
if ~exist('newfig','var')  || isempty(newfig)
    newfig = 0;
end

if leftRightFlipped(pialvol)
    axes_order=[2 1 3];
else
    axes_order=[1 2 3];
end    


% This function is mostly for debug purposes. Pialvol is typically 
% not displayed in the AtlasViewGUI

[pialvol.handles.hSurf, pialvol.handles.hAxes] = ...
    viewvol_in3d_points(pialvol.img, 'winter', 'white', axes_order, newfig, 1);


