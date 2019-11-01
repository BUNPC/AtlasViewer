function T_2ras = getRasXformFromOrientation(o)

% Construct a matrix, T_2ras, relating the 3-letter orientation 
% input code to RAS 

T_2ras = eye(4);

if isempty(o)
    return;
end

o = upper(o);

for i=1:3
    if o(i)     == 'R'
        T_2ras(i,1:3) = [ 1, 0, 0];
    elseif o(i) == 'L'
        T_2ras(i,1:3) = [-1, 0, 0];
    elseif o(i) == 'A'
        T_2ras(i,1:3) = [ 0, 1, 0];
    elseif o(i) == 'P'
        T_2ras(i,1:3) = [ 0,-1, 0];
    elseif o(i) == 'S'
        T_2ras(i,1:3) = [ 0, 0, 1];
    elseif o(i) == 'I'
        T_2ras(i,1:3) = [ 0, 0,-1];
    end
end

T_2ras = inv(T_2ras);

