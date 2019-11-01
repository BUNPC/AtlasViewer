function PP_List = ProjectionBI ( Pp, Mat )

% PROJECTIONBI - Baloon-inflation projection.
%
% USEAGE.
%   PP_List = ProjectionBI ( PP, Mat )
%
% DESCRIPTION.
%   Funtion searches for a group of points on the cortical surface that are
%   closest to head surface point to be projected and locate the centroid
%   for closest points. It than draws a line through the given point and
%   the centroid. The intersection between the line and the cortical
%   surface is defined as cortical projection point. Name of algorithm is 
%   Baloon-inflation projection. More info in the article: Automated 
%   corticalprojection of head-surface locations for transcranial 
%   functional brain mapping. NeuroImage 26 18-28 2005.
%
% INPUTS.
%   Pp is a point or matrix of points [n,3] on the head surface
%   or its outside space   e.g. [54 104 70]; 
%
%   Mat is [n,3] matrix of 3D Cartesian coordinates which create brain
%   surface. Created by IMAGEREAD3D function.
%   
% OUTPUT.
%   PP_List list of projected coordinates on the cortical surface.
%
% See also DISTBTW, IMAGEREAD3D, MAKEPLOT3D, PLOT4.
 
%   Brain Research Group
%   Food Physics Laboratory, Division of Food Function, 
%   National Food Research Institute,  Tsukuba,  Japan
%   WEB: http://brain.job.affrc.go.jp,  EMAIL: dan@nfri.affrc.go.jp
%   AUTHOR: Ippeita Dan & Valer Jurcak,  DATE: 12.jan.2006,   VERSION: 1.1
%-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-


% CHECKING INPUTS & OUTPUTS
% ..............................................................  ^..^ )~
    if nargin ~= 2
        error('Wrong number of input arguments.');
    end
    
    if nargout > 1
        error('Too many output arguments.');
    end
    
    
% PROJECT ONE POIINT AFTER THE OTHER
% ..............................................................  ^..^ )~
for count = 1 : size(Pp,1)
    P = Pp(count,:); 

    % Coordinate list for 1000 closest points
    MATTop = DistBtw ( P, Mat, 1000 );
    % plot4(MATTop, 'y.', 1)


    % Compute the closest point PNear on the convex hull surface from P
    % as average of 200 closest points
    MATClose = DistBtw ( P, Mat, 200 );
    PNear = mean(MATClose);
    % plot4(PNear, '.m', 15), plot4(MATClose, 'g.', 1)
    

    % Draw a line between P and Pnear
    NMATTop = size(MATTop, 1);
    PVec = P - PNear; % First, define a vector
    A = PVec(1); B = PVec(2); C = PVec(3);
    H = ones(size(MATTop));

    
    % We will get a list of foots H of normal line from brain surface 
    % points to the vector
    for c=1:NMATTop;
        xc = MATTop(c, 1); yc = MATTop(c, 2); zc = MATTop(c, 3);
        t=(A*(xc - P(1))+B*(yc - P(2))+C*(zc - P(3)))/(A^2+B^2+C^2);
        H(c,:) = [A*t+P(1) B*t+P(2) C*t+P(3)];
    end

    
    % Find diviation between points in MATTop and H
    DH = DistBtw ( H, MATTop ); %This is a distance list for brain
    % surface points to the vector

    
    % Rod Option, expand the line P-Pnear to a rod
    % RodR may be 1 for smoothed images, more for unsmoothed images 
    % Thickness of value RodR will go up if no points are intersect
    for RodR = 1 : 5 % max predefined thickens 5mm
        Iless2 = find( DH <= RodR );
        Rod = MATTop(Iless2,:);
        if ~isempty(Rod)
            break % there are intersected brain surf points
        end
    end
    % plot4(Rod, 'k.')

    
    % Find brain surface points on the vicinity of P
    VicD = DistBtw ( P, Rod );
    
    [VVicD,IVicD] = sort(VicD);

    NVic = 3; % the number of points to be averaged
    if size(Rod,1)<= NVic % if we have less then 3 points
        NVic = size(Rod,1);
    end;
    
    NIVicD = IVicD(1:NVic);
    
    
    % Select top NVic closest points from Pnear within the rod
    Vic = Rod(NIVicD,:); 
    %  plot4(Vic, 'c.')

    
    % Projected point coordinates
    CP(count,:) = mean(Vic,1);
%    plot4(CP, 'r.', 20)
end


% LIST OF PROJECTED COORDINATES
% ..............................................................  ^..^ )~
    PP_List = CP;




