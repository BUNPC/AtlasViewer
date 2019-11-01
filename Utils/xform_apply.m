function v1 = xform_apply(v, T)

% 
% Usage:   v1 = xform_apply(v, T)
% 
% Description: applies 2D or 3D transformation matrix T to every 
% vertex in array v and return the new transformed array
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   11/13/2008
%
% Changed; Jay Dubb
% Date:    03/12/2014

v1 = double([]);  
if isempty(v)
    return
end

n = size(v, 1);
v=v';


if(all(size(T) == [4 4]) | all(size(T) == [3 4]))
    A = T(1:3, 1:3);
    b = T(1:3,4);
elseif(all(size(T) == [3 3]) | all(size(T) == [2 3]))
    A = T(1:2,1:2);
    b = T(1:2,3);
end

v1 = A*v;
for i=1:n
    v1(:,i) = v1(:,i)+b;
end
v1=v1';
