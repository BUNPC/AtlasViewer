function h = displayFluenceProf(fwmodel, pialsurf, iOpt, hAxes, thresh)

standalone=true;

val = get(fwmodel.handles.popupmenuImageDisplay,'value');
if val==1
    colorbar off;
    return;
end

if leftRightFlipped(fwmodel)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

fluenceProf = initFluenceProf();
if isfield(pialsurf, 'mesh')
    if ~isempty(fwmodel.mesh)
        mesh = fwmodel.mesh;
    else
        mesh = pialsurf.mesh;
    end
else
    mesh = pialsurf;
end

hold on; 

% Error checks
if isempty(fluenceProf)
    return;
end
if ~exist('iOpt','var') | isempty(iOpt)
    iOpt = 1:size(fluenceProf,1);
end
if ~exist('hAxes','var')
    hAxes = gca;
end
if ~exist('thresh','var')
    thresh = [-1,0];
end

lights_onoff='off';
if standalone
    lights_onoff = 'on';
end

% First check if there's a profile already cached
if isFluenceProfEmpty(fwmodel.fluenceProf(1))
    i=2; j=2;
elseif isFluenceProfEmpty(fwmodel.fluenceProf(2))
    i=1; j=1;
else
    i=1; j=2;
end

if fwmodel.Ch(1) & ~fwmodel.Ch(2)
    intensity = fwmodel.fluenceProf(i).intensities(iOpt,:);
elseif ~fwmodel.Ch(1) & fwmodel.Ch(2)
    intensity = fwmodel.fluenceProf(j).intensities(iOpt,:);
end
intensity = log10(sum(intensity,1));

mesh = fwmodel.mesh;

h = displayIntensityOnMesh(mesh, intensity, lights_onoff, axes_order);

if ishandles(h)
    
    fwmodel = enableFwmodelDisplay(fwmodel, 'on');
    colorbar;

    % Set colormap threshold 
    fwmodel = setSensitivityColormap(fwmodel, hAxes);
        
end

if standalone
    axis off;
    axis equal;
    axis vis3d;
    rotate3d on;    
else
    h = fwmodel;
    hold off;
end
