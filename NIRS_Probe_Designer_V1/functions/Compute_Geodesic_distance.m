function [Total_pathlength,midpoint,surface_points]=Compute_Geodesic_distance(pnt1,pnt2,vertices,faces,NS,Li)

%%% compute geodesic distance between the two optodes: pnt1 and pnt2
%%%% pt 1
X1=pnt1(1);
Y1=pnt1(2);
Z1=pnt1(3);

%%%% pt 2
X2=pnt2(1);
Y2=pnt2(2);
Z2=pnt2(3);

%             NS=10; %%% number of segments to draw
SLx=(X2-X1)/NS;
SLy=(Y2-Y1)/NS;
SLz=(Z2-Z1)/NS;

pts_new=[X1 Y1 Z1];
for i1=1:NS-1
    pt_next=[X1+SLx*i1 Y1+SLy*i1 Z1+SLz*i1];
    pts_new=[pts_new; pt_next];
end
pts_new=[pts_new; X2 Y2 Z2];
xmin = min([X1 X2]);
xmax = max([X1 X2]);
ymin = min([Y1 Y2]);
ymax = max([Y1 Y2]);
zmin = min([Z1 Z2]);
zmax = max([Z1 Z2]);

try
    %%%% box limit to clip the mesh
    box = [xmin-Li xmax+Li ymin-Li ymax+Li zmin-Li zmax+Li];
    [FV.vertices, FV.faces] = clipMeshVertices(vertices, faces, box);
    [distances,surface_points] = point2trimesh(FV, 'QueryPoints', pts_new(2:end-1,:),'Algorithm','linear');
catch
    FV.vertices=vertices;
    FV.faces=faces;
    [distances,surface_points] = point2trimesh(FV, 'QueryPoints', pts_new(2:end-1,:),'Algorithm','linear');
end

surface_points=[pts_new(1,:); surface_points; pts_new(end,:)];

pathlength=[0 0];
for i1=1:size(surface_points,1)-1
    SL=dist(surface_points(i1,:),surface_points(i1+1,:)');
    pathlength=[pathlength; SL SL+pathlength(end,2)];
end
Total_pathlength=sum(pathlength(:,1));
Ds=abs(Total_pathlength/2-pathlength(:,2));
L=find(Ds==min(Ds));
midpoint=surface_points(L(1),:);
