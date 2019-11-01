function [az_new, el_new] = getViewAngles(hAxes, o)

az_new=0; 
el_new=0;

if isempty(o)
    return;
end

cp0 = get(hAxes, 'CameraPosition');
ct0 = get(hAxes, 'CameraTarget');

% Translate ct to (0,0,0)
v = cp0 - ct0;
x = v(1);
y = v(2);
z = v(3);
Vaxis = [x,y,z];

% Make sure we are dealing with a righ handed coordinate system
if leftRightFlipped(o)
    o = [o(2), o(1), o(3)];
end

%%%%%%%%%% Variables U, Vp, SI, RL
% U : the projection of view axis to the RL-AP plane.
% Vp: a vector along the P axis with length equal to view axis. 
% SI: the value of this var is the magnitude of the XYZ axis corresponding to
%     the SI axis
% RL: the value of this var is the magnitude of the XYZ axis corresponding to
%     the RL axis.
% 


% Dealing only with right-handed systems means we only have to consider 24
% orientations instead of 48 total possibilities
switch(upper(o))
    
    case 'RAS'
        
        % elevation angle: RL-AP plane corresponds to XY plane        
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(x^2 + y^2), 0];
        Vp_norm = [0, -1, 0];
        RL = x;

    case 'RPI'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(x^2 + y^2), 0];
        Vp_norm = [0, 1, 0];
        RL = x;
        
    case 'RSP'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z. 
        Vp = [0, 0, sqrt(x^2 + z^2)];
        Vp_norm = [0, 0, 1];
        RL = x;

    case 'RIA'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(x^2 + z^2)];
        Vp_norm = [0, 0,-1];
        RL = x;


    case 'LAI'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y.
        Vp = [0, -sqrt(x^2 + y^2), 0];
        Vp_norm = [0, -1, 0];
        RL = -x;

    case 'LPS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(x^2 + y^2), 0];
        Vp_norm = [0, 1, 0];
        RL = -x;

    case 'LSA'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(x^2 + z^2)];
        Vp_norm = [0, 0, -1];
        RL = -x;

    case 'LIP'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, Z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z.
        Vp = [0, 0, sqrt(x^2 + Z^2)];
        Vp_norm = [0, 0, 1];
        RL = -x;

    case 'ARI'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X.
        Vp = [-sqrt(x^2 + y^2), 0, 0];
        Vp_norm = [-1, 0, 0];
        RL = y;

    case 'ALS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X. 
        Vp = [-sqrt(x^2 + y^2), 0, 0];
        Vp_norm = [-1, 0, 0];
        RL = -y;

    case 'ASR'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X.
        Vp = [-sqrt(x^2 + z^2), 0, 0];
        Vp_norm = [-1, 0, 0];
        RL = z;

    case 'AIL'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is -X. 
        Vp = [-sqrt(x^2 + z^2), 0, 0];
        Vp_norm = [-1, 0, 0];
        RL = -z;

    case 'PRS'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X. 
        Vp = [sqrt(x^2 + y^2), 0, 0];
        Vp_norm = [1, 0, 0];
        RL = y;

    case 'PLI'
        
        % elevation angle: RL-AP plane corresponds to XY plane
        U  = [x, y, 0];
        SI = -z;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X. 
        Vp = [sqrt(x^2 + y^2), 0, 0];
        Vp_norm = [1, 0, 0];
        RL = -y;

    case 'PSL'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X.
        Vp = [sqrt(x^2 + z^2), 0, 0];
        Vp_norm = [1, 0, 0];
        RL = -z;

    case 'PIR'
        
        % elevation angle: RL-AP plane corresponds to XZ plane
        U  = [x, 0, z];
        SI = -y;
        
        % azimuth angle: axis in the xyz system corresponding to P is +X.
        Vp = [sqrt(x^2 + z^2), 0, 0];
        Vp_norm = [1, 0, 0];
        RL = z;


    case 'SRA'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Z.
        Vp = [0, 0, -sqrt(y^2 + z^2)];
        Vp_norm = [0, 0, -1];
        RL = y;

    case 'SLP'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z.
        Vp = [0, 0, sqrt(y^2 + z^2)];
        Vp_norm = [0, 0, 1];
        RL = -y;

    case 'SAL'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(y^2 + z^2), 0];
        Vp_norm = [0,-1, 0];
        RL = -z;

    case 'SPR'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Y. 
        Vp = [0, sqrt(y^2 + z^2), 0];
        Vp_norm = [0, 1, 0];
        RL = z;

        
    case 'IRP'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
        
        % azimuth angle: axis in the xyz system corresponding to P is +Z. 
        Vp = [0, 0, sqrt(y^2 + z^2)];
        Vp_norm = [0, 0, 1];
        RL = y;

    case 'ILA'

        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth angle: axis in the xyz system corresponding to P is -Z. 
        Vp = [0, 0, -sqrt(y^2 + z^2)];
        Vp_norm = [0, 0, -1];
        RL = -y;
                
    case 'IAR'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth angle: axis in the xyz system corresponding to P is -Y. 
        Vp = [0, -sqrt(y^2 + z^2), 0];
        Vp_norm = [0,-1, 0];
        RL = z;
                
    case 'IPL'
        
        % elevation angle: RL-AP plane corresponds to YZ plane
        U  = [0, y, z];
        SI = -x;
    
        % azimuth angle: axis in the xyz system corresponding to P is +Y.
        Vp = [0, sqrt(y^2 + z^2), 0];
        Vp_norm = [0, 1, 0];
        RL = -z;

end

if all(U==0) | all(Vp==0)
    U = Vp_norm;
    Vp = Vp_norm;
end
 
if SI > 0
    el_new =  angleBetweenVectors(U, Vaxis);
else
    el_new = -angleBetweenVectors(U, Vaxis);
end
if RL > 0
    az_new = angleBetweenVectors(Vp, U);
else
    az_new = -angleBetweenVectors(Vp, U);
end


if abs(az_new) < 1e-3
    az_new=0;
end
if abs(el_new) < 1e-3
    el_new=0;
end

