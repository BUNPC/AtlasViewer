function fwmodel = getFwmodel(fwmodel, dirname, pialsurf, headsurf, headvol, probe)

if iscell(dirname)
    for ii=1:length(dirname)
        fwmodel = getFwmodel(fwmodel, dirname{ii}, pialsurf, headsurf, headvol, probe);
        if ~fwmodel.isempty(fwmodel)
            return;
        end
        if ~isempty(fwmodel.projVoltoMesh_brain)
            return;
        end
    end
    return;
end

if isempty(dirname)
    return;
end

if dirname(end)~='/' && dirname(end)~='\'
    dirname(end+1)='/';
end
dirnameOut = [dirname, 'fw/'];

if exist([dirnameOut, 'headvol.vox'],'file')
    fwmodel.headvol = load_vox([dirnameOut, 'headvol.vox'], fwmodel.headvol);
    if ~isempty(headvol.center)
        % It's fwmodel.headvol not heavol that will have the correct transformation T_2mc
        % since we're getting the transformed saved volume from fw not anatomical folder
        fwmodel.headvol.center = xform_apply(headvol.center, fwmodel.headvol.T_2mc);
    else
        fwmodel.headvol.center = findcenter(fwmodel.headvol.img);
    end
elseif isidentity(headvol.T_2digpts)
    fwmodel.headvol = headvol;
end

fwmodel.mesh_orig = pialsurf.mesh;
fwmodel.mesh = pialsurf.mesh_reduced;
fwmodel.mesh_scalp_orig = headsurf.mesh;
fwmodel.mesh_scalp = headsurf.mesh_reduced;

if exist([dirnameOut, 'projVoltoMesh_brain.mat'],'file')
    fwmodel.projVoltoMesh_brain = [dirnameOut, 'projVoltoMesh_brain.mat'];
end

if exist([dirnameOut, 'projVoltoMesh_scalp.mat'],'file')
    fwmodel.projVoltoMesh_scalp = [dirnameOut, 'projVoltoMesh_scalp.mat'];
end


if isempty(fwmodel.fluenceProfFnames)
    
    dirnameFluence = dirnameOut;
    
    % Check if there a fluence profile to load in this particular search path
    fluenceProfFnames = dir([dirnameFluence, 'fluenceProf*.mat']);
    if isempty(fluenceProfFnames)
        dirnameFluence = [headsurf.pathname, 'fw/'];
        fluenceProfFnames = dir([dirnameFluence, 'fluenceProf*.mat']);
    end
    
    for ii = 1:length(fluenceProfFnames)
        foo = loadFluenceProf([dirnameFluence, fluenceProfFnames(ii).name], 'index');
        fwmodel.fluenceProfFnames{foo.index} = [dirnameFluence, fluenceProfFnames(ii).name];
    end
    
    if ~isempty(fwmodel.fluenceProfFnames)
        s = loadFluenceProf(fwmodel.fluenceProfFnames{1});
        fwmodel.mesh = s.mesh;
        fwmodel.nWavelengths = size(s.intensities,3);
        fwmodel.nphotons = s.nphotons;
        fwmodel.headvol.tiss_prop = s.tiss_prop;
        fwmodel.nFluenceProfPerFile = size(s.srcpos,1);
        fwmodel.voxPerNode = s.voxPerNode;
    end
    
end
    
if exist([dirnameOut, 'Adot.mat'],'file')
    
    load([dirnameOut, 'Adot.mat']);
    
    if exist('tiss_prop','var')
        fwmodel.headvol.tiss_prop = tiss_prop;
    end
    if exist('nphotons','var')
        fwmodel.nphotons = nphotons;
    end
    if ~isempty(fwmodel.mesh)
        if size(fwmodel.mesh.vertices,1) == size(Adot,2)
            fwmodel.Adot = Adot;
            d=getFileDateStruct([dirnameOut, 'Adot.mat']);
            fwmodel.AdotDate = d;
            fwmodel.nWavelengths = size(Adot,3);
        end
    end
    
    if exist([dirnameOut, 'Adot_scalp.mat'],'file')
        load([dirnameOut, 'Adot_scalp.mat']);        
        if ~isempty(fwmodel.mesh_scalp)
            if size(fwmodel.mesh_scalp.vertices,1) == size(Adot_scalp,2)
                fwmodel.Adot_scalp = Adot_scalp;
                d=getFileDateStruct([dirnameOut, 'Adot_scalp.mat']);
            end
        end        
    else
        fwmodel.Adot_scalp     = [];        
    end
    
    if ~isempty(fwmodel.handles) && ishandle(fwmodel.handles.menuItemImageReconGUI)
        set(fwmodel.handles.menuItemImageReconGUI,'enable','on');
    end
    
else
    
    fwmodel.Adot     = [];
    fwmodel.AdotDate = struct('num',0);
    if ~isempty(fwmodel.handles) && ishandle(fwmodel.handles.menuItemImageReconGUI)
        set(fwmodel.handles.menuItemImageReconGUI,'enable','off');
    end
       
    % Look at MC input files for forward model params only 
    % if not using precalculated fluence files
    if isempty(fwmodel.fluenceProfFnames)
        fwmodel.nWavelengths = length(fwmodel.headvol.tiss_prop(1).scattering);
    end
end

fwmodel.pathname = dirname;


