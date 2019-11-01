function [headsurf, status] = headvol2headsurf(headvol)

headsurf = initHeadsurf();

status=1;
nSteps = 100;
iStep = 1;

if headvol.isempty(headvol)
    return;
end

headnames = {'head','skin','scalp'};

% Search for index of tissue type head
idxhead = [];
for ii=1:length(headvol.tiss_prop)
    if sum(strcmpi(headvol.tiss_prop(ii).name, headnames))
        idxhead=ii;
        break;
    end
end

if isempty(idxhead)
    return;
end

% Assign one tissue type to all non-zero voxels
k = find(headvol.img ~= 0);
headvol.img(k) = idxhead;

h = waitbar_msg_print(sprintf('Generating head surface from volume...'));

fv = isosurface(headvol.img,.9);

% isosurface flips x and y, so we have to either flip x and y back, or have
% the transform do it.
fv.vertices = [fv.vertices(:,2) fv.vertices(:,1) fv.vertices(:,3)];

iStep = iStep+30;
waitbar_msg_print(sprintf('Downsampling head surface...'), h, iStep, nSteps);

[fv.vertices, fv.faces] = reduceMesh(fv.vertices,fv.faces,0.15);

headsurf.pathname = pwd;
headsurf.mesh = fv;

iStep = iStep+30;
waitbar_msg_print('Downsampling head surface.', h, iStep, nSteps);

pause(2);
close(h);

status = 0;

