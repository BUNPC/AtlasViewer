%code to create a mesh from a 3D MRI segmented image call head
function scalp_vertices = img2mesh(head,displ)
%
% PLOT4 -  
%
% USAGE.
%   scalp_vertices = img2mesh(head,displ)
%
% DESCRIPTION.
%   
%   
%   
%   
%   
%   
%
% INPUTS.
%   
%   
%   
%    e.g. gray -> [0.8 0.8 0.8], define MC just as marker e.g. '.' or '-'
%   MS defines 'MarkerSize'  e.g. 15; default is 10
%   COLOR - define own (not matlab predefined) color e.g. [0.8 0.8 0.8] or
%    random color [randn(1,3)]
%   
% OUTPUT.
%   Output is plot3.

   
%   Brain Research Group
%   MIT Research Group 
%   National Food Research Institute,  Tsukuba,  Japan
%   Computer Science and Artificial Intelligence Laboratory, Cambridge, MA
%   WEB: http://brain.job.affrc.go.jp,  EMAIL: annac@mit.edu
%   AUTHOR: Anna Custo and Daisuke ??
%-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-~-

[xsize ysize zsize]=size(head);
head(isnan(head)) = 0; % after registration there might be NaN from the interpolation
head(find(head ~= 0)) = 1;

% zero padding to avoid cutting bounderies...
headorig = head;
head = zeros(xsize+6, ysize+6, zsize+6);
head(4:xsize+3,4:ysize+3,4:zsize+3) = headorig;

tmp = zeros(size(head));
disp('y-z shift...');
tmp(2:end,:,:) = head(1:end-1,:,:); % shift y-z right
z1 = head - tmp;
z1(find(z1 == -1)) = 0;

tmp(1:end-1,:,:) = head(2:end,:,:); % shift y-z left
z1 = z1 + head - tmp;
z1(find(z1 == -1)) = 0;

disp('x-z shift...');
tmp(:,2:end,:) = head(:,1:end-1,:); % shift x-z right
z1 = z1 + head - tmp;
z1(find(z1 == -1)) = 0;

tmp(:,1:end-1,:) = head(:,2:end,:); % shift x-z left
z1 = z1 + head - tmp;
z1(find(z1 == -1)) = 0;

disp('x-y shift...');
% % do this only if you want the bottom/neck part as well...
% tmp(:,:,2:end) = head(:,:,1:end-1); % shift x-y right
% z1 = z1 + head - tmp;
% z1(find(z1 == -1)) = 0;

tmp(:,:,1:end-1) = head(:,:,2:end); % shift x-y left
z1 = z1 + head - tmp;
z1(find(z1 == -1)) = 0;

clear tmp;

disp('vectorializing the scalp voxels...');
[scalp_x scalp_y scalp_z] = ind2sub(size(head),find(z1 ~= 0));
scalp_vertices = [scalp_x'-3; scalp_y'-3; scalp_z'-3]';

clear head;

if displ == 1, 
    figure;
    plot4(scalp_vertices, 'c.', 1); 
    axis equal;
    set(gca, 'Color', [0 0 0]); 
end;
