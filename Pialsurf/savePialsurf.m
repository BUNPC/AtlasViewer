function savePialsurf(pialsurf, T_vol2mc, mode)

if isempty(pialsurf) | isempty(pialsurf.mesh.vertices)
    return;
end

dirname = [pialsurf.pathname, '/anatomical/'];
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('T_vol2mc','var') | isempty(T_vol2mc)
    T_vol2mc = eye(4);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end


if ~exist([dirname, '/pialsurf.mesh'], 'file') | strcmp(mode, 'overwrite')
    pialsurf.mesh.vertices = xform_apply(pialsurf.mesh.vertices, inv(T_vol2mc*pialsurf.T_2vol));
    write_surf([dirname, '/pialsurf.mesh'], pialsurf.mesh.vertices, pialsurf.mesh.faces);
end

if ~exist([dirname, '/pialsurf2vol.txt'], 'file') | strcmp(mode, 'overwrite')
    T = pialsurf.T_2vol;
    save([dirname, '/pialsurf2vol.txt'], 'T','-ascii');
end

