% USAGE:
%
%    [hPtsTxt hPts] = viewPts(pts, ctr, lift, axes_order)
% 
% DESCRIPTION:
%   
% 
% INPUT:
%
%    pts        - Either an array of structures containing N-size set of 
%                 points which to visualize on the surface. The structure is
%           
%                 pts(i).pos;
%                 pts(i).col;
%                 pts(i).size;
%                 pts(i).str;
%           
%                 or just a Nx3 array of N vertices. 
% 
%    ctr        - center point away from which to push points away
%
%    lift       - How much to lift points away from surface for easier viewing
%
%    axes_order - transformation for correctly displaying subject anatomy.
%
% OUTPUT:
%
%    hPts  -  handles of point visualized on surf 
%
%
function [hPtsTxt, hPts] = viewPts(pts, ctr, lift, axes_order)
global hAxesBbox

hold on

% Init output param
hPts=[];
hPtsTxt=[];


% Check arg 1
if isempty(pts)
    return;
end

% Check arg 2
if isempty(ctr)
    dx = 0; dy = 0; dz = 0;
end

% Check arg 3
if ~exist('lift','var')
   lift=0; 
end

% Check arg 4
if ~exist('axes_order','var')
    axes_order=[1 2 3];
end


% Display points
if isfield(pts,'pos')
    
    hPts = zeros(length(pts),2);
    hPtsTxt = zeros(length(pts),2);
    for i=1:length(pts);
        ptPos0 = [pts(i).pos(axes_order(1)) pts(i).pos(axes_order(2)) pts(i).pos(axes_order(3))];
        ptCol = pts(i).col;
        textSz  = pts(i).textsize;
        circleSz  = pts(i).circlesize;
        ptStr = pts(i).str;
        
        if ~isempty(ctr)
            dr = dist3(ptPos0, ctr);
            ptPos = points_on_line(ptPos0, ctr, -lift/100);
        else
            ptPos = ptPos0;
        end
        
        hPts(i,1) = plot3(ptPos(1), ptPos(2), ptPos(3), '.',...
                          'markersize',circleSz, 'color',ptCol,...
                          'visible','off');
        hPts(i,2) = plot3(ptPos0(1), ptPos0(2), ptPos0(3), '.',...
                          'markersize',circleSz, 'color',ptCol,...
                          'visible','off');
        if ~isempty(ptStr)           
            hPtsTxt(i,1) = text(ptPos(1), ptPos(2), ptPos(3), ptStr,...
                             'fontsize',textSz, 'color',ptCol, 'fontWeight','bold',...
                             'verticalalignment','middle','horizontalalignment','center',...
                             'visible','on');
            hPtsTxt(i,2) = text(ptPos0(1), ptPos0(2), ptPos0(3), ptStr,...
                             'fontsize',textSz, 'color',ptCol, 'fontWeight','bold',...
                             'verticalalignment','middle','horizontalalignment','center',...
                             'visible','off');
        end
    end
    
else
    
    pts0 = [pts(:,axes_order(1)) pts(:,axes_order(2)) pts(:,axes_order(3))];
    for i=1:size(pts,1);       
        if ~isempty(ctr)
            dr = dist3(pts0(i,:), ctr);
            pts(i,:) = points_on_line(pts0(i,:),ctr,-lift/100);
        else
            pts(i,:) = pts0(i,:);
        end
        hPts(i,1) = plot3(pts(i,1), pts(i,2), pts(i,3), '.',...
                          'markersize',12, 'color','r',...
                          'visible','on');
        hPts(i,2) = plot3(pts0(i,1), pts0(i,2), pts0(i,3), '.',...
                          'markersize',12, 'color','r',...
                          'visible','off');
    end
    
end


% We draw axes bounding corner points because the text() function has 
% the interesting property of not updating axes limits even when limit 
% modes are set to auto. plot3 doesn't have this problem, so we use it 
% to update axes limits when only text objects are displayed on axes.
if ~isempty(hPts)
    
    p1 = cell2array(get(hPts(:,1), {'xdata','ydata','zdata'}));
    p2 = cell2array(get(hPts(:,2), {'xdata','ydata','zdata'}));
    p = [p1; p2];
    
    flag = 0;
    bbox = gen_bbox(p,10);
    
    xlim0 = get(gca,'xlim');
    ylim0 = get(gca,'ylim');
    zlim0 = get(gca,'zlim');
    xlim_new = xlim0;
    ylim_new = ylim0;
    zlim_new = zlim0;

    if max(bbox(:,1)) > xlim0(2)
        xlim_new(2) = max(bbox(:,1)); flag=1;
    end
    if min(bbox(:,1)) < xlim0(1)
        xlim_new(1) = min(bbox(:,1)); flag=1;
    end
    if max(bbox(:,2)) > ylim0(2)
        ylim_new(2) = max(bbox(:,2)); flag=1;
    end
    if min(bbox(:,2)) < ylim0(1)
        ylim_new(1) = min(bbox(:,2)); flag=1;
    end
    if max(bbox(:,3)) > zlim0(2)
        zlim_new(2) = max(bbox(:,3)); flag=1;
    end
    if min(bbox(:,3)) < zlim0(1)
        zlim_new(1) = min(bbox(:,3)); flag=1;
    end
    
    if flag==1
        if ishandles(hAxesBbox)
            delete(hAxesBbox);
        end
        
        c = get(get(gca,'parent'),'color');
        hAxesBbox = plot3(xlim_new, ylim_new, zlim_new,'.w','color',c,'marker','none');                
    end        
        
end

hold off
