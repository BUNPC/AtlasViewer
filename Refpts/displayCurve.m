function h = displayCurve(headmesh, curve, axes_order)

if ~exist('axes_order','var')
    axes_order = [2,1,3];
end
if ~exist('curve','var') | isempty(curve)
    if 0
        figure;
        v = reduceMesh(headmesh.vertices, headmesh.faces, .1);
        h = plot3(v(:,axes_order(1)), v(:,axes_order(2)), v(:,axes_order(3)), '.r');
    else
        axes();
    end
    
    grid on
    axis equal
    return;
else
    hold on
    c = curve;
    h = plot3(c(:,axes_order(1)), c(:,axes_order(2)), c(:,axes_order(3)), '.b');
    drawnow;
    hold off
end
