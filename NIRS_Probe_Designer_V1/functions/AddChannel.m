function AddChannel(handles,Si,txt,Label,Src_No,Det_No)
% global SelectMode Grabbed Snap Points Weights Xi Degree Index

%%%%% get the  faces and vertices
hi = findobj(gca,'Tag','nd'); % get the head handle
hj=get(hi);
vertices=hj.Vertices;
faces=hj.Faces;

%%%% keep only vertices above z=0
Li=find((vertices(:,3)>0)==1);
Nodes_Int=vertices(Li,:);
Normal_Int=hj.VertexNormals(Li,:); %%%% Normal vectot for each node

%%%%% generate a sphere for electrodes
r=5;
[x,y,z] = sphere;

%%%%% set parametyers for optode visualization
AmbientStrength=0.2;
DiffuseStrength=0.8;
SpecularStrength=0.5;
SpecularExponent=25;
Lij=5;

hs=findobj(gcf,'Tag',['S' num2str(Src_No)]);
hd=findobj(gcf,'Tag',['D' num2str(Det_No)]);

Xi=get(hs);
Source=Xi.UserData;
Yi=get(hd);
Detector=Yi.UserData;
%%%% pt 1
X1=Source(1);
Y1=Source(2);
Z1=Source(3);

%%%% pt 2
X2=Detector(1);
Y2=Detector(2);
Z2=Detector(3);

NS=2; %%% number of segments to draw
SLx=(X2+X1)/NS;
SLy=(Y2+Y1)/NS;
SLz=(Z2+Z1)/NS;

pts_new=[SLx SLy SLz];
xmin = min([X1 X2]);
xmax = max([X1 X2]);
ymin = min([Y1 Y2]);
ymax = max([Y1 Y2]);
zmin = min([Z1 Z2]);
zmax = max([Z1 Z2]);

Li=10; %%% box limit to clip the mesh
box = [xmin-Li xmax+Li ymin-Li ymax+Li zmin-Li zmax+Li];
[FV.vertices, FV.faces] = clipMeshVertices(vertices, faces, box);
[distances,selectedPoint] = point2trimesh(FV, 'QueryPoints', pts_new,'Algorithm','linear');

Ds=dist(Nodes_Int,selectedPoint');
L=find(Ds==min(abs(Ds)));
b=Normal_Int(L(1),:);


handles.hj(Si,1) = surf(r*x+selectedPoint(1),r*y+selectedPoint(2),r*z+selectedPoint(3),'Facecolor','c','EdgeColor','none','Tag',txt,'DisplayName',Label);
set(handles.hj(Si,1),'FaceLighting','phong','AmbientStrength',AmbientStrength,'DiffuseStrength',DiffuseStrength,'SpecularStrength',SpecularStrength,'SpecularExponent',SpecularExponent,...
    'BackFaceLighting','unlit','UserData',selectedPoint);
handles.hj(Si,2)=text(selectedPoint(1)+Lij*b(1)+1,selectedPoint(2)+Lij*b(2)+1,selectedPoint(3)+Lij*b(3)+1,txt,'fontsize',12,'color','k','FontWeight','bold');
set(handles.hj(Si,2),'UserData',b);
