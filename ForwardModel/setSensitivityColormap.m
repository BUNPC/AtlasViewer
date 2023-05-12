function fwmodel = setSensitivityColormap(fwmodel, hAxes, cmThreshold)

if ~isempty(hAxes)
    axes(hAxes);
else
    return;
end

if isempty(fwmodel.iCh)
    return;
end
if ~exist('cmThreshold','var')
    cmThreshold = [];
end

if isempty(cmThreshold)
    cmThreshold = fwmodel.cmThreshold;
end

% Wavelength to display always one for now. TBD: Add feature to select
% between wavelengths
img = getFwmodel_DisplayPanelImage(fwmodel);

% Set colormap max/min values
createColorbar(cmThreshold, img, cmThreshold(1));


