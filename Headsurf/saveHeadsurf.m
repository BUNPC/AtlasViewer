function saveHeadsurf(headsurf, T_vol2mc, mode)

if isempty(headsurf) | isempty(headsurf.mesh.vertices)
    return;
end

dirname = [headsurf.pathname, '/anatomical/'];
if ~exist(dirname, 'dir')
    mkdir(dirname);
end
if ~exist('T_vol2mc','var') | isempty(T_vol2mc)
    T_vol2mc = eye(4);
end
if ~exist('mode', 'var')
    mode='nooverwrite';
end


if ~exist([dirname, '/headsurf.mesh'], 'file') | strcmp(mode, 'overwrite')
    headsurf.mesh.vertices = xform_apply(headsurf.mesh.vertices, inv(T_vol2mc * headsurf.T_2vol));
    write_surf([dirname, '/headsurf.mesh'], headsurf.mesh.vertices, headsurf.mesh.faces);
end

if ~exist([dirname, '/headsurf2vol.txt'], 'file') | strcmp(mode, 'overwrite')
    T = headsurf.T_2vol;
    save([dirname, '/headsurf2vol.txt'], 'T','-ascii');
end
