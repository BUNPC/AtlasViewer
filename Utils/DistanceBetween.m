function D_List = DistanceBetween ( PA, MAT )

% DISTANCEBETWEEN - Compute distance between vectors.
%
% USEAGE.
%   D_List = DistanceBetween ( PA, MAT )
%
% DESCRIPTION.
%   This function will compute distance between two points
%   or between one point and points in matrix.
%
% INPUTS.
%   PA is vector, e.g. PA = [ x, y, z ];
%
%   MAT is [n,3] matrix of 3D Cartesian coordinates
%   e.g. MAT = [ 51.94 108.78 203.84;  89.18 138.18 225.4 ];
%   
% OUTPUT.
%   D_List is [n,1] list of distances.
%
   
%   Brain Research Group
%   Food Physics Laboratory, Division of Food Function, 
%   National Food Research Institute,  Tsukuba,  Japan
%   WEB: http://brain.job.affrc.go.jp,  EMAIL: valo@nfri.affrc.go.jp
%   AUTHOR: Valer Jurcak,   DATE: 9.jun.2005,    VERSION: 1.0
%-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-


% Checking output ........................................................
    if nargout ~= 1
        error('Too many outputs arguments.')
    end

% Checking inputs ........................................................
    if (nargin ~= 2)
        error('Not enough input arguments.');
    end    

% Inputs are fliped
    if size(PA,1) > size(MAT,1);
        error('Wrong order of inputs.');
    end        



% Distances between matrix & matrix ......................................
    if size(PA,1) == size(MAT,1)
        
    PreD  = MAT - PA;
    PreD2 = PreD.^2;
    PreD3 = sum(PreD2, 2);
    
    D_List = PreD3 .^ 0.5; % Now distance is found
    
    else
% Distances between point & matrix .......................................
    Echo   = repmat(PA, size(MAT,1), 1);
    PreD  = MAT - Echo;
    PreD2 = PreD.^2;
    PreD3 = sum(PreD2, 2);
    
    D_List = PreD3 .^ 0.5; % Now distance is found
    
    end
    
