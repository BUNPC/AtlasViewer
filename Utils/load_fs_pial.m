function pial=load_fs_pial(subj,pial)

if ~exist('pial','var')
    pial = [];
end

if(~exist([subj '/surf/rh.pial_resampled'],'file') | ...
   ~exist([subj '/surf/lh.pial_resampled'],'file'))

    [nodeorigr,elemorigr] = read_surf([subj '/surf/rh.pial']);
    [nodeorigr,elemorigr] = meshcheckrepair(nodeorigr,elemorigr);
    [noder,elemr] = reduceMesh(nodeorigr,elemorigr,0.1);
    
    [nodeorigl,elemorigl] = read_surf([subj '/surf/lh.pial']);
    [nodeorigl,elemorigl] = meshcheckrepair(nodeorigl,elemorigl);
    [nodel,eleml] = reduceMesh(nodeorigl,elemorigl,0.1);
    
    nodeorig = [nodeorigr ; nodeorigl];
    elemorig = [elemorigr ; elemorigl+size(nodeorigr,1)];
    node = [noder ; nodel];
    elem = [elemr ; eleml+size(noder,1)];
    
    write_surf([subj '/surf/rh.pial_resampled'], noder, elemr);
    write_surf([subj '/surf/lh.pial_resampled'], nodel, eleml);
else
    [nodeorigr,elemorigr] = read_surf([subj '/surf/rh.pial']);
    [nodeorigl,elemorigl] = read_surf([subj '/surf/lh.pial']);
    
    [noder,elemr] = read_surf([subj '/surf/rh.pial_resampled']);
    [nodel,eleml] = read_surf([subj '/surf/lh.pial_resampled']);
    
    nodeorig = [nodeorigr ; nodeorigl];
    elemorig = [elemorigr ; elemorigl+size(nodeorigr,1)];
    node = [noder ; nodel];
    elem = [elemr ; eleml+size(noder,1)];
end

nnoder = size(noder,1);
node = [noder ; nodel];
elem = [elemr ; eleml+nnoder];

T_ras2vox = eye(4);
if exist([subj '/vox2ras.txt'], 'file')
    % Freesurfer volumes start with 0, matlab starts with 1.
    % We need to account for this by translaring by one voxel
    T = inv(load([subj '/vox2ras.txt']));
    T_ras2vox = [T(1:3,1:3), T(1:3,4)+1; [0,0,0,1]];
end
nodeX = xform_apply(node,T_ras2vox);
nodeorigX = xform_apply(nodeorig,T_ras2vox);

% Map high-res pial indices to low-res
if(~exist([subj '/map_mesh_idx_lr2hr.mat'],'file'))
    display(sprintf('Mapping LR mesh to HR mesh for subject %s',subj));
    map_mesh_idx_lr2hr = map_mesh_idx(nodeX, nodeorigX);
    save([subj '/map_mesh_idx_lr2hr.mat'],'map_mesh_idx_lr2hr');
else
    load([subj '/map_mesh_idx_lr2hr.mat']);
end

% Map low-res pial indices to high-res
if(~exist([subj '/map_mesh_idx_hr2lr.mat'],'file'))
    display(sprintf('Mapping HR mesh to LR mesh for subject %s',subj));
    map_mesh_idx_hr2lr=map_mesh_idx(nodeorigX, nodeX);
    save([subj '/map_mesh_idx_hr2lr.mat'],'map_mesh_idx_hr2lr');
else
    load([subj '/map_mesh_idx_hr2lr.mat']);
end

pial.node_hr            = nodeorigX;
pial.faces_hr           = elemorig;
pial.node_lr            = nodeX;
pial.faces_lr           = elem;
pial.nnode_r_hr         = size(nodeorigr,1);
pial.nfaces_r_hr        = size(elemorigr,1);
pial.nnode_r_lr         = size(noder,1);
pial.nfaces_r_lr        = size(elemr,1);
pial.map_mesh_idx_hr2lr = map_mesh_idx_hr2lr;
pial.map_mesh_idx_lr2hr = map_mesh_idx_lr2hr;

% Note: mapping low res mesh values to high res is
% the reverse process of mapping low res mesh indices
% to high res, and vice versa.
pial.map_mesh_hr2lr     = map_mesh_idx_lr2hr;
pial.map_mesh_lr2hr     = map_mesh_idx_hr2lr;
