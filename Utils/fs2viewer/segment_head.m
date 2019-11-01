function fs2viewer = segment_head(fs2viewer)

%
% USAGE:
%
% [hseg, tiss_type] = segment_head(layers)
%
% AUTHOR: Jay Dubb (jdubb@nmr.mgh.harvard.edu)
% DATE:   12/18/2012
%

layers = fs2viewer.layers;
dirnameVol = fs2viewer.mripaths.volumes;

% Head volume
if ~isempty(layers.head.filename)
    if layers.head.isvolume
        layers.head = loadMri(layers.head);
        layers.head.surf2vol = inv(get_mri_vol2surf(layers.head.volume));
        layers.head.volume.vol = isolate_volume(layers.head.volume.vol, fs2viewer.threshold);
    else
        layers.head.vol = surf_file2vol(layers.head.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% Skin volume
if ~isempty(layers.skin.filename)
    if layers.skin.isvolume
        layers.skin = loadMri(layers.skin);    
    else
        layers.skin.volume.vol = surf_file2vol(layers.skin.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% Skull volume
if ~isempty(layers.skull.filename)
    if layers.skull.isvolume
        [~, layers.skull] = loadMri(fs2viewer, layers.skull.filename);    
    else
        layers.skull.volume.vol = surf_file2vol(layers.skull.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% Dura volume
if ~isempty(layers.dura.filename)
    if layers.dura.isvolume
        layers.dura = loadMri(layers.dura);    
    else
        layers.dura.volume.vol = surf_file2vol(layers.dura.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% CSF volume
if ~isempty(layers.csf.filename)
    if layers.csf.isvolume
        layers.csf = loadMri(layers.csf);    
    else
        layers.csf.volume.vol = surf_file2vol(layers.csf.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% Gray matter volume
if ~isempty(layers.gm.filename)
    if layers.gm.isvolume
        layers.gm = loadMri(layers.gm);    
    else
        layers.gm.volume.vol = surf_file2vol(layers.gm.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

% White matter volume
if ~isempty(layers.wm.filename)
    if layers.wm.isvolume
        layers.wm = loadMri(layers.wm);
    else
        layers.wm.volume.vol = surf_file2vol(layers.wm.filename, layers.head.volsize, layers.head.surf2vol);
    end
end

%%%% Hijack the head mri volume to create segmentation mri file, hseg
hseg = layers.head;
[dname, ~, ext] = fileparts(layers.head.filename);
hseg.filename = sprintf('%s/hseg%s', dname, ext);
[hseg.volume.vol, hseg.tiss_type] = segment_head_vols(layers);

fs2viewer.layers = layers;
fs2viewer.hseg = hseg;
fs2viewer.hseg.orientation = getOrientationFromMriHdr(fs2viewer.hseg.volume);

