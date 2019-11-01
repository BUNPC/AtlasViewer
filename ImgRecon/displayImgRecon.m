function imgrecon = displayImgRecon(imgrecon, fwmodel, pialsurf, labelssurf, probe, hAxes)

if isempty(imgrecon)
    return;
end
if fwmodel.isempty(fwmodel)
    return;
end

% Since sensitivity profile exists, enable all image panel controls
% for calculating metrics
set(imgrecon.handles.pushbuttonCalcMetrics_new, 'enable','on');

if imgrecon.isempty(imgrecon)
    return;
end

if leftRightFlipped(imgrecon)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end


val = get(imgrecon.handles.popupmenuImageDisplay,'value');

if ~exist('hAxes','var')
    hAxes = imgrecon.handles.axes;
end

% Error checks
if isempty(imgrecon.localizationError)
    return;
end
if isempty(imgrecon.resolution)
    return;
end
if isempty(probe.optpos_reg)
    return;
end
if isempty(probe.ml)
    return;
end

viewAxesXYZ(hAxes, axes_order);
intensityLC  = imgrecon.localizationError;
intensityRes = imgrecon.resolution;
HbO          = imgrecon.Aimg_conc.HbO;
HbR          = imgrecon.Aimg_conc.HbR;

if ~isempty(imgrecon.mesh)
    imgrecon.handles.hLocalizationError = ....
        displayIntensityOnMesh(imgrecon.mesh, intensityLC, 'off','off', axes_order);
    imgrecon.handles.hResolution = ....
        displayIntensityOnMesh(imgrecon.mesh, intensityRes, 'off','off', axes_order);
    
    if ~isempty(HbO)
        imgrecon.handles.hHbO = displayIntensityOnMesh(imgrecon.mesh, HbO, 'off','off', axes_order);
    end
    if ~isempty(HbR)
        imgrecon.handles.hHbR = displayIntensityOnMesh(imgrecon.mesh, HbR, 'off','off', axes_order);
    end
    
end
hold off;


% Enable of disable display controls based on the availability of the 
% hLocalizationError or hResolution handles
if ishandles(imgrecon.handles.hLocalizationError) & val==imgrecon.menuoffset+1
       
    % Turn sensitivity display off
    fwmodel = showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    imgrecon = showImgReconDisplay(imgrecon, hAxes, 'on', 'off', 'off', 'off');
    
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, {pialsurf, labelssurf});
    
elseif ishandles(imgrecon.handles.hLocalizationError) & val==imgrecon.menuoffset+2

    % Turn sensitivity display off
    fwmodel = showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    imgrecon = showImgReconDisplay(imgrecon, hAxes, 'off', 'on', 'off', 'off');    
       
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, {pialsurf, labelssurf});

else
  
    % Turn localization error on and resolution display off
    imgrecon = showImgReconDisplay(imgrecon, hAxes, 'off', 'off', 'off', 'off');
    
end

