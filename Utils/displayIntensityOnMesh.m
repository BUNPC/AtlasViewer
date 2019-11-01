function [h, l] = displayIntensityOnMesh(mesh, intensity, light_onoff, visible, axes_order)

% Usage:
%
%     [h, l] = displayIntensityOnMesh(mesh, intensity, light_onoff, visible, axes_order)
%
% Written by Jay Dubb
%

h=[];
l=[];

if ~exist('visible','var')
    visible = 'on';
end
    
if ~exist('axes_order','var')
    axes_order=[1 2 3];
end

nodes = mesh.vertices;
elem  = mesh.faces;
nnodes = size(nodes,1);
k=find(intensity==-Inf);
intensity(k)=0;
h=trisurf(elem, nodes(:,axes_order(1)), nodes(:,axes_order(2)), nodes(:,axes_order(3)), ...
          intensity,'facecolor','interp','edgealpha',0, 'visible',visible);
set(h,'diffusestrength',.9,'specularstrength',.12,'ambientstrength',.2);

%%%% Lighting %%%%
if(~exist('light_onoff') | (exist('light_onoff') & strcmp(light_onoff,'on')))
    l = camlight;
    set(l,'Position',[50 2000 100]);

    l2 = camlight;
    set(l2,'Position',[50 -100 -100]);

    camlight(0,0);
end
lighting phong;

