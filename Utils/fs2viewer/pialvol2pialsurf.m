function [pialsurf, status] = pialvol2pialsurf(pialvol)

pialsurf = initPialsurf();
status=1;

nSteps = 100;
iStep = 1;

if pialvol.isempty(pialvol)
    return;
end

h = waitbar_msg_print('Generating pial surface from pial volume...');
pause(2);

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Downsampling pial surface. This will take a few minutes...', h, iStep, nSteps);
pause(2);

fv = isosurface(pialvol.img, 0.9);

% isosurface flips x and y, so we have to either flip x and y back, or have
% the transform do it.
fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Downsampling pial surface. This will take a few minutes...', h, iStep, nSteps);
pause(2);

[fv.vertices,fv.faces] = reduceMesh(fv.vertices,fv.faces, .30);

pialsurf.pathname = pwd;
pialsurf.mesh = fv;

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Finishing pial surface...', h, iStep, nSteps);
pause(2);

status=0;
close(h);
