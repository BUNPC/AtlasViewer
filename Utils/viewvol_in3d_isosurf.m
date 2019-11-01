function h = viewvol_in3d_isosurf(vol, dess, opaqueness, color, light_onoff, axes_order)

%
% Usage:
%
%    h = viewvol_in3d_isosurf(vol, dess, opaqueness, color, light_onoff, axes_order)
% 

if(~exist('axes_order') | isempty(axes_order))
    axes_order=[1 2 3];
end

if(~exist('dess'))
    dess = 2;
end

vol = vol(1:dess:end,1:dess:end,1:dess:end);
[Dx Dy Dz] = size(vol);
fv = isosurface(vol, 0.9);
fv.vertices = [fv.vertices(:,2), fv.vertices(:,1), fv.vertices(:,3)];
h = patch(fv);

if(exist('color','var'))
    set(h, 'FaceColor', color, 'EdgeColor', 'none');
else
    set(h, 'FaceColor', 'red', 'EdgeColor', 'none');
end

%%%% Transperency level %%%%
if(exist('opaqueness'))
    set(h, 'facealpha', opaqueness);
else
    set(h, 'facealpha', .7);
end


%%%% Lighting %%%%
if(exist('light_onoff'))
    if(strcmp(light_onoff, 'on'))
		daspect([1 1 1]);
		view(3);
		l = camlight;
		set(l,'Position',[64 -1000 64]);
		set(l,'Position',[64  1000 64]);
		camlight(0,0);
		lighting phong;
    end
end

x_min_max = get(gca, 'xlim');
y_min_max = get(gca, 'ylim');
z_min_max = get(gca, 'zlim');
xmin = x_min_max(1); xmax = x_min_max(2);
ymin = y_min_max(1); ymax = y_min_max(2);
zmin = z_min_max(1); zmax = z_min_max(2);
set(gca, 'xlim', [xmin-5 xmax+5]);
set(gca, 'ylim', [ymin-5 ymax+5]);
set(gca, 'zlim', [zmin-5 zmax+5]);
set(gca, 'xgrid', 'on');
set(gca, 'ygrid', 'on');
set(gca, 'zgrid', 'on');
xlabel('x');
ylabel('y');
zlabel('z');

axis equal;
rotate3d on
