function saveHeadvol(headvol, mode)

if isempty(headvol) | isempty(headvol.img)
    return;
end

dirname = [headvol.pathname, '/anatomical/'];
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end

if ~exist([dirname, 'headvol.vox'], 'file') | strcmp(mode, 'overwrite')
    if ~isempty(headvol.imgOrig)
        headvol.img = headvol.imgOrig;
    else
        headvol.img = xform_apply_vol_smooth(headvol.img, inv(headvol.T_2mc));
    end
    save_vox([dirname, 'headvol.vox'], headvol);
end

