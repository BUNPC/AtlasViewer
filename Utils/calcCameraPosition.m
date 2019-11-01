function cp_new = calcCameraPosition(cp, ct, az, el, o)

cp_new = cp;

if isempty(o)
    return;
end

% Translate view axis so that ct is at (0,0,0)
v = cp - ct;
x = v(1);
y = v(2);
z = v(3);
len_view_axis = sqrt(x^2 + y^2 + z^2);

% Make sure we are dealing with a righ handed coordinate system
if leftRightFlipped(o)
    o = [o(2), o(1), o(3)];  
end

% az rotation is around SI axis. If I is positive then the direction of the
% angle changes sign
if ismember('I',o)
    az = -az;
end

Rx = rotateMatrixXaxis(az);
Ry = rotateMatrixYaxis(az);
Rz = rotateMatrixZaxis(az);

azr = deg2rad(az);
elr = deg2rad(el);

%%%% Set azimuth

% Vector U relative to which azimuth is measured
if o(1)=='P'
   U = [ 1, 0, 0 ];
elseif o(1)=='A'
   U = [-1, 0, 0 ];
elseif o(2)=='P'
   U = [ 0, 1, 0 ];
elseif o(2)=='A'
   U = [ 0,-1, 0 ];
elseif o(3)=='P'
   U = [ 0, 0, 1 ];
elseif o(3)=='A'
   U = [ 0, 0,-1 ];
end

if o(1)=='S'
    R = Rx;
elseif o(1)=='I'
    R = Rx;
elseif o(2)=='S'
    R = Ry;
elseif o(2)=='I'
    R = Ry;
elseif o(3)=='S'
    R = Rz;
elseif o(3)=='I'
    R = Rz;
end

% Rotate U around S axis by az amount.
U1 = xform_apply(U, R);

%%%% Vector Vaxis_new 
if o(1)=='S'
    if el==90
        Vaxis_new = [  1,  0,  0  ];
    elseif el==-90
        Vaxis_new = [ -1,  0,  0  ];
    else
        S_len = tan(elr) * sqrt(U1(2)^2 + U1(3)^2);
        Vaxis_new = [S_len, U1(2), U1(3)];
    end
elseif o(1)=='I'
    if el==90
        Vaxis_new = [ -1,  0,  0  ];
    elseif el==-90
        Vaxis_new = [  1,  0,  0  ];
    else
        S_len = tan(elr) * sqrt(U1(2)^2 + U1(3)^2);
        Vaxis_new = [-S_len, U1(2), U1(3)];
    end    
elseif o(2)=='S'
    if el==90
        Vaxis_new = [  0,  1,  0  ];
    elseif el==-90
        Vaxis_new = [  0, -1,  0  ];
    else
        S_len = tan(elr) * sqrt(U1(1)^2 + U1(3)^2);
        Vaxis_new = [U1(1), S_len, U1(3)];
    end    
elseif o(2)=='I'
    if el==90
        Vaxis_new = [  0, -1,  0  ];
    elseif el==-90
        Vaxis_new = [  0,  1,  0  ];
    else
        S_len = tan(elr) * sqrt(U1(1)^2 + U1(3)^2);
        Vaxis_new = [U1(1), -S_len, U1(3)];
    end    
elseif o(3)=='S'
    if el==90
        Vaxis_new = [  0,  0,  1  ];
    elseif el==-90
        Vaxis_new = [  0,  0, -1  ];
    else
        S_len = tan(elr) * sqrt(U1(1)^2 + U1(2)^2);
        Vaxis_new = [U1(1), U1(2), S_len];
    end    
elseif o(3)=='I'
    if el==90
        Vaxis_new = [  0,  0, -1  ];
    elseif el==-90
        Vaxis_new = [  0,  0,  1  ];
    else
        S_len = tan(elr) * sqrt(U1(1)^2 + U1(2)^2);
        Vaxis_new = [U1(1), U1(2), -S_len];
    end    
end

% Set new camera position which should be a vector of the same length 
% as the previous camera position
len = sqrt(Vaxis_new(1)^2 + Vaxis_new(2)^2 + Vaxis_new(3)^2);
c = len_view_axis / len;
Vaxis_new = Vaxis_new * c;
cp_new = ct + Vaxis_new;

