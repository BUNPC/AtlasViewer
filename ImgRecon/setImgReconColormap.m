function imgrecon = setImgReconColormap(imgrecon, hAxes, img, cmThreshold)
if ~exist('img','var')
    img = getImgRecon_DisplayPanelImage(imgrecon);
end
if ~exist('cmThreshold','var')
    cmThreshold = [];
end

% Get axes
if ~isempty(hAxes)
    axes(hAxes);
else
    return;
end

if ~isempty(cmThreshold)
    createColorbar(cmThreshold);
else
    createColorbar([], img);
end

