function [T, nz_new, iz_new, rpa_new, lpa_new, cz_new] = alignRefptsWithXyz(varargin)

DEBUG1 = 0;
DEBUG2 = 0;

T = eye(4);
o = [];

if nargin>1
    nz  = varargin{1};
    iz  = varargin{2};
    rpa = varargin{3};
    lpa = varargin{4};
    cz  = varargin{5};
elseif nargin==1
    p = varargin{1};
    if all(size(p)==[5,3])
        nz  = p(1,:);
        iz  = p(2,:);
        rpa = p(3,:);
        lpa = p(4,:);
        cz  = p(5,:);
    else
        return;
    end
end
      
if isempty(nz) | isempty(iz) | isempty(rpa) | isempty(lpa) | isempty(cz)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine origin of the head: Get line between LPA and RPA
% and line between Nz and Iz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
m1 = [(rpa(1)+lpa(1))/2, (rpa(2)+lpa(2))/2, (rpa(3)+lpa(3))/2];
m2 = [(nz(1)+iz(1))/2,   (nz(2)+iz(2))/2,   (nz(3)+iz(3))/2];
o = mean([m1; m2]);
czo = AVUtils.points_on_line(o, cz, -1, 'relative');
m3 = [(cz(1)+czo(1))/2,  (cz(2)+czo(2))/2,  (cz(3)+czo(3))/2];

% Translate head axes to common head origin
%{
T1 = [1 0 0 o(1)-m1(1); 0 1 0 o(2)-m1(2); 0 0 1 o(3)-m1(3); 0 0 0 1];
T2 = [1 0 0 o(1)-m2(1); 0 1 0 o(2)-m2(2); 0 0 1 o(3)-m2(3); 0 0 0 1];
T3 = [1 0 0 o(1)-m3(1); 0 1 0 o(2)-m3(2); 0 0 1 o(3)-m3(3); 0 0 0 1];
rpa = xform_apply(rpa, T1);
lpa = xform_apply(lpa, T1);
nz  = xform_apply(nz , T2);
iz  = xform_apply(iz , T2);
cz  = xform_apply(cz , T3);
czo = xform_apply(czo, T3);
%}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform to origin of xyz right-handed coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First translate to origin 
T1 = [1 0 0 -o(1); 0 1 0 -o(2); 0 0 1 -o(3); 0 0 0 1];
p_new = xform_apply([nz; iz; rpa; lpa; cz; czo], T1);
nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);

% Rotate to align with x,y,z coordinates. 
p(1,:) = findClosestAxes(rpa_new);
p(2,:) = -p(1,:);
p(3,:) = findClosestAxes(nz_new);
p(4,:) = -p(3,:);
p(5,:) = findClosestAxes(cz_new);
p(6,:) = -p(5,:);
q = [rpa_new; lpa_new; nz_new; iz_new; cz_new; czo_new];
T2 = gen_xform_from_pts(q, p);
if isempty(T2)
    return;
end
p_new = xform_apply(p_new, T2);

nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);


% Translate back to initial origin 
T3 = [1 0 0 o(1); 0 1 0 o(2); 0 0 1 o(3); 0 0 0 1];
p_new = xform_apply([nz_new; iz_new; rpa_new; lpa_new; cz_new; czo_new], T3);
nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);

if DEBUG2
    showLandmarks(nz_new, iz_new, rpa_new, lpa_new, cz_new, czo_new);
end

% Calculate final Transform between original positions and new positions
T = [T3*T2*T1];



