function [v, t] = readsurf_trans(filename, T)

% 
% Usage:
%
% function [v, t] = readsurf_trans(filename, T)
% 
% Description: 
% 
%   This function reads a tesselated surface file, filename 
%   and applies the tranformation T to the vertices, v. A tesselated 
%   surface is described in terms of connected triangles. The 
%   tesselated surface file has the following format: 
%   
%   2 sets os rows; one of vertices, one of triangle faces. Each 
%   row of the triangle face set has three indices into the vertex array, 
%   specifying which 3 vertices combine to make a surface triangle. 
%   Here's an example small portion of a tesselated file, with 2562 
%   vertices and 5120 triangle faces.
%
%       2562
%       1    0.1768    0.5976   78.6509
%       2   60.4849   -1.0700   45.7082
%       3   21.7187   63.9851   53.9352
%       4  -48.1773   32.5930   44.3000
%        . . . . . . . .
%      
%        5120
%       1    1  643  645
%       2  643  163  644
%       3  645  643  644
%       4  645  644  165
%       5  163  646  648
%        . . . . . . . .
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%

    fid = fopen(filename,'rt');
    nv = fscanf(fid, '%d', 1);

    v = fscanf(fid, '%f', [4, nv]);
    v = v';

    nt = fscanf(fid, '%d', 1);  
    t = fscanf(fid, '%d', [4, nt]);
    t = t';
    
    v(:, 1) = [];
    t(:, 1) = [];
    
    for i=1:nv  
	vi = T * [v(i, 1)  v(i, 2) v(i, 3)  1]';
	v(i, :) = [vi(1, :) vi(2, :) vi(3, :)];
    end

    
