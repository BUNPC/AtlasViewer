function [a,b,c,d]=getplanefrom3pt(plane)
%  [a,b,c,d]=getplanefrom3pt(plane)
%
%  calculate the plane equation coefficients for a plane 
%   (determined by 3 points), the plane equation is a*x+b*y+c*z+d=0
%
%  author: Qianqian Fang <fangq at nmr.mgh.harvard.edu>
%  date: 12/12/2008
%
% parameters: 
%      plane: a 3x3 matrix, each row is a 3d point in form of (x,y,z)
%             this is used to define a plane
% outputs:
%      a,b,c,d: the coefficients of the plane equation
%
% for degenerated lines or triangles, this will stop
%
% Please find more information at http://iso2mesh.sf.net/cgi-bin/index.cgi?metch
%
% this function is part of "metch" toobox, see COPYING for license

x=plane(:,1);
y=plane(:,2);
z=plane(:,3);

% compute the plane equation a*x + b*y +c*z +d=0

a=y(1)*(z(2)-z(3))+y(2)*(z(3)-z(1))+y(3)*(z(1)-z(2));
b=z(1)*(x(2)-x(3))+z(2)*(x(3)-x(1))+z(3)*(x(1)-x(2));
c=x(1)*(y(2)-y(3))+x(2)*(y(3)-y(1))+x(3)*(y(1)-y(2));
d=-det(plane);
