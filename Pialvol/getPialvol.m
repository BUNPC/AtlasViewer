function pialvol = getPialvol(pialvol,dirname0)
global DEBUG

if iscell(dirname0)
    for ii=1:length(dirname0)
        pialvol = getPialvol(pialvol, dirname0{ii});
        if ~pialvol.isempty(pialvol)
            return;
        end
    end
    return;
end

if isempty(dirname0)
    return;
end

if dirname0(end)~='/' && dirname0(end)~='\'
    dirname0(end+1)=filesep;
end
dirname = [dirname0, 'anatomical/'];

if exist([dirname, 'pialvol.mat'],'file')

    load([dirname, 'pialvol.mat'],'-mat');
    
else

    if isempty(pialvol)
        pialvol = initPialvol();
    end
    if ~isempty(pialvol.img)
        return;
    end
    
    if ~exist([dirname, 'pialvol.vox'],'file') && ~exist([dirname, 'pialvol.vox.gz'],'file')
        return;
    elseif ~exist([dirname, 'pialvol.vox'],'file')
        gunzip([dirname, 'pialvol.vox.gz']);
    end
    
    pialvol = load_vox([dirname, 'pialvol.vox'],pialvol);
    
    if DEBUG
        mesh = isosurface(pialvol.img,.9);
        mesh.vertices = [mesh.vertices(:,2) mesh.vertices(:,1) mesh.vertices(:,3)];
        [mesh.vertices, mesh.faces] = reduceMesh(mesh.vertices, mesh.faces,.05);
        pialvol.mesh = mesh;
    end

    pialvol.center = findcenter(pialvol.img);

end

if ~pialvol.isempty(pialvol)
    pialvol.pathname = dirname0;
end

