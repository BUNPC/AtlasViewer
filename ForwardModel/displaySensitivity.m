function fwmodel = displaySensitivity(fwmodel, pialsurf, labelssurf, probe, hAxes)
if isempty(fwmodel)
    return;
end
if fwmodel.isempty(fwmodel)
    set(fwmodel.handles.menuItemImageReconGUI,'enable','off');
    return;
end

val = get(fwmodel.handles.popupmenuImageDisplay,'value');

if ~exist('hAxes','var')
    hAxes = fwmodel.handles.axes;
end

if leftRightFlipped(fwmodel)
    axes_order = [2,1,3];
else
    axes_order = [1,2,3];
end

if ~isempty(probe.optpos_reg)
    set(fwmodel.handles.menuItemGenerateMCInput,'enable','on');
else
    set(fwmodel.handles.menuItemGenerateMCInput,'enable','off');    
end

% Error checks
if isempty(probe.optpos_reg)
    return;
end
if isempty(probe.ml)
    return;
end

% Find the channels for which to display sensitivity
if fwmodel.Ch(1)==0 && fwmodel.Ch(2)==0
    fwmodel.iCh = 1:size(fwmodel.Adot,1);
else
    fwmodel.iCh = find(probe.ml(:,1)==fwmodel.Ch(1) & probe.ml(:,2)==fwmodel.Ch(2), 1);
end
if isempty(fwmodel.iCh)
    return;
end


% Wavelength to display always one for now. TBD: Add feature to select
% between wavelengths
iW = 1;
viewAxesXYZ(hAxes, axes_order);
if all(fwmodel.Adot(fwmodel.iCh(1),:,iW)==0)
    intensity = fwmodel.cmThreshold(1).*ones(size(sum(fwmodel.Adot(fwmodel.iCh,:,iW),1),2), 1);
else
    intensity = log10(sum(fwmodel.Adot(fwmodel.iCh,:,iW),1));
end

if ishandles(fwmodel.handles.surf)
    delete(fwmodel.handles.surf);
end
intensity0 = zeros(length(intensity),1)-1;
fwmodel.handles.surf = displayIntensityOnMesh(fwmodel.mesh, intensity, 'off','off', axes_order);
fwmodel.handles.surf0 = displayIntensityOnMesh(fwmodel.mesh, intensity0, 'off','off', axes_order);
hold off;


set(fwmodel.handles.menuItemImageReconGUI,'enable','on');

if ishandles(fwmodel.handles.surf) & (val == fwmodel.menuoffset+1)
    
    fwmodel = showFwmodelDisplay(fwmodel, hAxes, 'on');
    fwmodel = enableFwmodelDisplay(fwmodel, 'on');
    fwmodel = setSensitivityColormap(fwmodel, hAxes);
    
    setProbeDisplay(probe,[],fwmodel.iCh);
    
    set(pialsurf.handles.radiobuttonShowPial, 'value',0);
    uipanelBrainDisplay(pialsurf.handles.radiobuttonShowPial, {pialsurf, labelssurf});
   
end

