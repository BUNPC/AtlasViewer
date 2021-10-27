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

hbconc.Ch = str2num(get(hbconc.handles.editSelectChannel, 'string'));
val = get(hbconc.handles.popupmenuImageDisplay,'value');

if ~exist('hAxes','var')
    hAxes = hbconc.handles.axes;
end

hold on
viewAxesXYZ(hAxes, axes_order);
HbO = hbconc.HbO;
HbR = hbconc.HbR;
hHbO_old = hbconc.handles.HbO;
hHbR_old = hbconc.handles.HbR;
if ~isempty(hbconc.mesh)
    hbconc.handles.HbO = ....
        displayIntensityOnMesh(hbconc.mesh, HbO, 'off','off', axes_order);
    hbconc.handles.HbR = ....
        displayIntensityOnMesh(hbconc.mesh, HbR, 'off','off', axes_order);
end
hold off;

if ~isempty(hAxes)
    axes(hAxes);
end




% Enable or disable display controls based on the availability of the 
% HbO or HbR handles
if ishandles(hbconc.handles.HbO) & (val == hbconc.menuoffset+1)
      
    set(hbconc.handles.editColormapThreshold, 'string',sprintf('%0.2g %0.2g', hbconc.cmThreshold(val-hbconc.menuoffset, 1), hbconc.cmThreshold(val-hbconc.menuoffset, 2)));
        
    % Turn sensitivity display off
    showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    showImgReconDisplay(imgrecon, hAxes, 'off', 'off', 'off', 'off');
    
    hbconc = showHbConcDisplay(hbconc, hAxes, 'on', 'off');
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, pialsurf);
    
elseif ishandles(hbconc.handles.HbR) & (val == hbconc.menuoffset+2)

    set(hbconc.handles.editColormapThreshold, 'string',sprintf('%0.2g %0.2g', hbconc.cmThreshold(val-hbconc.menuoffset, 1), hbconc.cmThreshold(val-hbconc.menuoffset, 2)));

    % Turn sensitivity display off
    showFwmodelDisplay(fwmodel, hAxes, 'off');
    
    % Turn localization error on and resolution display off
    showImgReconDisplay(imgrecon, hAxes, 'off', 'off', 'off', 'off');    
       
    hbconc = showHbConcDisplay(hbconc, hAxes, 'off', 'on');
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, pialsurf);
    
else
    
    % Turn HbO on and HbR display off
    hbconc = showHbConcDisplay(hbconc, hAxes, 'off', 'off');
      
end

if ishandles(hHbO_old)
    delete(hHbO_old);
end
if ishandles(hHbR_old)
    delete(hHbR_old);
end
