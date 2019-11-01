function [pialsurf, status] = headvol2pialsurf(headvol)

pialsurf = initPialsurf();
status=1;

nSteps = 100;
iStep = 1;

if headvol.isempty(headvol)
    return;
end

brainnames = {'gray matter', 'gm', 'brain', 'cortex', 'pial'};

% Search for index of tissue type brain
idxBrain = [];
for ii=1:length(headvol.tiss_prop)
    if sum(strcmpi(headvol.tiss_prop(ii).name, brainnames))
        idxBrain=ii;
        break;
    end
end

if isempty(idxBrain)
    return;
end

% Zero out all tissue types except brain
k = find(headvol.img ~= idxBrain);
headvol.img(k) = 0;

h = waitbar_msg_print('Generating pial surface from head volume...');
pause(2);

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Downsampling pial surface. This will take a few minutes...', h, iStep, nSteps);
pause(2);

fv = isosurface(headvol.img, 0.9);

% isosurface flips x and y, so we have to either flip x and y back, or have
% the transform do it.
fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Downsampling pial surface. This will take a few minutes...', h, iStep, nSteps);
pause(2);

fv = reduceMesh(fv, 0.15);
pialsurf.pathname = pwd;
pialsurf.mesh = fv;

iStep = iStep+(nSteps/2);
msg = waitbar_msg_print('Finishing pial surface...', h, iStep, nSteps);
pause(2);

status=0;
close(h);
