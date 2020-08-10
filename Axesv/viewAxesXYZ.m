function viewAxesXYZ(hAxes, axes_order, origin, mode)

if ~ishandles(hAxes)
    hAxes = gca;
    setappdata(hAxes, 'hOrigin',[]);
    setappdata(hAxes, 'hViewOrigin',[]);
end
if ~exist('origin','var') | isempty(origin)
    origin = [0,0,0];
end
if ~exist('mode','var')
    mode = 'redraw';
end

axes(hAxes); hold on
hOrigin = getappdata(hAxes, 'hOrigin');
hViewOrigin = getappdata(hAxes, 'hViewOrigin');
if ~ishandles(hViewOrigin)
    return;
end

type = get(hViewOrigin(1),'type');
if strcmp(type, 'uicontrol')
    val = get(hViewOrigin(1), 'value');
    if val==1 onoff = 'on'; else onoff = 'off'; end
elseif strcmp(type, 'uimenu')
    onoff = get(hViewOrigin(1), 'checked');
end

o = origin;
s = 64;
Xa = [o(1)+s, o(2),   o(3);   o(1)-s, o(2),   o(3)];
Ya = [o(1),   o(2)+s, o(3);   o(1),   o(2)-s, o(3)];
Za = [o(1),   o(2),   o(3)+s; o(1),   o(2),   o(3)-s];

if strcmp(mode,'redraw')
    if size(hOrigin,1)>=1 & ishandles(hOrigin(1,:))
        delete(hOrigin(1,:));
    end
    
    % Get axes colors
    c = getappdata(hAxes, 'colors') ;
    
    hxcoord = line([Xa(1,axes_order(1)), Xa(2,axes_order(1))], [Xa(1,axes_order(2)), Xa(2,axes_order(2))], [Xa(1,axes_order(3)), Xa(2,axes_order(3))], 'color', c(1,:));
    hycoord = line([Ya(1,axes_order(1)), Ya(2,axes_order(1))], [Ya(1,axes_order(2)), Ya(2,axes_order(2))], [Ya(1,axes_order(3)), Ya(2,axes_order(3))], 'color', c(2,:));
    hzcoord = line([Za(1,axes_order(1)), Za(2,axes_order(1))], [Za(1,axes_order(2)), Za(2,axes_order(2))], [Za(1,axes_order(3)), Za(2,axes_order(3))], 'color', c(3,:));
    
    hxt = text(Xa(1,axes_order(1)),Xa(1,axes_order(2)),Xa(1,axes_order(3)), 'x', 'fontweight','bold', 'color', c(1,:));
    hyt = text(Ya(1,axes_order(1)),Ya(1,axes_order(2)),Ya(1,axes_order(3)), 'y', 'fontweight','bold', 'color', c(2,:));
    hzt = text(Za(1,axes_order(1)),Za(1,axes_order(2)),Za(1,axes_order(3)), 'z', 'fontweight','bold', 'color', c(3,:));
    
    hOrigin(1,:) = [hxcoord, hycoord, hzcoord, hxt, hyt, hzt];
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

setappdata(hAxes, 'hOrigin', hOrigin);
if size(hOrigin,1)<1
    return;
end
if ~ishandles(hOrigin(1,:))
    return;
end
if strcmp(onoff, 'on')
    set(hOrigin(1,:), 'visible','on');
    
    % Set axis limits so that origin is visible
    setAxisLimits(s);
elseif strcmp(onoff, 'off')
    set(hOrigin(1,:), 'visible','off');
end






% ------------------------------------------------------------------------
function setAxisLimits(s)

alim = get(gca, {'xlim','ylim','zlim'});
xlim = alim{1};
ylim = alim{2};
zlim = alim{3};

if xlim(1) > -s
    xlim(1) = -s-20;
end
if xlim(2) < s
    xlim(2) = s+20;
end
if ylim(1) > -s
    ylim(1) = -s-20;
end
if ylim(2) < s
    ylim(2) = s+20;
end
if zlim(1) > -s
    zlim(1) = -s-20;
end
if zlim(2) < s
    zlim(2) = s+20;
end

set(gca,'xlim',xlim);
set(gca,'ylim',ylim);
set(gca,'zlim',zlim);


