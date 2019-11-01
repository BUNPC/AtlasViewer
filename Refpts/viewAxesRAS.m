function viewAxesRAS(hAxes, axes_order, refpts, mode)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Parse arguments
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Arg 1
if ~ishandles(hAxes)
    hAxes = gca;
    set(hAxes, {'xgrid', 'ygrid','zgrid'}, {'on','on','on'});
    axis vis3d;
    axis equal
    rotate3d
    setappdata(h, 'hOrigin',[]);
    setappdata(h, 'hViewOrigin',[]);
end

% Arg 2
if ~exist('axes_order','var') || isempty(axes_order)
    return;   % must have legitimate value for this arg
end

% Arg 3
if ~exist('refpts','var') || isempty(refpts)
    nz  = [];
    iz  = [];
    rpa = [];
    lpa = [];
    cz  = [];
    czo = [];
else      
    [nz, iz, rpa, lpa, cz, czo] = findRefptsAxes(refpts);
end

% Arg 4
if ~exist('mode','var')
    mode = 'redraw';
end

axes(hAxes); hold on
hOrigin = getappdata(hAxes, 'hOrigin');
hViewOrigin = getappdata(hAxes, 'hViewOrigin');
if ~ishandles(hViewOrigin)
    return;
end

type = get(hViewOrigin(2),'type');
if strcmp(type, 'uicontrol')
    val = get(hViewOrigin(2), 'value');
    if val==1 onoff = 'on'; else onoff = 'off'; end
elseif strcmp(type, 'uimenu')
    onoff = get(hViewOrigin(2), 'checked');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now ready to display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if strcmp(mode,'redraw')
    if isempty(nz) | isempty(iz) | isempty(rpa) | isempty(lpa) | isempty(cz) | isempty(czo)
        return;
    end
    
    if size(hOrigin,1)>=2 & ishandles(hOrigin(2,:))
        delete(hOrigin(2,:));
    end
    
    % Get axes colors
    o = refpts.orientation; 
    axes_order2 = abs(getCoordTranspose(o));
    c = getappdata(hAxes, 'colors');
    c = [c(:,axes_order2(1)), c(:,axes_order2(2)), c(:,axes_order2(3))];
    c = [c(:,axes_order(1)), c(:,axes_order(2)), c(:,axes_order(3))];

    l1 = points_on_line(rpa, lpa, 1/100, 'all');
    l2 = points_on_line(nz, iz, 1/100, 'all');
    l3 = points_on_line(cz, czo, 1/100, 'all');
    
    hl1 = plot3(l1(:,axes_order(1)), l1(:,axes_order(2)), l1(:,axes_order(3)), 'color',c(1,:));
    hl2 = plot3(l2(:,axes_order(1)), l2(:,axes_order(2)), l2(:,axes_order(3)), 'color',c(2,:));
    hl3 = plot3(l3(:,axes_order(1)), l3(:,axes_order(2)), l3(:,axes_order(3)), 'color',c(3,:));
    
    hxt = text(rpa(1,axes_order(1)),rpa(1,axes_order(2)),rpa(1,axes_order(3)), 'R', 'fontweight','bold', 'color', c(1,:));
    hyt = text(nz(1,axes_order(1)),nz(1,axes_order(2)),nz(1,axes_order(3)), 'A', 'fontweight','bold', 'color', c(2,:));
    hzt = text(cz(1,axes_order(1)),cz(1,axes_order(2)),cz(1,axes_order(3)), 'S', 'fontweight','bold', 'color', c(3,:));
    
    hOrigin(2,:) = [hl1, hl2, hl3, hxt, hyt, hzt];    
end

setappdata(hAxes, 'hOrigin', hOrigin);

if size(hOrigin,1)<2
    return;
end
if ~ishandles(hOrigin(2,:))
    return;
end
if strcmp(onoff, 'on')
    set(hOrigin(2,:), 'visible','on');
elseif strcmp(onoff, 'off')
    set(hOrigin(2,:), 'visible','off');
end

