function p3 = points_on_line(p1, p2, crop, mode)

%
% USAGE:
%   
%    p3 = points_on_line(p1,p2,crop,mode)
%
% DESCRIPTION:
%   
%    Function takes 2 points in 3d, p1 and p2, and a crop length
%    and finds a point on the line formed by extending p1,p2 by the 
%    amount (or fraction of p1-p2 distance) crop extends away from p1. 
%    
%    Positive crop crops p1,p2 by the crop amount.
%    Negative crop extends p1,p2 by the crop amount.
%     
%    mode = 'relative' means crop is the distance p3 extends away from p1 relative 
%    to the distance between p1 and p2. This is the default if no mode is provided. 
%
%    mode = 'absolute' means crop is the absolute distance (in unit length) that 
%    p3 extends away from p1.
%
%    mode = 'all' returns the set of all points at intervals 1/crop on the line 
%    segment between p1 and p2. 
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   7/7/2012
%

if ~exist('mode','var')
    mode = 'relative';
end

p3 = p1;

if isempty(p1) || isempty(p2)
    return;
end
if all(p1==p2)
    return;
end

if ~exist('crop','var') || isempty(crop)
    crop = set_line_crop(p2, p1);
end

dx0 = p1(1)-p2(1);
dy0 = p1(2)-p2(2);
dz0 = p1(3)-p2(3);
dr = (dx0*dx0 + dy0*dy0 + dz0*dz0)^0.5;
if strcmp(mode, 'relative')
    crop = crop*dr;
    dx = crop*dx0/dr;
    dy = crop*dy0/dr;
    dz = crop*dz0/dr;
elseif strcmp(mode, 'absolute')
    crop = crop/dr;
    dx = crop*dx0;
    dy = crop*dy0;
    dz = crop*dz0;
elseif strcmp(mode, 'all')
    if crop > 1
        return;
    end    
    ii=1;
	step = crop;
    while (step*ii)<1
        crop = (step*ii)*dr;
        dx(ii) = crop*dx0/dr;
        dy(ii) = crop*dy0/dr;
        dz(ii) = crop*dz0/dr;
        ii=ii+1;
    end
end

for ii=1:length(dx)
    p3(ii,1) = p1(1)-dx(ii);
    p3(ii,2) = p1(2)-dy(ii);
    p3(ii,3) = p1(3)-dz(ii);
end


% ------------------------------------------------------------------------
function gapRelative = set_line_crop(p1, p2)
gapRelative = 0;

if isempty(p1) || isempty(p2) 
    return;
end

% Set desired absolute gap distance
gapAbsolute  = 1;
lineSize     = dist3(p1, p2);

% Get relative gap distance
gapRelative = gapAbsolute / lineSize;
% fprintf('Line gap: relative = %0.2f, absolute: %0.2f\n', gapRelative, gapAbsolute);

