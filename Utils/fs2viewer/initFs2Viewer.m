function fs2viewer = initFs2Viewer(handles, dirnameSubj)

% Parse arguments
if nargin==0
    handles = [];
    dirnameSubj = pwd;
end
if nargin==1
    dirnameSubj = pwd;
end
dirnameSubj = filesepStandard(dirnameSubj);

layer = initLayer();
fs2viewer = struct(...
                   'pathname','', ...
                   'handles',struct('menuItemFs2Viewer',[]), ...
                   'mripaths',struct('volumes','','surfaces','','surfaces_flash',''), ... 
                   'layers',struct('head',layer, ...
                                   'skin',layer, ...
                                   'skull',layer, ...
                                   'dura',layer, ...
                                   'csf',layer, ...
                                   'gm',layer, ...
                                   'wm',layer), ...
                   'surfs',struct('pial_lh',layer, ...
                                  'pial_rh',layer), ...
                   'hseg',layer,...                                  
                   'threshold',30, ... 
                   'checkCompatability',[], ...
                   'prepObjForSave',[], ...
                   'T_vol2ras', eye(4) ...
                  );
              
if exist([dirnameSubj, 'mri'], 'dir')
    dirnameMriVol = [dirnameSubj, 'mri/'];
else
    dirnameMriVol = dirnameSubj;
end

if exist([dirnameSubj, 'surf'], 'dir')
    dirnameMriSurf = [dirnameSubj, 'surf/'];
else
    dirnameMriSurf = dirnameSubj;
end

if exist([dirnameSubj, 'bem/flash'], 'dir')
    dirnameMriSurfFlash = [dirnameSubj, 'bem/flash/'];
else
    dirnameMriSurfFlash = dirnameSubj;
end

fs2viewer.mripaths.volumes         = dirnameMriVol;
fs2viewer.mripaths.surfaces        = dirnameMriSurf;
fs2viewer.mripaths.surfaces_flash  = dirnameMriSurfFlash;              

fs2viewer = findMriFiles(fs2viewer);

if ~isempty(handles)
    fs2viewer.handles.menuItemFs2Viewer = handles.menuItemFs2Viewer;
    if (~exist([dirnameSubj, 'anatomical/headsurf.mesh'],'file') && ...
            ~exist([dirnameSubj, 'anatomical/headvol.vox'],'file')) || ...
            ~exist([dirnameSubj, 'anatomical/pialsurf.mesh'],'file')        
        if exist([dirnameSubj, fs2viewer.hseg.filename],'file')
            set(fs2viewer.handles.menuItemFs2Viewer,'enable','on');
        elseif exist([dirnameSubj, fs2viewer.layers.head.filename],'file')
            set(fs2viewer.handles.menuItemFs2Viewer,'enable','on');
        else
            % set(fs2viewer.handles.menuItemFs2Viewer,'enable','off');
        end        
    else        
        %set(fs2viewer.handles.menuItemFs2Viewer,'enable','off');        
    end    
end
