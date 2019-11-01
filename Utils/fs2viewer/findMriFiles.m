function fs2viewer = findMriFiles(fs2viewer)

dirnameVol       = fs2viewer.mripaths.volumes;
dirnameSurf      = fs2viewer.mripaths.surfaces;
dirnameSurfFlash = fs2viewer.mripaths.surfaces_flash;

head_fn      = '';
skin_fn      = '';
skull_fn     = '';
dura_fn      = '';
csf_fn       = '';
gm_fn        = '';
wm_fn        = '';
pial_rh_fn   = '';
pial_lh_fn   = '';
hseg_fn      = '';


%%%%%%%%%%%%%%%%%%%%%%%
% Volume files
%%%%%%%%%%%%%%%%%%%%%%%

% 1. Head
if(exist([dirnameVol, 'T1.nii'],'file'))
    head_fn = [dirnameVol, 'T1.nii'];
elseif(exist([dirnameVol, 'head.nii'],'file'))
    head_fn = [dirnameVol, 'head.nii'];
elseif(exist([dirnameVol, 'T1.mgz'],'file'))
    head_fn = [dirnameVol, 'T1.mgz'];
elseif(exist([dirnameVol, 'head.mgz'],'file'))
    head_fn = [dirnameVol, 'head.mgz'];
end

% 2. Outer skin
if exist([dirnameSurfFlash, 'outer_skin.tri'], 'file')
    skin_fn  = [dirnameSurfFlash, 'outer_skin.tri'];
    fs2viewer.layers.skin.isvolume = false;
end

% 3. Outer skull
if exist([dirnameSurfFlash, 'outer_skull.tri'], 'file')
    skull_fn = [dirnameSurfFlash, 'outer_skull.tri'];
    fs2viewer.layers.skull.isvolume = false;
elseif exist([dirnameVol, 'skull.nii'], 'file')
    skull_fn = [dirnameVol, 'skull.nii'];
end

% 4. Dura / Inner skull 
if exist([dirnameSurfFlash, 'inner_skull.tri'], 'file')
    dura_fn = [dirnameSurfFlash, 'inner_skull.tri'];
    fs2viewer.layers.dura.isvolume = false;
elseif exist([dirnameVol, 'dura.nii'], 'file')
    dura_fn = [dirnameVol, 'dura.nii'];
end

% 5. CSF
if exist([dirnameVol, 'brain.nii'], 'file') & exist([dirnameVol, 'T1.nii'], 'file') 
    csf_fn = [dirnameVol, 'brain.nii'];
elseif exist([dirnameVol, 'csf.nii'], 'file')
    csf_fn = [dirnameVol, 'csf.nii'];
elseif exist([dirnameVol, 'brain.mgz'], 'file') & exist([dirnameVol, 'T1.mgz'], 'file') 
    csf_fn = [dirnameVol, 'brain.mgz'];
elseif exist([dirnameVol, 'csf.mgz'], 'file')
    csf_fn = [dirnameVol, 'csf.mgz'];
end

% 6. Gray Matter
if exist([dirnameVol, 'aseg.nii'], 'file') & exist([dirnameVol, 'T1.nii'], 'file') 
    gm_fn = [dirnameVol, 'aseg.nii'];
elseif exist([dirnameVol, 'gm.nii'], 'file')
    gm_fn = [dirnameVol, 'gm.nii'];
elseif exist([dirnameVol, 'brain.nii'], 'file') & ~exist([dirnameVol, 'T1.nii'], 'file') 
    gm_fn = [dirnameVol, 'brain.nii'];
elseif exist([dirnameVol, 'aseg.mgz'], 'file') & exist([dirnameVol, 'T1.mgz'], 'file') 
    gm_fn = [dirnameVol, 'aseg.mgz'];
elseif exist([dirnameVol, 'gm.mgz'], 'file')
    gm_fn = [dirnameVol, 'gm.mgz'];
elseif exist([dirnameVol, 'brain.mgz'], 'file') & ~exist([dirnameVol, 'T1.mgz'], 'file') 
    gm_fn = [dirnameVol, 'brain.mgz'];
end

% 7. White Matter
if exist([dirnameVol, 'wm.nii'], 'file')
    wm_fn = [dirnameVol, 'wm.nii'];
elseif exist([dirnameVol, 'wm.mgz'], 'file')
    wm_fn = [dirnameVol, 'wm.mgz'];
end


%%%%%%%%%%%%%%%%%%%%%%%
% Surface files
%%%%%%%%%%%%%%%%%%%%%%%
if exist([dirnameSurf, 'rh.pial_resampled'],'file')
    pial_rh_fn = [dirnameSurf, 'rh.pial_resampled'];
elseif exist([dirnameSurf, 'rh.pial'],'file')
    pial_rh_fn = [dirnameSurf, 'rh.pial'];
end

if exist([dirnameSurf, 'lh.pial_resampled'],'file')
    pial_lh_fn = [dirnameSurf, 'lh.pial_resampled'];
elseif exist([dirnameSurf, 'lh.pial'],'file')
    pial_lh_fn = [dirnameSurf, 'lh.pial'];
end


% Check if the segmented volume already exists
if exist([dirnameVol, 'hseg.nii'], 'file')
    hseg_fn = [dirnameVol, 'hseg.nii'];
elseif exist([dirnameVol, 'hseg.mgz'], 'file')
    hseg_fn = [dirnameVol, 'hseg.mgz'];
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assign all filenames to fs2viewer
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fs2viewer.layers.head.filename  = head_fn;
fs2viewer.layers.skin.filename  = skin_fn;
fs2viewer.layers.skull.filename = skull_fn;
fs2viewer.layers.dura.filename  = dura_fn;
fs2viewer.layers.csf.filename   = csf_fn;
fs2viewer.layers.gm.filename    = gm_fn;
fs2viewer.layers.wm.filename    = wm_fn;

fs2viewer.surfs.pial_rh.filename  = pial_rh_fn;
fs2viewer.surfs.pial_lh.filename  = pial_lh_fn;

fs2viewer.hseg.filename = hseg_fn;

