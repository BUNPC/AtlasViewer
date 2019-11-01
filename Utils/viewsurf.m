function [h l] = viewsurf(fv, opaqueness, col, light_onoff, axes_order)


% Usage:
%
%     h = viewsurf(fv, opaqueness, col, light_onoff)
%
% Description:
%
%     Displays surface containing vertices and faces, of the opaqueness
%     and color spcified in opaqueness and col parameters. Opaqueness is
%     a number between 0 and 1, the smaller it is, the more transparent 
%     the image of the mesh. 
% 
% Example 1:
%     
%     h = viewsurf(fv, .7, 'red', 'on');     
%
% Example 2:
%     
%     h = viewsurf(mesh, .8, [.9 .9 .9], 'on');
%
% Author: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% Date:   05/16/2012

h=[];
l=[];

if isempty(fv)
    return;
end
if isempty(fv.vertices) | isempty(fv.faces)
    return;
end

if ~exist('axes_order','var')
    axes_order=[1 2 3];
end


% first flip first and second axes because patch flips them
fv.vertices=[fv.vertices(:,axes_order(1)) fv.vertices(:,axes_order(2)) fv.vertices(:,axes_order(3))];
h = patch(fv);    
if(exist('col'))
    set(h, 'FaceColor', col, 'EdgeColor', 'none');
else
    set(h, 'FaceColor', 'red', 'EdgeColor', 'none');
end

%%%% Transperency level %%%%
if(exist('opaqueness'))
    set(h, 'facealpha', opaqueness);
else
    set(h, 'facealpha', .7);
end
set(h,'diffusestrength',.9,'specularstrength',.12,'ambientstrength',.2);


daspect([1 1 1]);
% view(3);

%%%% Lighting %%%%
if(~exist('light_onoff') | (exist('light_onoff') & strcmp(light_onoff, 'on')))
    l = camlight;
    set(l,'Position',[50 2000 100]);
    camlight(0,0);
end
lighting phong;

