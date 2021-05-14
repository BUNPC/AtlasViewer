function imgrecon = getImgRecon(imgrecon, dirname, fwmodel, pialsurf, probe, dataTree)

if isempty(imgrecon)
    return;
end

if iscell(dirname)
    for ii=1:length(dirname)
        imgrecon = getImgRecon(imgrecon, dirname{ii}, fwmodel, pialsurf, probe, dataTree);
        if ~imgrecon.isempty(imgrecon)
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
dirnameOut = [dirname 'imagerecon/'];

% Error check rest of the arguments
if ~exist('fwmodel','var') || isempty(fwmodel)
    fwmodel = initFwmodel();
end
if ~exist('pialsurf','var') || isempty(pialsurf)
    pialsurf = initPialsurf();
end
if ~exist('probe','var') || isempty(probe)
    probe = initProbe();
end
    

% Since sensitivity profile exists, enable all image panel controls 
% for calculating metrics
set(imgrecon.handles.pushbuttonCalcMetrics_new, 'enable','on');

imgrecon.mesh = fwmodel.mesh;

if exist([dirnameOut, 'metrics.mat'], 'file')
    load([dirnameOut, 'metrics.mat']);
    imgrecon.localizationError = localizationError;
    imgrecon.resolution = resolution;
end

if exist([dirnameOut, 'Aimg_conc.mat'],'file')
    imgrecon.Aimg_conc = load([dirnameOut, 'Aimg_conc.mat'], '-mat');
end
if exist([dirnameOut, 'Aimg_conc_scalp.mat'],'file')
    imgrecon.Aimg_conc_scalp = load([dirnameOut, 'Aimg_conc_scalp.mat'], '-mat');
end

if ~isempty(probe.ml) & ~isempty(fwmodel.Adot)
    enableImgReconGen(imgrecon, 'on');
    enableImgReconDisplay(imgrecon, 'on');
else
    enableImgReconGen(imgrecon, 'off');
    enableImgReconDisplay(imgrecon, 'off');
end

if ~imgrecon.isempty(imgrecon)
    imgrecon.pathname = dirname;
end

