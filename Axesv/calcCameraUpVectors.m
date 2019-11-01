function [v_up_sup, v_up_ant] = calcCameraUpVectors(o)

v_up_sup = []; 
v_up_ant = [];

if length(o)<3
    return;
end

o = upper(o);

% Find camera up vector coinciding with Superior axis 
if o(1)=='S'
    v_up_sup = [1, 0, 0];
elseif o(1)=='I'
    v_up_sup = [-1, 0, 0];
elseif o(2)=='S'
    v_up_sup = [0, 1, 0];
elseif o(2)=='I'
    v_up_sup = [0,-1, 0];
elseif o(3)=='S'
    v_up_sup = [0, 0, 1];
elseif o(3)=='I'
    v_up_sup = [0, 0,-1];
end

% Find camera up vector coinciding with Superior axis 
if o(1)=='A'
    v_up_ant = [1, 0, 0];
elseif o(1)=='P'
    v_up_ant = [-1, 0, 0];
elseif o(2)=='A'
    v_up_ant = [0, 1, 0];
elseif o(2)=='P'
    v_up_ant = [0,-1, 0];
elseif o(3)=='A'
    v_up_ant = [0, 0, 1];
elseif o(3)=='P'
    v_up_ant = [0, 0,-1];
end

if leftRightFlipped(o)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

v_up_sup = [v_up_sup(axes_order(1)), v_up_sup(axes_order(2)), v_up_sup(axes_order(3))];
v_up_ant = [v_up_ant(axes_order(1)), v_up_ant(axes_order(2)), v_up_ant(axes_order(3))];

