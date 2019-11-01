function headsurf = getHeadsurf(headsurf, dirname0)

if iscell(dirname0)
    for ii=1:length(dirname0)
        headsurf = getHeadsurf(headsurf, dirname0{ii});
        if ~headsurf.isempty(headsurf)
            return;
        end
    end
    return;
end

if isempty(dirname0)
    return;
end

if dirname0(end)~='/' && dirname0(end)~='\'
    dirname0(end+1)='/';
end
dirname = [dirname0, 'anatomical/'];

if exist([dirname, 'headsurf.mat'],'file')

    load([dirname, 'headsurf.mat'],'-mat');
    
else
   
    if ~exist([dirname, 'headsurf.mesh'],'file')
        return;
    end
    if ~isempty(headsurf.mesh.vertices)    
        return;
    end
    if ishandles(headsurf.handles.surf)    
        return;
    end

    [v f] = read_surf([dirname, 'headsurf.mesh']);
    if isempty(v) | isempty(f)
        return;
    end

    if exist([dirname, 'headsurf2vol.txt'],'file')
        T_2vol = load([dirname, 'headsurf2vol.txt'],'-ascii');
    else
        T_2vol = eye(4);
    end
    v = xform_apply(v,T_2vol);
    fv.vertices = v;
    fv.faces = f;
    
    headsurf.mesh = fv;
    headsurf.T_2vol = T_2vol;
    headsurf.center = findcenter(fv.vertices);
    headsurf.centerRotation = headsurf.center;
    
    headsurf.mesh_reduced = reduceMesh(headsurf.mesh);
    
end


if ~headsurf.isempty(headsurf)
    headsurf.pathname = dirname0;
end


