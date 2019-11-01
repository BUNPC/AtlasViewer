function v = getUpVector(orientation)

v = [];
o = orientation;

if isempty(o)
    return;
end

% Make sure we are dealing with a righ handed coordinate system
if leftRightFlipped(o)
    o = [o(2), o(1), o(3)];
end

if o(1)=='S'
    v = [1,0,0];
elseif o(1)=='I'
    v = [-1,0,0];
end
if o(2)=='S'
    v = [0,1,0];
elseif o(2)=='I'
    v = [0,-1,0];
end
if o(3)=='S'
    v = [0,0,1];
elseif o(3)=='I'
    v = [0,0,-1];
end
