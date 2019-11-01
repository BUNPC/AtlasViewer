function savePialvol(pialvol, mode)

if isempty(pialvol) | isempty(pialvol.img)
    return;
end

dirname = [pialvol.pathname, '/anatomical/'];

if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end

if ~exist([dirname, 'pialvol.vox'], 'file') | strcmp(mode, 'overwrite')
    if ~isempty(pialvol.imgOrig)
        pialvol.img = pialvol.imgOrig;
    else
        pialvol.img = xform_apply_vol_smooth(pialvol.img, inv(pialvol.T_2mc));
    end
    save_vox([dirname, 'pialvol.vox'], pialvol);
end

