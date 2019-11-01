function headvol = getHeadvol(headvol,dirname0)
global DEBUG

if iscell(dirname0)
    for ii=1:length(dirname0)
        headvol = getHeadvol(headvol, dirname0{ii});
        if ~headvol.isempty(headvol)
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

if exist([dirname, 'headvol.mat'],'file')

    load([dirname, 'headvol.mat'],'-mat');
    
else

    if isempty(headvol)
        headvol = initHeadvol();
    end
    if ~isempty(headvol.img)
        return;
    end
    
    if ~exist([dirname, 'headvol.vox'],'file') && ~exist([dirname, 'headvol.vox.gz'],'file')
        return;
    elseif ~exist([dirname, 'headvol.vox'],'file')
        gunzip([dirname, 'headvol.vox.gz']);
    end
    
    headvol = load_vox([dirname, 'headvol.vox'],headvol);
    
    if DEBUG
        mesh = isosurface(headvol.img,.9);
        mesh.vertices = [mesh.vertices(:,2) mesh.vertices(:,1) mesh.vertices(:,3)];
        [mesh.vertices, mesh.faces] = reduceMesh(mesh.vertices, mesh.faces,.05);
        headvol.mesh = mesh;
    end

    headvol.center = findcenter(headvol.img);
    headvol.centerRotation = headvol.center;

end

if ~headvol.isempty(headvol)
    headvol.pathname = dirname0;
end

