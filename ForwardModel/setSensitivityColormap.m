function fwmodel = setSensitivityColormap(fwmodel, hAxes, img, cmThreshold)

if ~exist('img','var')
    img = [];
end
if ~exist('cmThreshold','var')
    cmThreshold = [];
end

if ~isempty(hAxes)
    axes(hAxes);
else
    return;
end

if isempty(fwmodel.iCh)
    return;
end


% Wavelength to display always one for now. TBD: Add feature to select
% between wavelengths
img = getFwmodel_DisplayPanelImage(fwmodel);

if ~isempty(fwmodel.cmThreshold)
    % Set colormap thresholds edit box
    set(fwmodel.handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',fwmodel.cmThreshold(1), fwmodel.cmThreshold(2)));
end

% Set colormap max/min values
if ~isempty(cmThreshold)    
    createColorbar(cmThreshold);
else
    createColorbar(fwmodel.cmThreshold, img);
end
