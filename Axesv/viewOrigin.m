function viewOrigin(hAxes, axes_order, origin, mode)

if ~ishandles(hAxes)
    return;
end

hOrigin = getappdata(hAxes, 'hOrigin');

if ~exist('mode','var')
    mode = 'redraw';
end
if ~exist('origin','var') | isempty(origin)
    origin = [0,0,0];
end
axes(hAxes); hold on
hViewOrigin = getappdata(hAxes, 'hViewOrigin');

type = get(hViewOrigin,'type');
if strcmp(type, 'uicontrol')
    val = get(hViewOrigin, 'value');
    if val==1 onoff = 'on'; else onoff = 'off'; end
elseif strcmp(type, 'uimenu')
    onoff = get(hViewOrigin, 'checked');
end

c = origin;
s = 64;
Xa = [c(1)+s, c(2),   c(3);   c(1)-s, c(2),   c(3)];
Ya = [c(1),   c(2)+s, c(3);   c(1),   c(2)-s, c(3)];
Za = [c(1),   c(2),   c(3)+s; c(1),   c(2),   c(3)-s];

if strcmp(mode,'redraw')
    if ishandles(hOrigin)
        delete(hOrigin);
    end
    
    % Set axes colors
    c = [ ...
        .95, .00, .95; ...
        .20, .80, .10; ...
        .10, .80, .80 ...
        ];    
    
    hxcoord = line([Xa(1,axes_order(1)), Xa(2,axes_order(1))], [Xa(1,axes_order(2)), Xa(2,axes_order(2))], [Xa(1,axes_order(3)), Xa(2,axes_order(3))], 'color', c(1,:)); hold on
    hycoord = line([Ya(1,axes_order(1)), Ya(2,axes_order(1))], [Ya(1,axes_order(2)), Ya(2,axes_order(2))], [Ya(1,axes_order(3)), Ya(2,axes_order(3))], 'color', c(2,:)); hold on
    hzcoord = line([Za(1,axes_order(1)), Za(2,axes_order(1))], [Za(1,axes_order(2)), Za(2,axes_order(2))], [Za(1,axes_order(3)), Za(2,axes_order(3))], 'color', c(3,:)); hold on    
    hxt = text(Xa(1,axes_order(1)),Xa(1,axes_order(2)),Xa(1,axes_order(3)), 'x', 'fontweight','bold', 'color', c(1,:)); hold on
    hyt = text(Ya(1,axes_order(1)),Ya(1,axes_order(2)),Ya(1,axes_order(3)), 'y', 'fontweight','bold', 'color', c(2,:)); hold on
    hzt = text(Za(1,axes_order(1)),Za(1,axes_order(2)),Za(1,axes_order(3)), 'z', 'fontweight','bold', 'color', c(3,:)); hold on
    hOrigin = [hxcoord, hycoord, hzcoord, hxt, hyt, hzt];
   
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

end

setappdata(hAxes, 'hOrigin', hOrigin);
if ishandles(hOrigin)
    if strcmp(onoff, 'on')
        set(hOrigin, 'visible','on');
        
        % Set axis limits so that origin is visible
        setAxisLimits(s);
    elseif strcmp(onoff, 'off')
        set(hOrigin, 'visible','off');
    end
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


