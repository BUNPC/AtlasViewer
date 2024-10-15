function h = createColorbar(cmThreshold, img, leastSignificantVal)
global atlasViewer
h = [];
if nargin == 0
    return;
end
if ~exist('img','var')
    img = [];
end
if ~exist('leastSignificantVal','var')
    if ~isempty(img)
        leastSignificantVal = mean(img);
    else
        leastSignificantVal = [];
    end
end

if isempty(cmThreshold) && isempty(img)
    return;
end

if ~isempty(img)
    if ishandles(img)
        img = img.FaceVer;
    end
    img(isnan(img)) = 0;
    img(isinf(img)) = 0;
    if isempty(cmThreshold)
        meany = mean(img);
        miny = min(img);
        maxy = max(img);
        range = abs(maxy-miny);
        d1 = abs(maxy-meany);
        d2 = abs(miny-meany);
        if range>1
            d = max([d1, d2])/2;
        else
            d = min([d1, d2])/2;
        end
        cmThreshold = [meany-d, meany+d];
    end
end

% Colormap threshold error check
if cmThreshold(1) == cmThreshold(2)
    cmThreshold(1) = cmThreshold(1)-1;
    cmThreshold(2) = cmThreshold(2)+1;
end

% Create new colormap graphic
h = colorbar;
set(h, 'visible','on');
if isempty(cmThreshold)
    return;
end

cm = jet(10000);
cm(1,:) = [0.8 0.8 0.8];

colormap(cm);
caxis(cmThreshold);

% Set colormap thresholds edit box
set(atlasViewer.imgrecon.handles.editColormapThreshold,'string',sprintf('%0.2g %0.2g',cmThreshold(1), cmThreshold(2)));

