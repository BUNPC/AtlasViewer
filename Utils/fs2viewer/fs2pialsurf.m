function [pialsurf, fs2viewer, status] = fs2pialsurf(fs2viewer)

pialsurf = initPialsurf();

status = 1;

dirname = fs2viewer.mripaths.surfaces;

noder=[];
nodel=[];
elemr=[];
eleml=[];

h = [];

if strcmp(fs2viewer.surfs.pial_rh.filename, [dirname, 'rh.pial'])
    h = waitbar_msg_print('Downsampling right brain surface. This may take a few minutes...');
    [nodeorigr, elemorigr] = read_surf([dirname, 'rh.pial']);
    [noder, elemr] = reduceMesh(nodeorigr, elemorigr, 0.15);
    write_surf([dirname, 'rh.pial_resampled'], noder, elemr);
    fs2viewer.surfs.pial_rh.filename = [dirname, 'rh.pial_resampled'];
end

if strcmp(fs2viewer.surfs.pial_lh.filename, [dirname, 'lh.pial'])
    if isempty(h)
        h = waitbar_msg_print('Downsampling left brain surface. . This may take a few minutes...');
    else
        waitbar_msg_print('Downsampling left brain surface. . This may take a few minutes...', h, 1, 2);
    end
    [nodeorigl, elemorigl] = read_surf([dirname, 'lh.pial']);
    [nodel, eleml] = reduceMesh(nodeorigl, elemorigl, 0.15);
    write_surf([dirname, 'lh.pial_resampled'], nodel, eleml);
    fs2viewer.surfs.pial_lh.filename = [dirname, 'lh.pial_resampled'];
end

if strcmp(fs2viewer.surfs.pial_rh.filename, [dirname, 'rh.pial_resampled'])  && ...
        strcmp(fs2viewer.surfs.pial_lh.filename, [dirname, 'lh.pial_resampled'])
    [noder, elemr] = read_surf([dirname, 'rh.pial_resampled']);
    [nodel, eleml] = read_surf([dirname, 'lh.pial_resampled']);
end


if ~isempty(h)
    close(h);
end

% Check to see if surface exist
if isempty(noder) | isempty(nodel) | isempty(elemr) | isempty(eleml)
    return;
end

nnoder = size(noder,1);
node = [noder ; nodel];
elem = [elemr ; eleml+nnoder];

% Transform pialsurf to headvol space
% We make an assumption here that external surface file are in RAS coordinates
% and are therefore related to the head volume by the T_2vol transformation matrix.
% This assumtion is based on Freesurfer.
%
% TBD: to make this more generic, add options for external surface files
% that doesn't assume Freesurfer and therefore doesn't assume RAS
% coordinates for surfaces.
pialsurf.T_2vol = inv(get_mri_vol2surf(fs2viewer.hseg.volume));
pialsurf.mesh.vertices = xform_apply(node, pialsurf.T_2vol);
pialsurf.mesh.faces = elem;

status = 0;

