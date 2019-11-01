function T=gen_xform_from_pts(p1,p2)
% USAGE:
%    
% T=gen_xform_from_pts(p1,p2)
%
% DESCRIPTION:
% Given two sets of points, p1 and p2 in N dimensions 
% find the N-dims affine transformation matrix T, from p1 to p2. 
%    
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   11/19/2012


T=[];
p=size(p1,1);
q=size(p2,1);
m=size(p1,2);
n=size(p2,2);
if p~=q
    warning('Number of points for p1 and p2 must be the same');
    return;
end
if m~=n
    warning('Number of dimension for p1 and p2 must be the same');
    return;
end
if(p<n)
    menu(sprintf('Cannot solve transformation with fewer anchor\npoints (%d) than dimensions (%d).', p,n),'Okay');
    return;
end
T = eye(n+1);
A = [p1, ones(p,1)];
for ii=1:n
    x(:,ii) = pinv(A)*p2(:,ii);
    T(ii,:) = x(:,ii)'; 
end
