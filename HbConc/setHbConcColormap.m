function hbconc = setHbConcColormap(hbconc, ~, img, cmThreshold)
if ~exist('img','var')
    img = [];
end
if ~exist('cmThreshold','var')
    cmThreshold = [];
end

if ~isempty(cmThreshold)
    createColorbar(cmThreshold);
else
    createColorbar([], img);
end