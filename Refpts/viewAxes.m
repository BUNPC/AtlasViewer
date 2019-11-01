function viewAxes(refpts, hAxes, axes_order)

% Arg 1
if ~ishandles(hAxes)
    hAxes = gca;
    set(hAxes, {'xgrid', 'ygrid','zgrid'}, {'on','on','on'});
    axis vis3d;
    axis equal
    rotate3d
    setappdata(h, 'hOrigin',{});
    setappdata(h, 'hViewOrigin',[]);
end

viewAxesXYZ(hAxes, axes_order, [0,0,0]);
viewAxesRAS(hAxes, axes_order, refpts.pos);
