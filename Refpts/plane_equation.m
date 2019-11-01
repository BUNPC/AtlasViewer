function plane = plane_equation(p1, p2, p3)

% USAGE:
%  
%    plane = plane_equation(p1, p2, p3)
%
% DESCRIPTION:
%
%    Function takes 3 points, p1, p2, p3, in 3D space and computes the  
%    linear equation coefficients of the plane that contains those 3 points.
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   08/26/2009
%

plane = [];

x1 = p1(1);
y1 = p1(2);
z1 = p1(3);

x2 = p2(1);
y2 = p2(2);
z2 = p2(3);

x3 = p3(1);
y3 = p3(2);
z3 = p3(3);


% Calculate equation of the plane containing p1, p2, p3
A = y1 * (z2 - z3) + y2 * (z3 - z1) + y3 * (z1 - z2);
B = z1 * (x2 - x3) + z2 * (x3 - x1) + z3 * (x1 - x2);
C = x1 * (y2 - y3) + x2 * (y3 - y1) + x3 * (y1 - y2);
D = -(x1 * (y2 * z3 - y3 * z2) + x2 * (y3 * z1 - y1 * z3) + x3 * (y1 * z2 - y2 * z1));

plane = [A B C D];
