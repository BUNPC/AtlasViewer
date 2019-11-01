function pialsurf = getPialsurf(pialsurf, dirname0)

if iscell(dirname0)
    for ii=1:length(dirname0)
        pialsurf = getPialsurf(pialsurf, dirname0{ii});
        if ~pialsurf.isempty(pialsurf)
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

if exist([dirname, 'pialsurf.mat'],'file')

    load([dirname, 'pialsurf.mat'],'-mat');
    
else
  
    if ~exist([dirname 'pialsurf.mesh'],'file')
        return;
    end
    if ~isempty(pialsurf.mesh.vertices)    
        return;
    end
    if ishandles(pialsurf.handles.surf)    
        return;
    end
    
    [v,f] = read_surf([dirname 'pialsurf.mesh']);
    if isempty(v) | isempty(f)
        return;
    end
          
    if exist([dirname, 'pialsurf2vol.txt'],'file')
        T_2vol = load([dirname, 'pialsurf2vol.txt'],'-ascii');
    else
        T_2vol = eye(4);        
    end
    v = xform_apply(v,T_2vol);
    fv.vertices = v;
    fv.faces = f;

    pialsurf.mesh = fv;
    pialsurf.T_2vol = T_2vol;
    pialsurf.center = findcenter(v);

    pialsurf.mesh_reduced = reduceMesh(pialsurf.mesh);
    
end

if ~pialsurf.isempty(pialsurf)
    pialsurf.pathname = dirname0;
end
