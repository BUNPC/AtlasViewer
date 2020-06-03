function hbconc = displayHbConc(hbconc, pialsurf, probe, fwmodel, imgrecon)

% Error checks
if isempty(hbconc)
    return;
end
if probe.isempty(probe)
    return;
end
if hbconc.isempty(hbconc)
    return;
end
if isempty(probe.optpos_reg)
    return;
end
if isempty(probe.ml)
    return;
end
if isempty(hbconc.HbO)
    return;
end
if isempty(hbconc.HbR)
    return;
end

if leftRightFlipped(hbconc)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

val = get(hbconc.handles.popupmenuImageDisplay,'value');

if ~exist('hAxes','var')
    hAxes = hbconc.handles.axes;
end
if AVUtils.ishandles(hbconc.handles.HbO)
    delete(hbconc.handles.HbO);
end
if AVUtils.ishandles(hbconc.handles.HbR)
    delete(hbconc.handles.HbR);
end

hold on
viewAxesXYZ(hAxes, axes_order);
HbO = hbconc.HbO;
HbR = hbconc.HbR;
if ~isempty(hbconc.mesh)
    hbconc.handles.HbO = ....
        displayIntensityOnMesh(hbconc.mesh, HbO, 'off','off', axes_order);
    hbconc.handles.HbR = ....
        displayIntensityOnMesh(hbconc.mesh, HbR, 'off','off', axes_order);
end
hold off;

hclim = hbconc.handles.editColormapThreshold;

if ~isempty(hAxes)
    axes(hAxes);
end

% Enable or disable display controls based on the availability of the 
% HbO or HbR handles
if AVUtils.ishandles(hbconc.handles.HbO) & (val == hbconc.menuoffset+1)
      
    % Turn sensitivity display off
    fwmodel = showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    imgrecon = showImgReconDisplay(imgrecon, hAxes, 'off', 'off', 'off', 'off');
    
    hbconc = showHbConcDisplay(hbconc, hAxes, 'on', 'off');
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, pialsurf);
    
elseif AVUtils.ishandles(hbconc.handles.HbR) & (val == hbconc.menuoffset+2)

    % Turn sensitivity display off
    fwmodel = showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    imgrecon = showImgReconDisplay(imgrecon, hAxes, 'off', 'off', 'off', 'off');    
       
    hbconc = showHbConcDisplay(hbconc, hAxes, 'off', 'on');
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, pialsurf);
    
else
    
    % Turn HbO on and HbR display off
    hbconc = showHbConcDisplay(hbconc, hAxes, 'off', 'off');
      
end

