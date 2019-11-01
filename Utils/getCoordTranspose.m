function axes_order = getCoordTranspose(orientation, system)

axes_order = [];

o = orientation;

if ~exist('system','var')
    system = 'righthanded';
end

% Make sure we are dealing with a righ handed coordinate system
if strcmp(system, 'righthanded')
    if leftRightFlipped(o)
        o = [o(2), o(1), o(3)];
    end
end

if o(1)=='R';
    axes_order(1) =  1;
elseif o(1)=='L';
    axes_order(1) = -1;
end
if o(1)=='A';
    axes_order(1) =  2;
elseif o(1)=='P';
    axes_order(1) = -2;
end
if o(1)=='S';
    axes_order(1) =  3;
elseif o(1)=='I';
    axes_order(1) = -3;
end

if o(2)=='R';
    axes_order(2) =  1;
elseif o(2)=='L';
    axes_order(2) = -1;
end
if o(2)=='A';
    axes_order(2) =  2;
elseif o(2)=='P';
    axes_order(2) = -2;
end
if o(2)=='S';
    axes_order(2) =  3;
elseif o(2)=='I';
    axes_order(2) = -3;
end


if o(3)=='R';
    axes_order(3) =  1;
elseif o(3)=='L';
    axes_order(3) = -1;
end
if o(3)=='A';
    axes_order(3) =  2;
elseif o(3)=='P';
    axes_order(3) = -2;
end
if o(3)=='S';
    axes_order(3) =  3;
elseif o(3)=='I';
    axes_order(3) = -3;
end


