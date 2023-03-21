function imgrecon = setImgReconColormap(imgrecon, hAxes, img, cmThreshold)
if ~exist('img','var') || isempty(img)
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
    createColorbar(cmThreshold, img);
else
    createColorbar([], img);
end

