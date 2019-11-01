function [D_List, Fruit] = DistBtw ( MA, MB, Num )

% DISTBTW - Computes distance between vectors.
%
% USAGE.
%   [D_List, Fruit] = DistBtw ( MA, MB, Num )
%
% DESCRIPTION.
%   This function computes distances between two vectors or vector and
%   matrix or two matrix with the same size. If the input is only single
%   matrix (e.g. sorted apical points creating arch ) it computes
%   distances & cumulative distances between matrix points. 
%   If there are three inputs (first input is vector, second one is matrix,
%   third one is number) it selects number of matrix points
%   closest to the vector.
%
% INPUTS.
%   MA is vector or matrix [n,3], e.g. MA = [ x, y, z ];
%   MB is vector or matrix [n,3]
%   Num is number determining the number for the selection of the closest
%   points from matrix MB to vector MA
%   
% OUTPUTS.
%   D_List is [n,1] list of distances or coordinates of the closest points.
%   Fruit is [n,1] list of distances or cumulative distances.
   
%   Brain Research Group
%   Food Physics Laboratory, Division of Food Function, 
%   National Food Research Institute,  Tsukuba,  Japan
%   WEB: http://brain.job.affrc.go.jp,  EMAIL: dan@nfri.affrc.go.jp
%   AUTHOR: Valer Jurcak,   DATE: 12.jan.2006,    VERSION: 1.3
%-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-



% CHECK INPUTS & OUTPUTS
% ..............................................................  ^..^ )~
    % Check size
    if nargin == 1 & size(MA,1) < 3
        error('For one input minimum size of matrix is [3,3].')
    end
    
    if nargin == 2
        sA = size(MA,1); sB = size(MB,1);
        if sA < 2 | sB < 2 | sA==sB
            % OK
        else
         error('Can compute distance between "vector & vector", "vector & matrix" or "matrix & matrix" with the same size.')
        end
    end
    
    if nargout > 2
        error('Too many output arguments.');
    end
    
    
    % Keep [n,3] size
    if nargin == 1 
        MA = MA(:,1:3);
    end
    
    % Keep [n,3] size
    if nargin == 2 | nargin == 3
        MA = MA(:,1:3);
        MB = MB(:,1:3);
    end

    
% MAKE OUTPUT
% ..............................................................  ^..^ )~
    Fruit = [];


    
% ONE INPUT -> COMPUTES DISTANCES AND CUMULATIVE DISTANCES BETWEEN
% SORTED POINTS e.g. apical points which create arch 
% ..............................................................  ^..^ )~
if nargin == 1
    
        % Distances between points in MA matrix
        for n = 1 : size(MA, 1) - 1
                PreD = MA(n,:) - MA(n+1,:);
                PreD2 = PreD.^2;
                PreD3 = sum(PreD2, 2);   
                PreD4(n,1) = PreD3 .^ 0.5; 
        end
        D_List = PreD4;
        clear n

        % Cumulative distances
        Fruit = zeros(size(MA,1),1);
        Fruit(2:end) = PreD4;
        Fruit = cumsum(Fruit); % cumulative distances       
end    


    
% TWO INPUTS -> COMPUTE DISTANCES BETWEEN (VECTOR or MATRIX) & MATRIX
% ..............................................................  ^..^ )~
if nargin == 2
    
    % Check size
        if size(MA,1) > size(MB,1);
            DxM = MB;  DxN = MA;
        else
            DxM = MA;  DxN = MB;
        end        

    % Distances between matrix & matrix
        if size(DxM,1) == size(DxN,1)        
            PreD = DxN - DxM;
            PreD2 = PreD.^2;
            PreD3 = sum(PreD2, 2);    
            D_List = PreD3 .^ 0.5; % Now distance is found    
        else
    % Distances between vector & matrix
            Echo = repmat(DxM, size(DxN,1), 1);
            PreD  = DxN - Echo;
            PreD2 = PreD.^2;
            PreD3 = sum(PreD2, 2);    
            D_List = PreD3 .^ 0.5; % Now distance is found    
        end
end
    


% THREE INPUTS -> SELECT Num OF CLOSEST VECTORS TO MA
% ..............................................................  ^..^ )~
if nargin == 3
    
    % Distances between vector & matrix 
        Echo = repmat( MA, size(MB, 1), 1 );
        PreD  = MB - Echo;
        PreD2 = PreD.^2;
        PreD3 = sum(PreD2, 2);
    
        PreD4 = PreD3 .^ 0.5; % Now distance is found

    % Sort matrix according to distances
        MatRiX = [MB, PreD4]; % add forth column of distances
        MatRiX = sortrows(MatRiX, 4); % sorting
        D_List = MatRiX(1:Num, 1:3); % number of closest points
        Fruit = MatRiX(1:Num, 4); % actual distances
end
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    