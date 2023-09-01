function [orientation, o] = getOrientation(varargin)

%
% Usage:
%
%    [orientation, o] = getOrientation(nz, iz, rpa, lpa, cz)
%
% Description:
%    
%    Function determines the orientation of head reference points using  
%    a Freesurfer style 3 letter code. This code indicates how the 6 head 
%    axes Left-Right, Anterior-Posterior, and Superior-Inferior correspond to 
%    the 6 XYZ coordinates, (x+, x-, y+, y-, z+, z-)in a right handed 
%    coordinate system. 
%
%    The significance of this code is that any head orientation with 'L' 
%    in it (e.g., LAS or PLS) will appear left-right flipped (i.e. mirror 
%    image) when viewed in a right handed system. Conversly any code with 
%    'R' in it will appear correctly. That is, not-flipped with respect to 
%    left-right. Note: Matlab by default is a right-handed coordinate system. 
%
%
% Arguments:
%   
%    nz:  Nazion coordinates 
%
%    iz:  Inion coordinates 
%
%    rpa: Right Preauricular coordinates 
%
%    lpa: Left Preauricular coordinates 
%
%    cz:  Central coordinates 
%    
% Ouput:
%    
%    orientation: 3-letter code indicating how the axes of the head 
%                 correspond to the  axes of the xyz right-handed 
%                 coord system. There are 6x4x2 = 48 code possibilitities. 
%                 Here are 2 of them:
%
%                  'RIP' --> 
%                    Right     aligns with  x+ (thus Left      aligns with x-)
%                    Inferior  aligns with  y+ (thus Superior  aligns with y-)
%                    Posterior aligns with  z+ (thus Anterior  aligns with z-)
%                    
%                  'LAS' --> 
%                    Left      aligns with  x+ (thus Right    aligns with  x-) 
%                    Anterior  aligns with  y+ (thus Anterior aligns with  y-)
%                    Superior  aligns with  z+ (thus Anerior  aligns with  z-)
%                  
%
%    o:           Center of the reference points nz,iz,rpa,lpa,cz, 
%                 used to align with the (0,0,0) origin of the 
%                 xyz right-handed coord system.
%
%  Written by Jay Dubb (jdubb@nmr.mgh.harvard.edu) 
%  Date written: Nov 28, 2015
%

DEBUG1 = 0;
DEBUG2 = 0;

orientation = '';
o = [];

if nargin>4
    nz  = varargin{1};
    iz  = varargin{2};
    rpa = varargin{3};
    lpa = varargin{4};
    cz  = varargin{5};
    czo = [];
    if nargin==6
        czo = varargin{6};
    end
elseif nargin==1
    p = varargin{1};
    if all(size(p)==[5,3])
        nz  = p(1,:);
        iz  = p(2,:);
        rpa = p(3,:);
        lpa = p(4,:);
        cz  = p(5,:);
        czo = [];
        if size(p,1)==6
            czo = p(6,:);
        end
    elseif all(size(p)==[4,4])
        T_2ras = varargin{1};
        orientation = orientationFromMatrix(T_2ras);
        return;
    elseif isstruct(varargin{1})
        T_2ras = varargin{1};
        orientation = orientationFromMatrix(T_2ras);
        return;        
    else
        return;
    end
end
      
if isempty(nz) || isempty(iz) || isempty(rpa) || isempty(lpa) || isempty(cz)
    return;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Determine origin of the head: Get line between LPA and RPA
% and line between Nz and Iz.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[nz, iz, rpa, lpa, cz, czo, o] = findRefptsAxes([nz; iz; rpa; lpa; cz; czo]);

if DEBUG1
    showLandmarks(nz, iz, rpa, lpa, cz, czo);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Transform to origin of xyz right-handed coordinate system
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% First translate to origin 
T = [1 0 0 -o(1); 0 1 0 -o(2); 0 0 1 -o(3); 0 0 0 1];
p_new = xform_apply([nz; iz; rpa; lpa; cz; czo], T);
nz_new  = p_new(1,:);
rpa_new = p_new(3,:);
cz_new  = p_new(5,:);

% Rotate to align with x,y,z coordinates. 
p(1,:) = findClosestAxes(rpa_new);
p(2,:) = findClosestAxes(nz_new);
p(3,:) = findClosestAxes(cz_new);
q = [rpa_new; nz_new; cz_new];
T = gen_xform_from_pts(q,p(1:size(q,1),:));
if isempty(T)
    return;
end
p_new = xform_apply(p_new, T);

nz_new  = p_new(1,:);
iz_new  = p_new(2,:);
rpa_new = p_new(3,:);
lpa_new = p_new(4,:);
cz_new  = p_new(5,:);
czo_new = p_new(6,:);

if DEBUG2
    showLandmarks(nz_new, iz_new, rpa_new, lpa_new, cz_new, czo_new);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Now assign head axes to xyz positive axes
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Determine head orientation in relation to a right-handed xyz coordinate
% system. First determine which head side corresponds to which axis
[~,icoord_AP] = max(abs(nz_new - iz_new));
[~,icoord_RL] = max(abs(rpa_new - lpa_new));
[~,icoord_SI] = max(abs(cz_new - czo_new));

% Error checks
if icoord_AP==icoord_RL
   return; 
end
if icoord_AP==icoord_SI
   return; 
end
if icoord_RL==icoord_SI
   return;
end

% Assign Anterior or Posterior to +X, +Y, or +Z 
if nz_new(icoord_AP) >= 0
    orientation(icoord_AP) = 'A';
else
    orientation(icoord_AP) = 'P';
end

% Assign Left or Right to +X, +Y, or +Z 
if rpa_new(icoord_RL) >= 0
    orientation(icoord_RL) = 'R';
else
    orientation(icoord_RL) = 'L';
end

% Assign Superior or Inferior to +X, +Y, or +Z 
if cz_new(icoord_SI) >= 0
    orientation(icoord_SI) = 'S';
else
    orientation(icoord_SI) = 'I';
end




% ----------------------------------------------------------------------
function ostr = orientationFromMatrix(M)
    
% ------------------------------------------------------------------
%   This code is originally from a Freesurfer C function called 
%   MRIdircosToOrientationString().
%
%   It examines the direction cosines and creates an Orientation String. 
%   The Orientation String is a three
%   character string indicating the primary direction of each axis
%   in the 3d matrix. The characters can be L,R,A,P,I,S. Case is not
%   important, but upper case is used here. If ras_good_flag == 0,
%   then ostr = ??? and 1 is returned.
% ------------------------------------------------------------------

ostr = '';

for c=1:3
    sag = M(1,c);  % LR axis
    cor = M(2,c);  % PA axis
    ax  = M(3,c);  % IS axis
    
    if abs(sag) > abs(cor) && abs(sag) > abs(ax)
        if (sag > 0)
            ostr(c) = 'R';
        else
            ostr(c) = 'L';
        end
        continue;
    end
    if abs(cor) > abs(ax)
        if (cor > 0)
            ostr(c) = 'A';
        else
            ostr(c) = 'P';
        end
        continue;
    end
    if (ax > 0)
        ostr(c) = 'S';
    else
        ostr(c) = 'I';
    end
end
    
