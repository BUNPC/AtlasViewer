function [vertices ivertices] = plane_surf_intersect(plane, surf, dt)

% USAGE:
%   
%     [vertices ivertices] = plane_surf_intersect(plane, surf, dt) 
%
% EXAMPLE:
%   
%
%     vol = gen_sphere(30, [50 48 52], [100 100 100]);
%     [f v] = isosurface(vol, .9);
%     v=[v(:,2) v(:,1) v(:,3)];
%     fv.vertices = v; fv.faces = f;
%     p1=[26 33 43]; p2=[39 30 73]; p3=[69 29 65];
%     [A B C D] = plane_equation(p1,p2,p3);
%
%     curve_pts = plane_surf_intersect([A B C D], v, .4);
%
%     viewsurf(fv, .7, 'g'); hold on
%     h1=plot3(p1(:,1),p1(:,2),p1(:,3),'.r', 'markersize', 25); 
%     h2=plot3(p2(:,1),p2(:,2),p2(:,3),'.r', 'markersize', 25); 
%     h3=plot3(p3(:,1),p3(:,2),p3(:,3),'.r', 'markersize', 25);
%     h=plot3(curve_pts(:,1), curve_pts(:,2), curve_pts(:,3), '.k');
%  
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   08/26/2009

DEBUG=0;

if isstruct(surf)
    vertices0 = surf.vertices;
    faces0 = surf.faces;
else
    vertices0 = surf;
    faces0 = [];
end

if(~exist('dt') | isempty(dt))
    dt=.3;
end

A = plane(1);
B = plane(2);
C = plane(3);
D = plane(4);


% Loop through all points on the curved surface
% surf and find all points that are close than  
% the distance threshold, dt
vertices = [];
ivertices = [];
n = size(vertices0, 1);
jj = 1;
for ii=1:n
   i=vertices0(ii,1);
   j=vertices0(ii,2);
   k=vertices0(ii,3);

   %
   % Find distance from point (i,j,k) on the curved surface 
   % surf to the plane with equation Ax+By+Cz+D=0
   % 
   % http://en.wikipedia.org/wiki/Plane_(mathematics)
   %
   d = abs(A*i + B*j + C*k + D) / sqrt(A^2 + B^2 + C^2);
   if (d < dt)
       vertices(jj,:) = vertices0(ii,:);
       if DEBUG
           hold on
           h = plot3(vertices(jj,1), vertices(jj,2), vertices(jj,3), '.g');
           drawnow;
           hold off
       end
       ivertices(jj) = ii;
       jj=jj+1;
   end
end

