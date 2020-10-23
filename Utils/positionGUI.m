function positionGUI(hFig, xpos, ypos, xsize, ysize)

% Position and size GUI with handle hFig, relative to screen 

if ~exist('xsize','var')
    xsize = .85;
end
if ~exist('ysize','var')
    ysize = .75;
end

uf0 = get(hFig, 'units');
us0 = get(0, 'units');

set(hFig, 'units',us0);

q  = get(hFig, 'position');

% Set screen units to be same as GUI
p = get(0,'MonitorPositions');

% To work correctly for mutiple sceens, p must be sorted in ascending order
p = sort(p,'ascend');

% Find which monitor GUI is in
for ii = 1:size(p,1)
    if (q(1)+q(3)/2) < (p(ii,1)+p(ii,3))
        break;
    end
end

%set(hFig, 'units','pixels', 'position',[q(1)-q(3)/xsize*p(ii,3), q(2)-q(3)/ysize*p(ii,4), xsize*p(ii,3), ysize*p(ii,4)]);
d = p(ii,3) - (q(1)+xsize*p(ii,3));
if d<0
    xoffset = d+.1*d;
else
    xoffset = 0;
end
set(hFig, 'position',[q(1)+xoffset, q(2), xsize*p(ii,3), ysize*p(ii,4)]);

set(hFig, 'units',uf0);

